import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/common_models.dart';
import '../legal/legal_documents.dart';

class AppStorage {
  AppStorage._();

  static final AppStorage instance = AppStorage._();

  static const _tokenKey = 'authorization_token';
  static const _userKey = 'user_info';
  static const _searchHistoryKey = 'search_history';
  static const _privacyConsentVersionKey = 'privacy_consent_version';

  late final SharedPreferences _preferences;
  Future<void>? _initialization;

  Future<void> init() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  String get token => _preferences.getString(_tokenKey) ?? '';

  bool get isLoggedIn => token.isNotEmpty;

  bool get hasAcceptedPrivacyPolicy =>
      _preferences.getString(_privacyConsentVersionKey) ==
      LegalDocuments.privacyConsentVersion;

  UserModel? get user {
    final text = _preferences.getString(_userKey);
    if (text == null || text.isEmpty) return null;
    return UserModel.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }

  Future<void> saveLogin({required String token, UserModel? user}) async {
    await _preferences.setString(_tokenKey, token);
    if (user != null) {
      await _preferences.setString(_userKey, jsonEncode(user.toJson()));
    }
  }

  Future<void> saveUser(UserModel user) async {
    await _preferences.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> clearLogin() async {
    await _preferences.remove(_tokenKey);
    await _preferences.remove(_userKey);
  }

  Future<void> clearDeletedAccount() async {
    await _preferences.remove(_searchHistoryKey);
    await clearLogin();
  }

  Future<void> acceptPrivacyPolicy() {
    return _preferences.setString(
      _privacyConsentVersionKey,
      LegalDocuments.privacyConsentVersion,
    );
  }

  Future<void> revokePrivacyPolicy() {
    return _preferences.remove(_privacyConsentVersionKey);
  }

  List<String> get searchHistory =>
      _preferences.getStringList(_searchHistoryKey) ?? <String>[];

  Future<void> addSearchKeyword(String keyword) async {
    final text = keyword.trim();
    if (text.isEmpty) return;
    final values = [text, ...searchHistory.where((item) => item != text)];
    await _preferences.setStringList(
      _searchHistoryKey,
      values.take(12).toList(),
    );
  }

  Future<void> clearSearchHistory() async {
    await _preferences.remove(_searchHistoryKey);
  }
}

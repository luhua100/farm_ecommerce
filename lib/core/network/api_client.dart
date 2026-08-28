import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;

import '../../routes/app_routes.dart';
import '../logging/app_logger.dart';
import '../storage/app_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AppStorage.instance.token;
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
    dio.interceptors.add(AppLogger.dioInterceptor());
  }

  static final ApiClient instance = ApiClient._();
  static const baseUrl = 'https://vue.climby.cn';

  late final Dio dio;

  String assetUrl(String? value) {
    var text = (value ?? '').trim();
    if (text.startsWith('[')) {
      try {
        final list = jsonDecode(text);
        if (list is List && list.isNotEmpty) text = list.first.toString();
      } catch (_) {}
    }
    text = text.replaceAll(r'\', '/');
    if (text.isEmpty) return '';
    for (final prefix in [
      '$baseUrl/uploads/',
      'https://vue.climby.cn/uploads/',
      'http://vue.climby.cn/uploads/',
    ]) {
      if (text.startsWith(prefix)) {
        return '$baseUrl/api/v2/uploads/${text.substring(prefix.length)}';
      }
    }
    if (text.startsWith('http://') || text.startsWith('https://')) return text;
    if (text.startsWith('//')) return 'https:$text';
    var path = text.startsWith('/') ? text : '/$text';
    if (path.startsWith('/uploads/')) {
      path = '/api/v2/uploads/${path.substring('/uploads/'.length)}';
    }
    return '$baseUrl$path';
  }

  Future<T?> requestObject<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? parameters,
    bool showLoading = true,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final data = await requestData(
      path,
      method: method,
      parameters: parameters,
      showLoading: showLoading,
    );
    if (data == null) return null;
    if (data is Map<String, dynamic>) return fromJson(data);
    if (data is Map) return fromJson(Map<String, dynamic>.from(data));
    throw ApiException('数据格式异常');
  }

  Future<List<T>> requestArray<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? parameters,
    bool showLoading = true,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final data = await requestData(
      path,
      method: method,
      parameters: parameters,
      showLoading: showLoading,
    );
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    return parseList(data, fromJson);
  }

  Future<dynamic> requestData(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? parameters,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) EasyLoading.show(status: '加载中...');
      final response = await dio.request<dynamic>(
        path,
        data: ['POST', 'PUT', 'DELETE'].contains(method) ? parameters : null,
        queryParameters: method == 'GET' ? parameters : null,
        options: Options(method: method),
      );
      return _unwrap(response);
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? error.message ?? '网络请求失败',
      );
    } finally {
      if (showLoading) EasyLoading.dismiss();
    }
  }

  Future<void> requestEmpty(
    String path, {
    String method = 'POST',
    Map<String, dynamic>? parameters,
    bool showLoading = true,
  }) async {
    await requestData(
      path,
      method: method,
      parameters: parameters,
      showLoading: showLoading,
    );
  }

  Future<Map<String, dynamic>> uploadImage(
    String path, {
    required List<int> bytes,
    required String fileName,
    String fieldName = 'file',
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) EasyLoading.show(status: '上传中...');
      final formData = FormData.fromMap({
        fieldName: MultipartFile.fromBytes(bytes, filename: fileName),
      });
      final response = await dio.post<dynamic>(path, data: formData);
      final data = _unwrap(response);
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      throw ApiException('数据格式异常');
    } on DioException catch (error) {
      throw ApiException(
        error.response?.statusMessage ?? error.message ?? '上传失败',
      );
    } finally {
      if (showLoading) EasyLoading.dismiss();
    }
  }

  dynamic _unwrap(Response<dynamic> response) {
    final raw = response.data;
    final json = raw is Map<String, dynamic>
        ? raw
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : null;
    if (json == null) return raw;
    final code = _asInt(json['code']);
    final message = (json['message'] ?? json['msg'] ?? '').toString();
    if (code == 0 || code == 200) return json['data'];
    if (response.statusCode == 401 ||
        code == 401 ||
        message.contains('登录') ||
        message.toLowerCase().contains('token') ||
        message.contains('授权')) {
      _handleUnauthorized();
    }
    AppLogger.w('API business failure', {
      'path': response.requestOptions.path,
      'code': code,
      'message': message,
    });
    throw ApiException(message.isEmpty ? '请求失败' : message, code: code);
  }

  Future<void> _handleUnauthorized() async {
    AppLogger.w('Unauthorized, clearing local login state');
    await AppStorage.instance.clearLogin();
    if (Get.currentRoute != AppRoutes.login) {
      Get.toNamed(AppRoutes.login);
    }
  }
}

List<T> parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
  if (data is Map) {
    final map = Map<String, dynamic>.from(data);
    for (final key in ['list', 'records', 'items', 'rows', 'data']) {
      final value = map[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }
  }
  return <T>[];
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

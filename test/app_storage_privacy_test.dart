import 'package:farm_android/core/storage/app_storage.dart';
import 'package:farm_android/data/models/common_models.dart';
import 'package:farm_android/modules/support/account_deletion_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('privacy consent is persisted and can be revoked', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final storage = AppStorage.instance;
    final firstInitialization = storage.init();
    final secondInitialization = storage.init();
    expect(identical(firstInitialization, secondInitialization), isTrue);
    await firstInitialization;

    expect(storage.hasAcceptedPrivacyPolicy, isFalse);

    await storage.acceptPrivacyPolicy();
    expect(storage.hasAcceptedPrivacyPolicy, isTrue);

    await storage.revokePrivacyPolicy();
    expect(storage.hasAcceptedPrivacyPolicy, isFalse);

    await storage.saveLogin(
      token: 'token',
      user: UserModel(id: 1, phone: '13800138000'),
    );
    await storage.addSearchKeyword('土豆');

    final controller = AccountDeletionController();
    controller.onInit();
    expect(controller.maskedPhone, '138****8000');
    expect(controller.canDelete, isFalse);

    controller.codeController.text = '1234';
    controller.toggleAcknowledgement();
    expect(controller.canDelete, isTrue);
    controller.onClose();

    await storage.clearDeletedAccount();
    expect(storage.isLoggedIn, isFalse);
    expect(storage.user, isNull);
    expect(storage.searchHistory, isEmpty);
  });
}

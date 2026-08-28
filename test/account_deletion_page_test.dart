import 'package:farm_android/core/storage/app_storage.dart';
import 'package:farm_android/core/theme/app_theme.dart';
import 'package:farm_android/data/models/common_models.dart';
import 'package:farm_android/modules/support/account_deletion_controller.dart';
import 'package:farm_android/modules/support/account_deletion_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('account deletion page follows the guarded iOS flow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await AppStorage.instance.init();
    await AppStorage.instance.saveLogin(
      token: 'token',
      user: UserModel(id: 1, phone: '13800138000'),
    );

    Get.testMode = true;
    final controller = Get.put(AccountDeletionController());
    addTearDown(Get.reset);

    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.light, home: const AccountDeletionPage()),
    );

    expect(find.text('账号注销后无法恢复'), findsOneWidget);
    expect(find.text('138****8000'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField), '1234');
    controller.toggleAcknowledgement();
    await tester.pump();

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });
}

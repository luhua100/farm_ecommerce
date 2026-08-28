import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import 'core/storage/app_storage.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(AppStorage.instance.init());
  _configureLoading();
  runApp(const ChuZhiFarmApp());
}

class ChuZhiFarmApp extends StatelessWidget {
  const ChuZhiFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '楚智农购',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      builder: EasyLoading.init(),
    );
  }
}

void _configureLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorColor = AppColors.primary
    ..progressColor = AppColors.primary
    ..textColor = AppColors.textPrimary
    ..backgroundColor = Colors.white
    ..maskColor = Colors.black.withValues(alpha: 0.18)
    ..radius = 8
    ..userInteractions = false
    ..dismissOnTap = false;
}

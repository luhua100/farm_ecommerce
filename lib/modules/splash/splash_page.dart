import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/legal/legal_documents.dart';
import '../../core/logging/app_logger.dart';
import '../../core/payment/wechat_app_payment_service.dart';
import '../../core/storage/app_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _minimumDisplayDuration = Duration(milliseconds: 350);
  static const _backgroundColor = Color(0xFF078FED);
  var _navigated = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareApp());
  }

  Future<void> _prepareApp() async {
    await Future.wait([
      AppStorage.instance.init(),
      Future<void>.delayed(_minimumDisplayDuration),
    ]);
    if (!mounted) return;

    if (!AppStorage.instance.hasAcceptedPrivacyPolicy) {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      if (!mounted) return;
      final accepted = await _showPrivacyConsent();
      if (accepted != true) {
        await SystemNavigator.pop();
        return;
      }
      await AppStorage.instance.acceptPrivacyPolicy();
    }

    unawaited(_initializeAuthorizedSdks());
    await _goMain();
  }

  Future<void> _initializeAuthorizedSdks() async {
    try {
      await WechatAppPaymentService.instance.initialize();
    } catch (error, stackTrace) {
      AppLogger.e(
        'WeChat SDK startup initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool?> _showPrivacyConsent() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('隐私保护提示'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '欢迎使用楚智农购。为了向你提供商品浏览、下单和售后服务，请在使用前阅读并同意以下协议。',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: () =>
                        _openLegalDocument(LegalDocuments.userAgreementUrl),
                    child: const Text('《用户协议》'),
                  ),
                  const Text('和'),
                  TextButton(
                    onPressed: () =>
                        _openLegalDocument(LegalDocuments.privacyPolicyAsset),
                    child: const Text('《隐私政策》'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '点击“同意并继续”后，我们才会初始化微信等第三方 SDK。你可以在“我的-设置”中再次查看协议。',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('不同意并退出'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('同意并继续'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLegalDocument(String url) async {
    await Get.toNamed(AppRoutes.webView, parameters: {'url': url});
  }

  Future<void> _goMain() async {
    if (_navigated) return;
    _navigated = true;
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _backgroundColor,
      body: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/images/farm_launch.webp'),
          fit: BoxFit.fill,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/legal/legal_documents.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/app_storage.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final phone = TextEditingController();
  final code = TextEditingController();
  final canLogin = false.obs;
  final remainingSeconds = 0.obs;

  bool get canSendCode => remainingSeconds.value <= 0;

  String get sendCodeText =>
      remainingSeconds.value > 0 ? '${remainingSeconds.value}s' : '获取验证码';

  String? get validPhone {
    final value = phone.text.trim();
    return RegExp(r'^1[3-9]\d{9}$').hasMatch(value) ? value : null;
  }

  String? get validCode {
    final value = code.text.trim();
    return RegExp(r'^\d{4}$').hasMatch(value) ? value : null;
  }

  @override
  void onInit() {
    super.onInit();
    phone.addListener(_inputChanged);
    code.addListener(_inputChanged);
  }

  void _inputChanged() {
    if (phone.text.length > 11) {
      phone.text = phone.text.substring(0, 11);
      phone.selection = TextSelection.collapsed(offset: phone.text.length);
    }
    if (code.text.length > 4) {
      code.text = code.text.substring(0, 4);
      code.selection = TextSelection.collapsed(offset: code.text.length);
    }
    canLogin.value = validPhone != null && validCode != null;
  }

  Future<void> sendCode() async {
    final phoneValue = validPhone;
    if (phoneValue == null) {
      EasyLoading.showToast('请输入正确手机号');
      return;
    }
    if (!canSendCode) {
      return;
    }
    try {
      await UserService.sendPhoneCode(phoneValue);
      EasyLoading.showSuccess('验证码已发送');
      _startCountdown();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '发送失败');
    }
  }

  void _startCountdown() {
    remainingSeconds.value = 60;
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (isClosed) return false;
      remainingSeconds.value -= 1;
      return remainingSeconds.value > 0;
    });
  }

  Future<void> login() async {
    final phoneValue = validPhone;
    if (phoneValue == null) {
      EasyLoading.showToast('请输入正确手机号');
      return;
    }
    final codeValue = validCode;
    if (codeValue == null) {
      EasyLoading.showToast('验证码需为4位数字');
      return;
    }
    try {
      final result = await UserService.loginWithPhone(phoneValue, codeValue);
      if (result == null || result.token.isEmpty) {
        EasyLoading.showToast('登录失败');
        return;
      }
      await AppStorage.instance.saveLogin(
        token: result.token,
        user: result.userInfo,
      );
      EasyLoading.showSuccess('登录成功');
      Get.back();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '登录失败');
    }
  }

  void openUserAgreement() {
    Get.toNamed(
      AppRoutes.webView,
      parameters: {'url': LegalDocuments.userAgreementUrl},
    );
  }

  void openPrivacyPolicy() {
    Get.toNamed(
      AppRoutes.webView,
      parameters: {'url': LegalDocuments.privacyPolicyAsset},
    );
  }

  @override
  void onClose() {
    phone.removeListener(_inputChanged);
    code.removeListener(_inputChanged);
    phone.dispose();
    code.dispose();
    super.onClose();
  }
}

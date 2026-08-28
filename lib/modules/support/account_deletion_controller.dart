import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../core/storage/app_storage.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../main/main_controller.dart';
import '../mine/mine_controller.dart';

class AccountDeletionController extends GetxController {
  final codeController = TextEditingController();
  final hasAcknowledged = false.obs;
  final hasRequestedCode = false.obs;
  final codeLength = 0.obs;
  final remainingSeconds = 0.obs;

  bool get canDelete => hasAcknowledged.value && codeLength.value == 4;
  bool get canSendCode => remainingSeconds.value <= 0;

  String get sendCodeText => remainingSeconds.value > 0
      ? '${remainingSeconds.value}s后重试'
      : hasRequestedCode.value
      ? '重新获取'
      : '获取验证码';

  String get maskedPhone {
    final phone = AppStorage.instance.user?.phone ?? '';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) {
      return phone.isEmpty ? '已绑定手机号' : phone;
    }
    return '${digits.substring(0, 3)}****${digits.substring(7)}';
  }

  @override
  void onInit() {
    super.onInit();
    codeController.addListener(_onCodeChanged);
  }

  void _onCodeChanged() {
    codeLength.value = codeController.text.length;
  }

  void toggleAcknowledgement() {
    hasAcknowledged.toggle();
  }

  Future<void> sendCode() async {
    if (!canSendCode) return;
    try {
      await UserService.sendAccountDeletionCode();
      EasyLoading.showSuccess('验证码已发送');
      hasRequestedCode.value = true;
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

  Future<void> deleteAccount() async {
    final code = codeController.text.trim();
    if (!RegExp(r'^\d{4}$').hasMatch(code) || !hasAcknowledged.value) return;
    try {
      await UserService.deleteAccount(code);
      await AppStorage.instance.clearDeletedAccount();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      await DefaultCacheManager().emptyCache();
      _resetLoggedOutState();
      EasyLoading.showSuccess('账号已注销');
      Get.offAllNamed(AppRoutes.main, arguments: {'initialIndex': 3});
    } catch (error) {
      EasyLoading.showToast(
        error is ApiException ? error.message : '注销失败，请稍后重试',
      );
    }
  }

  void _resetLoggedOutState() {
    if (Get.isRegistered<MineController>()) {
      final mine = Get.find<MineController>();
      mine.user.value = null;
      mine.stats.value = OrderStatsModel();
      mine.member.value = MemberInfoModel(levelName: '登录解锁会员权益');
      mine.unreadCount.value = 0;
      mine.profileVersion.value++;
    }
    if (Get.isRegistered<CartController>()) {
      final cart = Get.find<CartController>();
      cart.loggedIn.value = false;
      cart.items.clear();
    }
    if (Get.isRegistered<MainController>()) {
      final main = Get.find<MainController>();
      main.currentIndex.value = 3;
      main.cartCount.value = 0;
    }
  }

  @override
  void onClose() {
    codeController.removeListener(_onCodeChanged);
    codeController.dispose();
    super.onClose();
  }
}

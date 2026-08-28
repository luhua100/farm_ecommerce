import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/legal/legal_documents.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/app_storage.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';
import '../mine/mine_controller.dart';

class SettingsController extends GetxController {
  final nicknameController = TextEditingController();
  final nickname = ''.obs;
  final avatar = ''.obs;
  final profileVersion = 0.obs;
  final selectedImageBytes = Rxn<Uint8List>();

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final user = AppStorage.instance.user;
    nickname.value = user?.nickname?.isNotEmpty == true
        ? user!.nickname!
        : '微信用户';
    nicknameController.text = nickname.value;
    avatar.value = user?.avatar ?? '';
    refreshRemoteUser();
  }

  @override
  void onClose() {
    nicknameController.dispose();
    super.onClose();
  }

  Future<void> pickAvatar() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 82,
    );
    if (image == null) return;
    selectedImageBytes.value = await image.readAsBytes();
  }

  Future<void> saveProfile(String value) async {
    final name = value.trim();
    if (name.isEmpty) {
      EasyLoading.showToast('请输入昵称');
      return;
    }
    if (name.length > 20) {
      EasyLoading.showToast('昵称最多20个字符');
      return;
    }
    try {
      var avatarUrl = avatar.value;
      final bytes = selectedImageBytes.value;
      if (bytes != null) {
        avatarUrl = await UserService.uploadAvatar(bytes: bytes);
        if (avatarUrl.isEmpty) throw ApiException('头像上传失败');
      }
      await UserService.updateInfo(nickname: name, avatar: avatarUrl);
      final current = AppStorage.instance.user;
      final user = UserModel(
        id: current?.id ?? 0,
        nickname: name,
        avatar: avatarUrl,
        phone: current?.phone,
      );
      await AppStorage.instance.saveUser(user);
      nickname.value = name;
      avatar.value = avatarUrl;
      profileVersion.value++;
      selectedImageBytes.value = null;
      if (Get.isRegistered<MineController>()) {
        Get.find<MineController>().user.value = user;
        Get.find<MineController>().profileVersion.value++;
      }
      EasyLoading.showSuccess('已保存');
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '保存失败');
    }
  }

  Future<void> refreshRemoteUser() async {
    if (!AppStorage.instance.isLoggedIn) return;
    try {
      final value = await UserService.userInfo();
      if (value == null) return;
      await AppStorage.instance.saveUser(value);
      nickname.value = value.nickname?.isNotEmpty == true
          ? value.nickname!
          : '微信用户';
      nicknameController.text = nickname.value;
      avatar.value = value.avatar ?? '';
      profileVersion.value++;
    } catch (_) {}
  }

  Future<void> clearCache() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    EasyLoading.showSuccess('清除成功');
  }

  void openAbout() {
    Get.toNamed(AppRoutes.about);
  }

  void openAgreement() => _openAgreementUrl(LegalDocuments.userAgreementUrl);

  void openPrivacy() => _openAgreementUrl(LegalDocuments.privacyPolicyAsset);

  Future<void> logout() async {
    await AppStorage.instance.clearLogin();
    EasyLoading.showSuccess('已退出登录');
    Get.back(result: true);
  }

  void openAccountDeletion() => Get.toNamed(AppRoutes.accountDeletion);

  Future<void> revokePrivacyConsent() async {
    await AppStorage.instance.revokePrivacyPolicy();
    await SystemNavigator.pop();
  }

  void _openAgreementUrl(String url) {
    Get.toNamed(AppRoutes.webView, parameters: {'url': url});
  }
}

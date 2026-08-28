import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/storage/app_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import 'settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = AppStorage.instance.isLoggedIn;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          if (loggedIn) ...[
            _ProfileCard(controller: controller),
            const SizedBox(height: 10),
          ],
          _Group(
            children: [
              _SettingsRow(
                icon: Icons.cleaning_services_outlined,
                title: '清除缓存',
                value: '0KB',
                onTap: controller.clearCache,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _Group(
            children: [
              _SettingsRow(
                icon: Icons.info_outline,
                title: '关于我们',
                onTap: controller.openAbout,
              ),
              _SettingsRow(
                icon: Icons.description_outlined,
                title: '用户协议',
                onTap: controller.openAgreement,
              ),
              _SettingsRow(
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                onTap: controller.openPrivacy,
              ),
              _SettingsRow(
                icon: Icons.no_accounts_outlined,
                title: '撤回隐私授权',
                onTap: () => _confirmRevokePrivacy(context),
              ),
            ],
          ),
          if (loggedIn) ...[
            const SizedBox(height: 10),
            _Group(
              children: [
                _SettingsRow(
                  icon: Icons.person_off_outlined,
                  title: '注销账号',
                  onTap: controller.openAccountDeletion,
                  destructive: true,
                ),
              ],
            ),
            SizedBox(
              height: 72,
              child: Center(
                child: TextButton(
                  onPressed: () => _confirmLogout(context),
                  child: const Text(
                    '退出登录',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('提示'),
        content: const Text('确定退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('退出'),
          ),
        ],
      ),
    );
    if (confirmed == true) controller.logout();
  }

  Future<void> _confirmRevokePrivacy(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('撤回隐私授权'),
        content: const Text(
          '撤回后应用将退出。下次打开时需要重新阅读并同意隐私政策，才能继续使用楚智农购。',
          style: TextStyle(height: 1.55),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认撤回'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.revokePrivacyConsent();
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: controller.pickAvatar,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Obx(
                      () => ClipOval(
                        child: Container(
                          width: 66,
                          height: 66,
                          color: Colors.white,
                          child: controller.selectedImageBytes.value != null
                              ? Image.memory(
                                  controller.selectedImageBytes.value!,
                                  fit: BoxFit.cover,
                                )
                              : controller.avatar.value.isNotEmpty
                              ? AppNetworkImage(
                                  controller.avatar.value,
                                  cacheBustKey: controller.profileVersion.value,
                                )
                              : const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 34,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -2,
                      child: Container(
                        width: 34,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '相机',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 66,
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '昵称',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller.nicknameController,
                          decoration: const InputDecoration(
                            hintText: '请输入昵称',
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 41,
            child: FilledButton(
              onPressed: () =>
                  controller.saveProfile(controller.nicknameController.text),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(21),
                ),
              ),
              child: const Text('保存资料'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: destructive ? Colors.red : AppColors.textTertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: destructive ? Colors.red : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            const SizedBox(width: 7),
            const Text(
              '›',
              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import 'account_deletion_controller.dart';

class AccountDeletionPage extends GetView<AccountDeletionController> {
  const AccountDeletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('注销账号')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        children: [
          const Icon(Icons.warning_rounded, color: AppColors.price, size: 48),
          const SizedBox(height: 14),
          const Text(
            '账号注销后无法恢复',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '注销后，您的昵称、头像、收货地址、收藏、购物车、浏览记录等个人数据将被删除。依法需要留存的订单、支付、退款和售后记录将进行脱敏后保存。',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          const _SectionTitle('当前账号'),
          const SizedBox(height: 8),
          Text(
            controller.maskedPhone,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 26),
          const _SectionTitle('短信验证'),
          const SizedBox(height: 8),
          _CodeField(controller: controller),
          const SizedBox(height: 20),
          _Acknowledgement(controller: controller),
          const SizedBox(height: 30),
          Obx(
            () => FilledButton(
              onPressed: controller.canDelete
                  ? () => _confirmDeletion(context)
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: AppColors.price,
                disabledBackgroundColor: const Color(0xFFFCA5A5),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white.withValues(alpha: 0.75),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '永久注销账号',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeletion(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('确认永久注销账号？'),
        content: const Text('注销完成后，账号及已删除的数据无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.price),
            child: const Text('确认注销'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.deleteAccount();
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({required this.controller});

  final AccountDeletionController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.separator, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.codeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                hintText: '请输入4位验证码',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14),
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          Container(width: 0.5, height: 24, color: AppColors.separator),
          SizedBox(
            width: 112,
            child: Obx(
              () => TextButton(
                onPressed: controller.canSendCode ? controller.sendCode : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  disabledForegroundColor: AppColors.textTertiary,
                ),
                child: Text(controller.sendCodeText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Acknowledgement extends StatelessWidget {
  const _Acknowledgement({required this.controller});

  final AccountDeletionController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: controller.toggleAcknowledgement,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(
            () => Icon(
              controller.hasAcknowledged.value
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 7),
          const Expanded(
            child: Text(
              '我已知晓注销后账号及相关数据无法恢复',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

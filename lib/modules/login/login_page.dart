import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('手机号登录')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 42, 28, 24),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: const AppNetworkImage(
                'https://climby-cn.oss-cn-hangzhou.aliyuncs.com/farm/farm_logo.png',
                width: 84,
                height: 84,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '楚智农购',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '手机号快捷登录',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _InputRow(
            icon: Icons.phone,
            controller: controller.phone,
            hintText: '请输入手机号',
            keyboardType: TextInputType.number,
            obscureText: false,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
          ),
          const SizedBox(height: 16),
          _CodeInputRow(controller: controller),
          const SizedBox(height: 16),
          Obx(
            () => FilledButton(
              onPressed: controller.canLogin.value ? controller.login : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.55,
                ),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('登录'),
            ),
          ),
          const SizedBox(height: 16),
          _Agreement(controller: controller),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  const _InputRow({
    required this.icon,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    required this.obscureText,
    this.inputFormatters,
    this.trailing,
  });

  final IconData icon;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4EADF), width: 0.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hintText,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (trailing != null) trailing!,
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _CodeInputRow extends StatelessWidget {
  const _CodeInputRow({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _InputRow(
        icon: Icons.lock,
        controller: controller.code,
        hintText: '请输入4位验证码',
        keyboardType: TextInputType.number,
        obscureText: true,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        trailing: SizedBox(
          width: 82,
          child: TextButton(
            onPressed: controller.canSendCode ? controller.sendCode : null,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              disabledForegroundColor: AppColors.textTertiary,
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(controller.sendCodeText),
          ),
        ),
      ),
    );
  }
}

class _Agreement extends StatelessWidget {
  const _Agreement({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            '登录即表示同意',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          InkWell(
            onTap: controller.openUserAgreement,
            child: const Text(
              '《用户协议》',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
          const Text(
            '和',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          InkWell(
            onTap: controller.openPrivacyPolicy,
            child: const Text(
              '《隐私政策》',
              style: TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

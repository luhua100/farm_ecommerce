import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import 'coupons_controller.dart';

class CouponsPage extends GetView<CouponsController> {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF5F7F4),
        appBar: AppBar(
          title: Text(controller.receiveMode.value ? '领取优惠券' : '我的优惠券'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Text(
                    controller.receiveMode.value ? '可领取优惠券' : '我的优惠券',
                    style: const TextStyle(
                      color: Color(0xFF18211B),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (!controller.receiveMode.value)
                    SizedBox(
                      height: 29,
                      child: FilledButton(
                        onPressed: controller.openReceiveCenter,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          '去领券',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!controller.receiveMode.value) ...[
              const SizedBox(height: 10),
              _CouponTabs(controller: controller),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.loading.value && controller.coupons.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.coupons.isEmpty) {
                  return _CouponEmpty(
                    receiveMode: controller.receiveMode.value,
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: controller.coupons.length,
                    itemBuilder: (_, index) {
                      final coupon = controller.coupons[index];
                      return _CouponCard(
                        coupon: coupon,
                        receiveMode: controller.receiveMode.value,
                        onAction: () {
                          if (controller.receiveMode.value) {
                            controller.receive(coupon);
                          } else if (coupon.status == 0) {
                            controller.goUse();
                          }
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponTabs extends StatelessWidget {
  const _CouponTabs({required this.controller});

  final CouponsController controller;

  @override
  Widget build(BuildContext context) {
    const titles = ['未使用', '已使用', '已过期'];
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4EADF), width: 0.5),
      ),
      child: Obx(
        () => Row(
          children: List.generate(titles.length, (index) {
            final selected = controller.activeStatus.value == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.switchStatus(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    titles[index],
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF66736A),
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.receiveMode,
    required this.onAction,
  });

  final CouponModel coupon;
  final bool receiveMode;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final inactive = !receiveMode && coupon.status != 0;
    return Opacity(
      opacity: inactive ? 0.62 : 1,
      child: Container(
        height: 104,
        margin: const EdgeInsets.fromLTRB(12, 4.5, 12, 4.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE4EADF), width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF18211B),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      coupon.description ?? coupon.displaySubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF66736A),
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      coupon.expireText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8B9A8B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 130,
              child: CustomPaint(
                painter: _DashedDividerPainter(),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFF1FBF3), Color(0xFFE7F5EB)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
                  child: Column(
                    children: [
                      Text(
                        coupon.couponValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        coupon.limitText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (receiveMode || coupon.status == 0)
                        SizedBox(
                          width: 92,
                          height: 28,
                          child: FilledButton(
                            onPressed: coupon.received ? null : onAction,
                            style: FilledButton.styleFrom(
                              backgroundColor: coupon.received
                                  ? const Color(0xFFCBD5D0)
                                  : AppColors.primary,
                              disabledBackgroundColor: const Color(0xFFCBD5D0),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            child: Text(
                              receiveMode
                                  ? (coupon.received ? '已领取' : '立即领取')
                                  : '去使用',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                      else
                        Text(
                          coupon.status == 1 ? '已使用' : '已过期',
                          style: const TextStyle(
                            color: Color(0xFF8B9A8B),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouponEmpty extends StatelessWidget {
  const _CouponEmpty({required this.receiveMode});

  final bool receiveMode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              receiveMode ? '暂无可领取优惠券' : '暂无优惠券',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF18211B),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              receiveMode ? '有新的优惠券活动时会显示在这里' : '领取后会在这里展示，结算时也会自动匹配可用券',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8B9A8B), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD1E7D8)
      ..strokeWidth = 1;
    var y = 11.0;
    while (y < size.height - 11) {
      canvas.drawLine(Offset(0.5, y), Offset(0.5, y + 4), paint);
      y += 7;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_network_image.dart';
import 'mine_controller.dart';

class MinePage extends GetView<MineController> {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: RefreshIndicator(
        onRefresh: controller.refreshUser,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _UserCard(controller: controller),
            const SizedBox(height: 10),
            _MessageEntry(controller: controller),
            const SizedBox(height: 10),
            _OrderSection(controller: controller),
            const SizedBox(height: 10),
            _MenuSection(controller: controller),
            const SizedBox(height: 10),
            _ServiceSection(controller: controller),
            // Obx(
            //   () => controller.isLoggedIn
            //       ? Padding(
            //           padding: const EdgeInsets.only(top: 14),
            //           child: OutlinedButton(
            //             onPressed: controller.logout,
            //             child: const Text('退出登录'),
            //           ),
            //         )
            //       : const SizedBox.shrink(),
            // ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.controller});

  final MineController controller;

  @override
  Widget build(BuildContext context) {
    return _Section(
      height: 190,
      child: Obx(
        () => InkWell(
          onTap: controller.openSettingsOrLogin,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        width: 56,
                        height: 56,
                        color: const Color(0xFFEDF6EF),
                        child: controller.user.value?.avatar?.isNotEmpty == true
                            ? AppNetworkImage(
                                controller.user.value?.avatar,
                                cacheBustKey: controller.profileVersion.value,
                              )
                            : const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 30,
                              ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.phoneText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                InkWell(
                  onTap: () => controller.requireLoginOr(AppRoutes.member),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 78,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF173D2B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.member.value.levelName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (controller
                                      .member
                                      .value
                                      .discountText
                                      ?.isNotEmpty ==
                                  true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  controller.member.value.discountText!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFF6D999),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          controller.isLoggedIn
                              ? '${controller.member.value.points}\n积分'
                              : '',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '›',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageEntry extends StatelessWidget {
  const _MessageEntry({required this.controller});

  final MineController controller;

  @override
  Widget build(BuildContext context) {
    return _Section(
      height: 72,
      child: Obx(
        () => ListTile(
          onTap: controller.openMessage,
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset('assets/images/message.png', width: 28, height: 28),
              if (controller.unreadCount.value > 0)
                Positioned(
                  right: -7,
                  top: -7,
                  child: _Badge(count: controller.unreadCount.value),
                ),
            ],
          ),
          title: const Text(
            '消息通知',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            '查看系统消息和订单通知',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          trailing: const Text(
            '›',
            style: TextStyle(color: Color(0xFFAAB6AA), fontSize: 24),
          ),
        ),
      ),
    );
  }
}

class _OrderSection extends StatelessWidget {
  const _OrderSection({required this.controller});

  final MineController controller;

  @override
  Widget build(BuildContext context) {
    return _Section(
      height: 130,
      child: Obx(() {
        final stats = controller.stats.value;
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    '我的订单',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => controller.openOrders(),
                    child: const Text(
                      '全部订单  ›',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    _DashboardIcon(
                      title: '待付款',
                      icon: 'order-pay',
                      badge: stats.pendingPay,
                      onTap: () => controller.openOrders('pending_pay'),
                    ),
                    _DashboardIcon(
                      title: '待发货',
                      icon: 'order-send',
                      badge: stats.pendingShip,
                      onTap: () => controller.openOrders('pending_ship'),
                    ),
                    _DashboardIcon(
                      title: '待收货',
                      icon: 'order-reciver',
                      badge: stats.pendingReceive,
                      onTap: () => controller.openOrders('shipped'),
                    ),
                    _DashboardIcon(
                      title: '待评价',
                      icon: 'order-advice',
                      badge: stats.pendingReview,
                      onTap: () =>
                          controller.requireLoginOr(AppRoutes.reviewCenter),
                    ),
                    _DashboardIcon(
                      title: '退换/售后',
                      icon: 'order-sale',
                      onTap: () => controller.requireLoginOr(AppRoutes.refund),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.controller});

  final MineController controller;

  @override
  Widget build(BuildContext context) {
    return _Section(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _DashboardIcon(
              title: '我的收藏',
              icon: 'heart',
              onTap: () => controller.requireLoginOr(AppRoutes.favorites),
            ),
            _DashboardIcon(
              title: '优惠券',
              icon: 'coupon',
              onTap: () => controller.requireLoginOr(AppRoutes.coupons),
            ),
            _DashboardIcon(
              title: '地址管理',
              icon: 'location',
              onTap: () => controller.requireLoginOr(AppRoutes.address),
            ),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _ServiceSection extends StatelessWidget {
  const _ServiceSection({required this.controller});

  final MineController controller;

  @override
  Widget build(BuildContext context) {
    return _Section(
      height: 146,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Text(
              '更多服务',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          _ServiceRow(
            title: '设置',
            icon: 'setting',
            onTap: () => Get.toNamed(AppRoutes.settings),
          ),
          const Divider(height: 0.5, indent: 14, color: Color(0xFFEEF2EB)),
          _ServiceRow(
            title: '关于我们',
            icon: 'about',
            onTap: () => Get.toNamed(AppRoutes.about),
          ),
        ],
      ),
    );
  }
}

class _DashboardIcon extends StatelessWidget {
  const _DashboardIcon({
    required this.title,
    required this.icon,
    required this.onTap,
    this.badge = 0,
  });

  final String title;
  final String icon;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.asset('assets/images/$icon.png', width: 25, height: 25),
                  if (badge > 0)
                    Positioned(right: -8, top: -8, child: _Badge(count: badge)),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 46,
        child: Row(
          children: [
            const SizedBox(width: 14),
            Image.asset('assets/images/$icon.png', width: 19, height: 19),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            const Text(
              '›',
              style: TextStyle(color: Color(0xFFAAB6AA), fontSize: 24),
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4EADF), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD64545),
        borderRadius: BorderRadius.circular(8.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

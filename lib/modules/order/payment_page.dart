import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/price_text.dart';
import 'payment_controller.dart';

class PaymentPage extends GetView<PaymentController> {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('确认订单')),
      body: Obx(() {
        if (controller.loading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.items.isEmpty) {
          return const EmptyState(title: '暂无待结算商品');
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _StatusCard(seconds: controller.remainSeconds.value),
            const SizedBox(height: 10),
            _AddressCard(
              address: controller.address.value,
              onTap: () => _showAddressSheet(context),
            ),
            const SizedBox(height: 10),
            _GoodsCard(items: controller.items),
            const SizedBox(height: 10),
            _SummaryCard(controller: controller),
            const SizedBox(height: 10),
            _CouponCard(controller: controller),
            const SizedBox(height: 10),
            const _PaymentMethodCard(),
            const SizedBox(height: 16),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.items.isEmpty) return const SizedBox.shrink();
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.separator)),
            ),
            child: SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: controller.canPay ? controller.pay : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  controller.payButtonTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _showAddressSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _AddressSheet(controller: controller),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final expired = seconds <= 0;
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: expired ? const Color(0xFF8B3A2F) : const Color(0xFF173D2B),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expired ? '订单已超时' : '待支付',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expired ? '请返回购物车重新确认订单' : '请在10分钟内完成支付，超时需重新下单',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _countdown(seconds),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onTap});

  final AddressModel? address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (address == null)
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              if (address == null) const SizedBox(width: 8),
              Expanded(
                child: address == null
                    ? const Text(
                        '请选择收货地址',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                address!.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                address!.phone,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Text(
                            address!.fullAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoodsCard extends StatelessWidget {
  const _GoodsCard({required this.items});

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(icon: Icons.inventory_2_outlined, title: '商品信息'),
          const SizedBox(height: 10),
          ...items.indexed.map((entry) {
            final item = entry.$2;
            return Column(
              children: [
                if (entry.$1 > 0) const _DividerLine(),
                _GoodsRow(item: item),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _GoodsRow extends StatelessWidget {
  const _GoodsRow({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AppNetworkImage(item.image, width: 70, height: 70),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '分类：${item.categoryName?.isNotEmpty == true ? item.categoryName! : '其他'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    PriceText(item.price, fontSize: 16),
                    const Spacer(),
                    Text(
                      '× ${item.quantity}',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) {
    final preview = controller.preview.value;
    final rawTotal = controller.rawTotal.toStringAsFixed(2);
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          _SummaryRow('订单号', controller.orderNo.value ?? '待创建'),
          _SummaryRow('商品数量', '${controller.itemCount} 件'),
          _SummaryRow('商品金额', '¥${preview?.originalAmount ?? rawTotal}'),
          if (_positive(preview?.memberDiscountAmount))
            _SummaryRow(
              '${preview?.memberLevel ?? '会员'}优惠',
              '-¥${preview!.memberDiscountAmount}',
              valueColor: AppColors.primary,
            ),
          if (_positive(preview?.couponDiscountAmount))
            _SummaryRow(
              '优惠券',
              '-¥${preview!.couponDiscountAmount}',
              valueColor: AppColors.primary,
            ),
          Container(
            height: 42,
            color: const Color(0xFFFFF7ED),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Text(
                  '本单可获积分',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '+${preview?.earnPoints ?? controller.rawTotal.toInt()}',
                  style: const TextStyle(
                    color: Color(0xFFC17023),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _SummaryRow(
            '应付金额',
            '¥${controller.payable}',
            valueColor: AppColors.primary,
            large: true,
            showLine: false,
          ),
        ],
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) {
    final preview = controller.preview.value;
    final coupons = preview?.availableCoupons ?? const <CouponModel>[];
    final selectedId = controller.selectedCouponId.value;
    return _Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionHeader(
                  icon: Icons.confirmation_number_outlined,
                  title: '优惠券',
                ),
              ),
              if (selectedId != null)
                TextButton(
                  onPressed: controller.clearCoupon,
                  child: const Text('不使用'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (coupons.isEmpty)
            const SizedBox(
              height: 38,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '暂无可用优惠券',
                  style: TextStyle(color: Color(0xFF8B9A8B), fontSize: 13),
                ),
              ),
            )
          else
            ...coupons.map(
              (coupon) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CouponRow(
                  coupon: coupon,
                  active: coupon.id == selectedId,
                  onTap: () => controller.selectCoupon(coupon.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.wechat,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '支付方式',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const Spacer(),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '微信支付',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '将打开微信完成支付',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressSheet extends StatelessWidget {
  const _AddressSheet({required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.62,
        child: Column(
          children: [
            SizedBox(
              height: 58,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    '选择收货地址',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  // Positioned(
                  //   right: 8,
                  //   top: 8,
                  //   child: IconButton(
                  //     onPressed: () => Navigator.of(context).pop(),
                  //     icon: const Icon(Icons.close),
                  //   ),
                  // ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.addresses.isEmpty) {
                  return const EmptyState(title: '暂无收货地址');
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: controller.addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final address = controller.addresses[index];
                    final selected = controller.address.value?.id == address.id;
                    return _AddressOption(
                      address: address,
                      selected: selected,
                      onTap: () {
                        controller.selectAddress(address);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    controller.addAddress();
                  },
                  child: const Text(
                    '+ 新增收货地址',
                    style: TextStyle(fontWeight: FontWeight.w700),
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

class _AddressOption extends StatelessWidget {
  const _AddressOption({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final AddressModel address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : const Color(0xFFCBD5E1),
                  width: selected ? 5 : 1,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${address.name}   ${address.phone}${address.isDefault ? '   默认' : ''}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    address.fullAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
    this.title,
    this.value, {
    this.valueColor = AppColors.textPrimary,
    this.large = false,
    this.showLine = true,
  });

  final String title;
  final String value;
  final Color valueColor;
  final bool large;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: large ? 58 : 44,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: large
                      ? AppColors.textTertiary
                      : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: large ? 25 : 14,
                    fontWeight: large ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (showLine)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _DividerLine(),
            ),
        ],
      ),
    );
  }
}

class _CouponRow extends StatelessWidget {
  const _CouponRow({
    required this.coupon,
    required this.active,
    required this.onTap,
  });

  final CouponModel coupon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEDF6EF) : const Color(0xFFF5F7F4),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: active ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coupon.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF18211B),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    coupon.description ?? coupon.displaySubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF66736A),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              coupon.displayBadge,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 0.5, color: Color(0xFFF0F0F0));
  }
}

String _countdown(int seconds) {
  final value = seconds.clamp(0, 600);
  final minutes = value ~/ 60;
  final remain = value % 60;
  return '${minutes.toString().padLeft(2, '0')}:${remain.toString().padLeft(2, '0')}';
}

bool _positive(String? value) => (double.tryParse(value ?? '0') ?? 0) > 0;

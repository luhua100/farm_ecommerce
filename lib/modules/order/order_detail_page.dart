import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/price_text.dart';
import 'order_detail_controller.dart';

class OrderDetailPage extends GetView<OrderDetailController> {
  const OrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('订单详情')),
      body: Obx(() {
        final order = controller.order.value;
        if (controller.loading.value && order == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (order == null) {
          return EmptyState(title: '订单信息不存在', onRetry: controller.load);
        }
        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  children: [
                    _StatusCard(order: order),
                    if (order.logistics != null) ...[
                      const SizedBox(height: 10),
                      _LogisticsCard(
                        logistics: order.logistics!,
                        controller: controller,
                      ),
                    ],
                    const SizedBox(height: 10),
                    _AddressCard(order: order),
                    if (order.currentAfterSale != null) ...[
                      const SizedBox(height: 10),
                      _AfterSaleCard(
                        model: order.currentAfterSale!,
                        controller: controller,
                      ),
                    ],
                    const SizedBox(height: 10),
                    _ProductsCard(items: order.displayItems),
                    const SizedBox(height: 10),
                    _PriceCard(order: order),
                    const SizedBox(height: 10),
                    _OrderInfoCard(order: order),
                  ],
                ),
              ),
            ),
            _BottomActions(order: order, controller: controller),
          ],
        );
      }),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.normalizedStatus);
    return _Card(
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(order.normalizedStatus), color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.displayStatusText,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusHint(order.normalizedStatus),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'pending_pay' => AppColors.primary,
      'shipped' => const Color(0xFF3B82F6),
      'completed' => const Color(0xFF16A34A),
      'cancelled' => AppColors.textTertiary,
      _ => AppColors.primary,
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'pending_pay' => Icons.payments_outlined,
      'pending_ship' => Icons.inventory_2_outlined,
      'shipped' => Icons.local_shipping_outlined,
      'completed' => Icons.check_circle_outline,
      'cancelled' => Icons.cancel_outlined,
      _ => Icons.receipt_long_outlined,
    };
  }

  String _statusHint(String status) {
    return switch (status) {
      'pending_pay' => '请尽快完成支付',
      'pending_ship' => '商家正在为您备货',
      'shipped' => '商品已发出，请注意查收',
      'completed' => '订单已完成',
      'cancelled' => '订单已取消',
      _ => '订单处理中',
    };
  }
}

class _LogisticsCard extends StatelessWidget {
  const _LogisticsCard({required this.logistics, required this.controller});

  final LogisticsModel logistics;
  final OrderDetailController controller;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: InkWell(
        onTap: controller.toggleLogistics,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: '物流信息',
              trailing: controller.showLogistics.value ? '收起' : '展开',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    [logistics.company, logistics.trackingNo]
                        .whereType<String>()
                        .where((item) => item.isNotEmpty)
                        .join(' · '),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: controller.openLogistics,
                  child: const Text('物流详情'),
                ),
              ],
            ),
            if (controller.showLogistics.value && logistics.traces.isNotEmpty)
              ...logistics.traces.map(
                (trace) => Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    '${trace.displayTime}\n${trace.displayContent}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      height: 1.4,
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

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final name = order.address?.name ?? order.receiverName ?? '-';
    final phone = order.address?.phone ?? order.receiverPhone ?? '';
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: '收货信息'),
          const SizedBox(height: 10),
          Text(
            '$name  $phone',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            order.displayAddress.isEmpty ? '-' : order.displayAddress,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AfterSaleCard extends StatelessWidget {
  const _AfterSaleCard({required this.model, required this.controller});

  final AfterSaleModel model;
  final OrderDetailController controller;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: InkWell(
        onTap: () => controller.openAfterSaleDetail(model),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(title: '售后信息', trailing: '查看'),
            const SizedBox(height: 10),
            Text(
              '${model.statusText} · ${model.typeText}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '售后单号：${model.afterSaleNo}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductsCard extends StatelessWidget {
  const _ProductsCard({required this.items});

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: '商品信息'),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: AppNetworkImage(
                      item.displayImage,
                      width: 64,
                      height: 64,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item.displaySpec} × ${item.quantity}',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PriceText(item.price, fontSize: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _priceRow('商品总额', order.originalAmount ?? order.displayTotalAmount),
          _priceRow(
            '优惠金额',
            order.discountAmount ?? order.couponDiscount ?? '0.00',
          ),
          _priceRow('运费', order.freightAmount ?? '0.00'),
          const Divider(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('实付 ', style: TextStyle(color: AppColors.textPrimary)),
              PriceText(order.displayTotalAmount, fontSize: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text('¥$value', style: const TextStyle(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _OrderInfoCard extends StatelessWidget {
  const _OrderInfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('订单号', order.orderNo),
      ('创建时间', order.displayTime),
      ('支付时间', order.displayPayTime),
      ('发货时间', order.displayShipTime),
      ('完成时间', order.displayCompleteTime),
    ].where((item) => item.$2.isNotEmpty);
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: '订单信息'),
          const SizedBox(height: 10),
          ...rows.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      item.$1,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.$2,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.order, required this.controller});

  final OrderModel order;
  final OrderDetailController controller;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[
      _ActionButton(label: '联系客服', onTap: controller.openCustomerService),
    ];
    if (order.normalizedStatus == 'completed' ||
        order.normalizedStatus == 'cancelled') {
      actions.add(_ActionButton(label: '再来一单', onTap: controller.buyAgain));
    }
    final activeReturn = order.activeReturnAfterSale;
    if (activeReturn != null) {
      actions.add(
        _ActionButton(
          label: '填写退货物流',
          primary: true,
          onTap: () => controller.submitReturnLogistics(activeReturn),
        ),
      );
    }
    if (order.normalizedStatus == 'pending_pay') {
      actions.add(_ActionButton(label: '取消订单', onTap: controller.cancel));
      actions.add(
        _ActionButton(label: '去支付', primary: true, onTap: controller.pay),
      );
    }
    if (order.canApplyAfterSale) {
      actions.add(_ActionButton(label: '申请售后', onTap: controller.openRefund));
    }
    if (order.normalizedStatus == 'shipped') {
      actions.add(
        _ActionButton(label: '确认收货', primary: true, onTap: controller.receive),
      );
    }
    if (order.normalizedStatus == 'completed' && !order.reviewed) {
      actions.add(
        _ActionButton(
          label: '去评价',
          primary: true,
          onTap: controller.openReview,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.separator, width: 0.5)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: actions
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: item,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: primary ? AppColors.primary : Colors.white,
          foregroundColor: primary ? Colors.white : AppColors.textSecondary,
          side: BorderSide(
            color: primary ? AppColors.primary : AppColors.separator,
            width: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(color: AppColors.primary, fontSize: 12),
          ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

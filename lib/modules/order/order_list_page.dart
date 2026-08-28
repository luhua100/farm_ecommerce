import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/price_text.dart';
import 'order_list_controller.dart';

class OrderListPage extends GetView<OrderListController> {
  const OrderListPage({super.key});

  static const _tabs = {
    'all': '全部',
    'pending_pay': '待付款',
    'pending_ship': '待发货',
    'shipped': '待收货',
    'completed': '已完成',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的订单')),
      body: Column(
        children: [
          Obx(
            () => Container(
              color: AppColors.surface,
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _tabs.entries.map((entry) {
                  final selected = controller.status.value == entry.key;
                  final badge = controller.badgeFor(entry.key);
                  return InkWell(
                    onTap: () => controller.switchStatus(entry.key),
                    child: SizedBox(
                      width: 82,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            entry.value,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                          if (badge > 0)
                            Positioned(
                              top: 7,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.price,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  badge > 99 ? '99+' : '$badge',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          if (selected)
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: 24,
                                height: 2,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.orders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.orders.isEmpty) {
                return EmptyState(title: '暂无订单', onRetry: controller.load);
              }
              return RefreshIndicator(
                onRefresh: controller.load,
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => _OrderCard(
                    order: controller.orders[index],
                    controller: controller,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.controller});

  final OrderModel order;
  final OrderListController controller;

  @override
  Widget build(BuildContext context) {
    final items = order.displayItems;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => controller.openDetail(order),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Expanded(
                //   child: Text(
                //     order.displayTime.isEmpty
                //         ? order.orderNo
                //         : order.displayTime,
                //     maxLines: 1,
                //     overflow: TextOverflow.ellipsis,
                //     style: const TextStyle(
                //       color: AppColors.textSecondary,
                //       fontSize: 12,
                //     ),
                //   ),
                // ),
                Text(
                  order.displayStatusText,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '订单号：${order.orderNo}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.take(2).map(_OrderProductRow.new),
            if (items.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '共 ${items.length} 个商品',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '共 ${order.totalCount} 件',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Text('合计 '),
                PriceText(order.displayTotalAmount, fontSize: 16),
              ],
            ),
            _OrderActions(order: order, controller: controller),
          ],
        ),
      ),
    );
  }
}

class _OrderProductRow extends StatelessWidget {
  const _OrderProductRow(this.item);

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AppNetworkImage(item.displayImage, width: 56, height: 56),
          ),
          const SizedBox(width: 9),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.displaySpec} × ${item.quantity}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                PriceText(item.price, fontSize: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderActions extends StatelessWidget {
  const _OrderActions({required this.order, required this.controller});

  final OrderModel order;
  final OrderListController controller;

  @override
  Widget build(BuildContext context) {
    final status = order.normalizedStatus;
    final actions = <Widget>[];
    if (status == 'pending_pay') {
      actions.add(
        _ActionButton(
          label: '去支付',
          primary: true,
          onTap: () => controller.pay(order),
        ),
      );
    } else if (status == 'shipped') {
      actions.add(
        _ActionButton(
          label: '确认收货',
          primary: true,
          onTap: () => controller.receive(order),
        ),
      );
    } else if (status == 'completed') {
      if (!order.reviewed) {
        actions.add(
          _ActionButton(
            label: '去评价',
            primary: true,
            onTap: () => controller.review(order),
          ),
        );
      }
      actions.add(
        _ActionButton(label: '再次购买', onTap: () => controller.buyAgain(order)),
      );
    }
    if (actions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: actions
            .map(
              (item) =>
                  Padding(padding: const EdgeInsets.only(left: 8), child: item),
            )
            .toList(),
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
      height: 32,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: primary ? AppColors.primary : AppColors.surface,
          foregroundColor: primary ? Colors.white : AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/price_text.dart';
import 'refund_controller.dart';

class RefundPage extends GetView<RefundController> {
  const RefundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(title: Text(controller.selectMode ? '选择售后商品' : '申请售后')),
        body: controller.loading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.selectMode
            ? _OrderSelector(controller: controller)
            : _RefundForm(controller: controller),
        bottomNavigationBar: controller.selectMode
            ? null
            : Container(
                padding: const EdgeInsets.fromLTRB(15, 9, 15, 24),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  border: Border(
                    top: BorderSide(color: Color(0xFFEDF2F7), width: 0.5),
                  ),
                ),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.submitting.value
                        ? null
                        : controller.submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      controller.submitting.value ? '提交中...' : '提交申请',
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _OrderSelector extends StatelessWidget {
  const _OrderSelector({required this.controller});

  final RefundController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.eligibleOrders.isEmpty) {
      return const EmptyState(title: '暂无可售后订单', subtitle: '确认收货后的订单可申请售后。');
    }
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(2, 6, 2, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择售后商品',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '请选择需要申请退换/售后的订单商品',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        ...controller.eligibleOrders.map(
          (order) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OrderCard(
              order: order,
              footer: Row(
                children: [
                  Expanded(
                    child: Text(
                      '共${order.totalCount}件，实付 ¥${order.displayTotalAmount}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Text(
                    '申请售后',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              onTap: () => controller.selectOrder(order),
            ),
          ),
        ),
      ],
    );
  }
}

class _RefundForm extends StatelessWidget {
  const _RefundForm({required this.controller});

  final RefundController controller;

  @override
  Widget build(BuildContext context) {
    final order = controller.order.value;
    if (order == null) {
      return EmptyState(title: '暂无可售后订单', onRetry: controller.load);
    }
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        _SectionCard(
          title: '售后商品',
          trailing: controller.orderNo == null ? '重新选择' : null,
          onTrailingTap: controller.changeOrder,
          child: _OrderCard(order: order),
        ),
        _SectionCard(
          title: '退款类型',
          child: Column(
            children: [
              _TypeTile(
                title: '仅退款',
                subtitle: '无需退货，直接退款',
                active: controller.refundType.value == 'refund_only',
                onTap: () => controller.refundType.value = 'refund_only',
              ),
              const SizedBox(height: 8),
              _TypeTile(
                title: '退货退款',
                subtitle: '需要退回商品',
                active: controller.refundType.value == 'return_refund',
                onTap: () => controller.refundType.value = 'return_refund',
              ),
            ],
          ),
        ),
        _SectionCard(
          title: '退款原因',
          child: InkWell(
            onTap: () => _showReasonSheet(context),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.selectedReason.value.isEmpty
                          ? '请选择退款原因'
                          : controller.selectedReason.value,
                      style: TextStyle(
                        color: controller.selectedReason.value.isEmpty
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
        _SectionCard(
          title: '问题描述（选填）',
          child: Column(
            children: [
              TextField(
                maxLines: 4,
                maxLength: 200,
                onChanged: (value) => controller.description.value = value,
                decoration: const InputDecoration(
                  hintText: '请详细描述您遇到的问题',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...controller.proofImages.asMap().entries.map(
                    (entry) => _ProofImageTile(
                      image: entry.value,
                      onRemove: () => controller.removeImage(entry.key),
                    ),
                  ),
                  if (controller.proofImages.length < 3)
                    _AddImageTile(
                      loading: controller.pickingImages.value,
                      onTap: controller.pickImages,
                    ),
                ],
              ),
            ],
          ),
        ),
        _SectionCard(
          title: '退款金额',
          child: Row(
            children: [
              const Spacer(),
              PriceText(order.displayTotalAmount, fontSize: 20),
            ],
          ),
        ),
      ],
    );
  }

  void _showReasonSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: RefundController.reasons
              .map(
                (reason) => ListTile(
                  title: Center(child: Text(reason)),
                  onTap: () {
                    controller.selectedReason.value = reason;
                    Navigator.of(context).pop();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ProofImageTile extends StatelessWidget {
  const _ProofImageTile({required this.image, required this.onRemove});

  final RefundProofImageItem image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              image.bytes,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFDBE5EE)),
        ),
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.textTertiary,
                    size: 22,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '上传图片',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, this.footer, this.onTap});

  final OrderModel order;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
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
              Text(
                order.displayStatusText,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          ...order.displayItems.map(_GoodsRow.new),
          if (footer != null) ...[const Divider(height: 18), footer!],
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }
}

class _GoodsRow extends StatelessWidget {
  const _GoodsRow(this.item);

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

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.05)
              : const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? AppColors.primary : Colors.transparent,
            width: active ? 1 : 0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: active ? AppColors.primary : const Color(0xFFDBE5EE),
                ),
              ),
              child: active
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
    this.onTrailingTap,
  });

  final String title;
  final Widget child;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (trailing != null)
                TextButton(onPressed: onTrailingTap, child: Text(trailing!)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

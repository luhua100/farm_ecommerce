import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_state.dart';
import 'after_sale_detail_controller.dart';

class AfterSaleDetailPage extends GetView<AfterSaleDetailController> {
  const AfterSaleDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('售后详情')),
      body: Obx(() {
        final model = controller.model.value;
        if (controller.loading.value && model == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (model == null) {
          return EmptyState(title: '售后详情不存在', onRetry: controller.load);
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoCard(
                title: '售后状态',
                value: '${model.statusText}\n售后单号：${model.afterSaleNo}',
              ),
              _InfoCard(
                title: '申请信息',
                value:
                    '订单号：${model.order?.orderNo ?? '-'}\n类型：${model.typeText}\n原因：${model.reason}\n退款金额：¥${model.refundAmount}',
              ),
              if (model.description?.isNotEmpty == true)
                _InfoCard(title: '问题描述', value: model.description!),
              if (model.images.isNotEmpty) _ImagesCard(images: model.images),
              if (model.rejectReason?.isNotEmpty == true)
                _InfoCard(title: '拒绝原因', value: model.rejectReason!),
              if (model.returnTrackingNo?.isNotEmpty == true)
                _InfoCard(title: '退货物流', value: model.returnTrackingNo!),
              if (model.refundOrders.isNotEmpty)
                _TimelineCard(
                  title: '退款进度',
                  children: model.refundOrders
                      .asMap()
                      .entries
                      .map(
                        (entry) => _TimelineItem(
                          title: entry.value.displayStatus,
                          subtitle: [
                            '退款单：${entry.value.refundNo}',
                            '金额：¥${entry.value.amount}',
                            if (entry.value.displayRefundedAt.isNotEmpty)
                              entry.value.displayRefundedAt,
                          ].join('\n'),
                          active: entry.key == 0,
                          first: entry.key == 0,
                          last: entry.key == model.refundOrders.length - 1,
                        ),
                      )
                      .toList(),
                ),
              if (model.logs.isNotEmpty)
                _TimelineCard(
                  title: '处理记录',
                  children: model.logs
                      .asMap()
                      .entries
                      .map(
                        (entry) => _TimelineItem(
                          title: entry.value.displayStatus,
                          subtitle: [
                            if (entry.value.remark?.isNotEmpty == true)
                              entry.value.remark!,
                            if (entry.value.displayTime.isNotEmpty)
                              entry.value.displayTime,
                          ].join('\n'),
                          active: entry.key == 0,
                          first: entry.key == 0,
                          last: entry.key == model.logs.length - 1,
                        ),
                      )
                      .toList(),
                ),
              if (model.canSubmitReturnLogistics)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      onPressed: controller.submitReturnLogistics,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('填写退货物流'),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.title, required this.children});

  final String title;
  final List<_TimelineItem> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.first,
    required this.last,
  });

  final String title;
  final String subtitle;
  final bool active;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final dotColor = active ? AppColors.primary : const Color(0xFFCBD5E1);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 16,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 1,
                    color: first ? Colors.transparent : const Color(0xFFE2E8F0),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1,
                    color: last ? Colors.transparent : const Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: active ? AppColors.primary : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagesCard extends StatelessWidget {
  const _ImagesCard({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '凭证图片',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: images
                .take(3)
                .map(
                  (image) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppNetworkImage(image, width: 76, height: 76),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

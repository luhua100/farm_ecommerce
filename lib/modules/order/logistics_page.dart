import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../shared/widgets/empty_state.dart';
import 'logistics_controller.dart';

class LogisticsPage extends GetView<LogisticsController> {
  const LogisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('物流详情')),
      body: Obx(() {
        final model = controller.logistics.value;
        if (controller.loading.value && model == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (model == null || model.traces.isEmpty) {
          return EmptyState(title: '暂无物流信息', onRetry: controller.load);
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _SectionCard(
                title: '快递信息',
                child: Column(
                  children: [
                    _InfoRow(
                      label: '快递公司',
                      value: model.company?.isNotEmpty == true
                          ? model.company!
                          : '暂无快递公司',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: '物流单号',
                      value: model.trackingNo?.isNotEmpty == true
                          ? model.trackingNo!
                          : '暂无单号',
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(label: '状态', value: model.displayStatusText),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: '物流轨迹',
                child: Column(
                  children: model.traces.asMap().entries.map((entry) {
                    final isFirst = entry.key == 0;
                    final isLast = entry.key == model.traces.length - 1;
                    return _TraceTile(
                      trace: entry.value,
                      active: isFirst,
                      isLast: isLast,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _TraceTile extends StatelessWidget {
  const _TraceTile({
    required this.trace,
    required this.active,
    required this.isLast,
  });

  final LogisticsTraceModel trace;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textTertiary;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: active ? 10 : 8,
                  height: active ? 10 : 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: const Color(0xFFE5E7EB),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trace.displayTime,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    trace.displayContent,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.45,
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

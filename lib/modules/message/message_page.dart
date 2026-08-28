import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../shared/widgets/empty_state.dart';
import 'message_controller.dart';

class MessagePage extends GetView<MessageController> {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('消息中心')),
      body: Column(
        children: [
          _TabsBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.loading.value && controller.items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.items.isEmpty) {
                return EmptyState(title: '暂无消息', onRetry: controller.load);
              }
              return RefreshIndicator(
                onRefresh: controller.load,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 16),
                  itemCount: controller.items.length,
                  itemBuilder: (_, index) {
                    final message = controller.items[index];
                    return Dismissible(
                      key: ValueKey(message.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 18),
                        decoration: BoxDecoration(
                          color: AppColors.price,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '删除',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      confirmDismiss: (_) async {
                        await controller.delete(message);
                        return false;
                      },
                      child: _MessageCell(
                        message: message,
                        onTap: () => controller.openMessage(message),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TabsBar extends StatelessWidget {
  const _TabsBar({required this.controller});

  final MessageController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5),
        ),
      ),
      child: Row(
        children: MessageController.tabs.map((tab) {
          return Expanded(
            child: Obx(() {
              final selected = controller.currentType.value == tab.type;
              return InkWell(
                onTap: () => controller.switchType(tab.type),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      tab.title,
                      style: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    if (selected)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          width: 24,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }
}

class _MessageCell extends StatelessWidget {
  const _MessageCell({required this.message, required this.onTap});

  final MessageModel message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: message.isRead
              ? Colors.white
              : const Color.fromRGBO(18, 183, 214, 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _iconForType(message.type),
                color: AppColors.primary,
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          message.displayTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        message.displayTime,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          message.displaySubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ReadBadge(read: message.isRead),
                    ],
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

class _ReadBadge extends StatelessWidget {
  const _ReadBadge({required this.read});

  final bool read;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 42, minHeight: 22),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: read ? const Color(0xFFF1F5F9) : AppColors.primary,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        read ? '已读' : '未读',
        style: TextStyle(
          color: read ? AppColors.textSecondary : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

IconData _iconForType(String? type) {
  switch (type) {
    case 'order':
      return Icons.receipt_long_outlined;
    case 'logistics':
      return Icons.local_shipping_outlined;
    case 'refund':
      return Icons.assignment_return_outlined;
    default:
      return Icons.notifications_none_outlined;
  }
}

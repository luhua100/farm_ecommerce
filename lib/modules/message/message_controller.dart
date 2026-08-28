import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';

class MessageController extends GetxController {
  static const tabs = <MessageTab>[
    MessageTab(title: '全部', type: 'all'),
    MessageTab(title: '订单', type: 'order'),
    MessageTab(title: '物流', type: 'logistics'),
    MessageTab(title: '系统', type: 'system'),
  ];

  final loading = false.obs;
  final items = <MessageModel>[].obs;
  final currentType = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      items.assignAll(await MessageService.list(type: currentType.value));
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '消息加载失败');
    } finally {
      loading.value = false;
    }
  }

  Future<void> switchType(String type) async {
    if (type == currentType.value) return;
    currentType.value = type;
    items.clear();
    await load();
  }

  Future<void> openMessage(MessageModel message) async {
    try {
      if (!message.isRead) {
        await MessageService.markRead(message.id);
        await load();
      }
      await _openLinkedOrder(message);
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '操作失败');
    }
  }

  Future<void> delete(MessageModel message) async {
    try {
      await MessageService.delete(message.id);
      items.removeWhere((item) => item.id == message.id);
      EasyLoading.showToast('已删除');
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '删除失败');
    }
  }

  Future<void> _openLinkedOrder(MessageModel message) async {
    if (message.type == 'system') return;
    final orderNo = message.orderNo;
    if (orderNo?.isNotEmpty == true) {
      Get.toNamed(
        message.type == 'logistics'
            ? AppRoutes.logistics
            : AppRoutes.orderDetail,
        parameters: {'orderNo': orderNo!},
      );
      return;
    }
    final orderId = message.orderId;
    if (orderId == null) return;
    final orders = await OrderService.list();
    final order = orders.firstWhereOrNull((item) => item.id == orderId);
    if (order == null) {
      EasyLoading.showToast('未找到关联订单');
      return;
    }
    Get.toNamed(
      message.type == 'logistics' ? AppRoutes.logistics : AppRoutes.orderDetail,
      parameters: {'orderNo': order.orderNo},
    );
  }
}

class MessageTab {
  const MessageTab({required this.title, required this.type});

  final String title;
  final String type;
}

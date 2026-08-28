import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../core/payment/wechat_app_payment_service.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';

class OrderListController extends GetxController {
  final loading = false.obs;
  final status =
      (Get.currentRoute == AppRoutes.reviewCenter
              ? 'completed'
              : Get.parameters['status'] ?? 'all')
          .obs;
  final orders = <OrderModel>[].obs;
  final stats = Rxn<OrderStatsModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      stats.value = await OrderService.stats();
      orders.assignAll(await OrderService.list(status: status.value));
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '订单加载失败');
    } finally {
      loading.value = false;
    }
  }

  Future<void> switchStatus(String value) async {
    status.value = value;
    await load();
  }

  int badgeFor(String value) {
    final item = stats.value;
    if (item == null) return 0;
    return switch (value) {
      'pending_pay' => item.pendingPay,
      'pending_ship' => item.pendingShip,
      'shipped' => item.pendingReceive,
      _ => 0,
    };
  }

  void openDetail(OrderModel order) {
    Get.toNamed(AppRoutes.orderDetail, parameters: {'orderNo': order.orderNo});
  }

  Future<void> pay(OrderModel order) async {
    try {
      await WechatAppPaymentService.instance.pay(order.orderNo);
      EasyLoading.showToast('支付成功');
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '支付失败');
    } finally {
      await load();
    }
  }

  Future<void> receive(OrderModel order) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认收货'),
        content: const Text('确认已经收到商品了吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await OrderService.receive(order.orderNo);
      EasyLoading.showToast('已确认收货');
      await load();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '操作失败');
    }
  }

  Future<void> buyAgain(OrderModel order) async {
    try {
      await OrderService.buyAgain(order.orderNo);
      EasyLoading.showToast('已加入购物车');
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '操作失败');
    }
  }

  void review(OrderModel order) {
    Get.toNamed(AppRoutes.review, parameters: {'orderNo': order.orderNo});
  }
}

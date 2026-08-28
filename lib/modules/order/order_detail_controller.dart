import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/payment/wechat_app_payment_service.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';

class OrderDetailController extends GetxController {
  final orderNo =
      (Get.parameters['orderNo'] ?? Get.arguments?.toString() ?? '').obs;
  final loading = false.obs;
  final showLogistics = false.obs;
  final order = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (orderNo.value.isEmpty) {
      EasyLoading.showToast('订单号不能为空');
      return;
    }
    loading.value = true;
    try {
      order.value = await OrderService.detail(orderNo.value);
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '订单加载失败');
    } finally {
      loading.value = false;
    }
  }

  void toggleLogistics() {
    showLogistics.toggle();
  }

  Future<void> pay() async {
    try {
      await WechatAppPaymentService.instance.pay(orderNo.value);
      EasyLoading.showToast('支付成功');
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '支付失败');
    } finally {
      await load();
    }
  }

  Future<void> cancel() async {
    final ok = await _confirm('取消订单', '确认取消该订单吗？');
    if (!ok) return;
    try {
      await OrderService.cancel(orderNo.value);
      EasyLoading.showToast('订单已取消');
      await load();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '操作失败');
    }
  }

  Future<void> receive() async {
    final ok = await _confirm('确认收货', '确认已经收到商品了吗？');
    if (!ok) return;
    try {
      await OrderService.receive(orderNo.value);
      EasyLoading.showToast('已确认收货');
      await load();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '操作失败');
    }
  }

  Future<void> buyAgain() async {
    try {
      await OrderService.buyAgain(orderNo.value);
      EasyLoading.showToast('已加入购物车');
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '操作失败');
    }
  }

  void openRefund() {
    Get.toNamed(
      AppRoutes.refund,
      parameters: {'orderNo': orderNo.value},
    )?.then((_) => load());
  }

  void openAfterSaleDetail(AfterSaleModel model) {
    Get.toNamed(AppRoutes.afterSaleDetail, parameters: {'id': '${model.id}'});
  }

  void openReview() {
    Get.toNamed(AppRoutes.review, parameters: {'orderNo': orderNo.value});
  }

  void openLogistics() {
    Get.toNamed(AppRoutes.logistics, parameters: {'orderNo': orderNo.value});
  }

  Future<void> openCustomerService() async {
    const displayPhone = '0716-6666889';
    final dialablePhone = displayPhone.replaceAll(RegExp(r'[^+0-9]'), '');
    final opened = await launchUrl(Uri(scheme: 'tel', path: dialablePhone));
    if (opened) return;
    await Clipboard.setData(const ClipboardData(text: displayPhone));
    EasyLoading.showToast('当前设备无法拨号，客服电话已复制');
  }

  Future<void> submitReturnLogistics(AfterSaleModel model) async {
    final result = await Get.dialog<Map<String, String>>(
      _ReturnLogisticsDialog(),
    );
    if (result == null) return;
    try {
      await AfterSalesService.submitReturnLogistics(
        afterSaleId: model.id,
        company: result['company'] ?? '',
        trackingNo: result['trackingNo'] ?? '',
      );
      EasyLoading.showToast('已提交');
      await load();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '提交失败');
    }
  }

  Future<bool> _confirm(String title, String message) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
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
    return ok == true;
  }
}

class _ReturnLogisticsDialog extends StatefulWidget {
  @override
  State<_ReturnLogisticsDialog> createState() => _ReturnLogisticsDialogState();
}

class _ReturnLogisticsDialogState extends State<_ReturnLogisticsDialog> {
  final companyController = TextEditingController();
  final trackingController = TextEditingController();

  @override
  void dispose() {
    companyController.dispose();
    trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('填写退货物流'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: companyController,
            decoration: const InputDecoration(hintText: '物流公司（选填）'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: trackingController,
            decoration: const InputDecoration(hintText: '物流单号'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('取消')),
        TextButton(
          onPressed: () {
            final trackingNo = trackingController.text.trim();
            if (trackingNo.isEmpty) {
              EasyLoading.showToast('请填写物流单号');
              return;
            }
            Get.back(
              result: {
                'company': companyController.text.trim(),
                'trackingNo': trackingNo,
              },
            );
          },
          child: const Text('提交'),
        ),
      ],
    );
  }
}

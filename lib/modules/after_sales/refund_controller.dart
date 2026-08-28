import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';

class RefundController extends GetxController {
  static const reasons = ['不想要了', '商品质量问题', '商品与描述不符', '收到商品损坏', '其他原因'];

  final orderNo = Get.parameters['orderNo'];
  final loading = false.obs;
  final submitting = false.obs;
  final order = Rxn<OrderModel>();
  final eligibleOrders = <OrderModel>[].obs;
  final refundType = 'refund_only'.obs;
  final selectedReason = ''.obs;
  final description = ''.obs;
  final proofImages = <RefundProofImageItem>[].obs;
  final pickingImages = false.obs;
  final _picker = ImagePicker();

  bool get selectMode => (orderNo ?? '').isEmpty && order.value == null;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final no = orderNo;
      if (no != null && no.isNotEmpty) {
        final detail = await OrderService.detail(no);
        if (detail == null) {
          EasyLoading.showToast('订单信息不存在');
        } else if (detail.normalizedStatus != 'completed') {
          EasyLoading.showToast('确认收货后才能申请售后');
        } else if (!detail.canApplyAfterSale) {
          EasyLoading.showToast('该订单已申请过售后');
        } else {
          order.value = detail;
        }
      } else {
        final orders = await OrderService.list(status: 'completed');
        eligibleOrders.assignAll(
          orders.where((item) => item.canApplyAfterSale),
        );
      }
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '售后商品加载失败');
    } finally {
      loading.value = false;
    }
  }

  void selectOrder(OrderModel value) {
    order.value = value;
  }

  void changeOrder() {
    if ((orderNo ?? '').isEmpty) order.value = null;
  }

  Future<void> pickImages() async {
    if (pickingImages.value) return;
    final remaining = 3 - proofImages.length;
    if (remaining <= 0) {
      EasyLoading.showToast('最多上传3张图片');
      return;
    }
    pickingImages.value = true;
    try {
      final picked = await _picker.pickMultiImage(
        imageQuality: 70,
        limit: remaining,
      );
      if (picked.isEmpty) return;
      final additions = <RefundProofImageItem>[];
      for (final file in picked.take(remaining)) {
        additions.add(
          RefundProofImageItem(
            file.name.isEmpty ? 'after-sale.jpg' : file.name,
            await file.readAsBytes(),
          ),
        );
      }
      if (additions.isNotEmpty) {
        proofImages.addAll(additions.take(3 - proofImages.length));
      }
    } catch (_) {
      EasyLoading.showToast('图片选择失败');
    } finally {
      pickingImages.value = false;
    }
  }

  void removeImage(int index) {
    if (index < 0 || index >= proofImages.length) return;
    proofImages.removeAt(index);
  }

  Future<void> submit() async {
    final target = order.value;
    if (target == null) {
      EasyLoading.showToast('请先选择售后商品');
      return;
    }
    if (selectedReason.value.isEmpty) {
      EasyLoading.showToast('请选择退款原因');
      return;
    }
    submitting.value = true;
    try {
      final urls = <String>[];
      for (final image in proofImages) {
        urls.add(
          await AfterSalesService.uploadProof(
            bytes: image.bytes,
            fileName: image.fileName,
          ),
        );
      }
      await AfterSalesService.apply(
        order: target,
        type: refundType.value,
        reason: selectedReason.value,
        description: description.value.trim(),
        images: urls,
      );
      await Get.dialog<void>(
        AlertDialog(
          title: const Text('申请已提交'),
          content: const Text('我们将在1-3个工作日内处理您的申请'),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('知道了')),
          ],
        ),
      );
      Get.back(result: true);
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '提交失败');
    } finally {
      submitting.value = false;
    }
  }
}

class RefundProofImageItem {
  RefundProofImageItem(this.fileName, this.bytes);

  final String fileName;
  final Uint8List bytes;
}

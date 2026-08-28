import 'dart:typed_data';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';

class ReviewController extends GetxController {
  final orderNo = Get.parameters['orderNo'] ?? '';
  final loading = false.obs;
  final submitting = false.obs;
  final order = Rxn<OrderModel>();
  final rating = 5.obs;
  final content = ''.obs;
  final images = <ReviewImageItem>[].obs;
  final pickingImages = false.obs;
  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadOrder();
  }

  Future<void> loadOrder() async {
    if (orderNo.isEmpty) {
      EasyLoading.showToast('订单号缺失');
      return;
    }
    loading.value = true;
    try {
      order.value = await OrderService.detail(orderNo);
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '订单加载失败');
    } finally {
      loading.value = false;
    }
  }

  void selectRating(int value) {
    rating.value = value.clamp(1, 5);
  }

  Future<void> pickImages() async {
    if (pickingImages.value) return;
    final remaining = 3 - images.length;
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
      final additions = <ReviewImageItem>[];
      for (final file in picked.take(remaining)) {
        additions.add(ReviewImageItem(file.name, await file.readAsBytes()));
      }
      if (additions.isNotEmpty) {
        images.addAll(additions.take(3 - images.length));
      }
    } catch (_) {
      EasyLoading.showToast('图片选择失败');
    } finally {
      pickingImages.value = false;
    }
  }

  void removeImage(int index) {
    if (index < 0 || index >= images.length) return;
    images.removeAt(index);
  }

  Future<void> submit() async {
    final target = order.value;
    if (target == null) {
      EasyLoading.showToast('订单信息不存在');
      return;
    }
    final text = content.value.trim();
    if (text.isEmpty) {
      EasyLoading.showToast('请输入评价内容');
      return;
    }
    submitting.value = true;
    try {
      final urls = <String>[];
      for (final image in images) {
        urls.add(
          await ReviewService.uploadImage(
            bytes: image.bytes,
            fileName: image.fileName.isEmpty ? 'review.jpg' : image.fileName,
          ),
        );
      }
      await ReviewService.submit(
        orderNo: target.orderNo,
        rating: rating.value,
        content: text,
        images: urls,
      );
      EasyLoading.showToast('评价成功');
      Get.back(result: true);
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '评价失败');
    } finally {
      submitting.value = false;
    }
  }
}

class ReviewImageItem {
  ReviewImageItem(this.fileName, this.bytes);

  final String fileName;
  final Uint8List bytes;
}

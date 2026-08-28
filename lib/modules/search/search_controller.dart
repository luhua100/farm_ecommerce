import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/logging/app_logger.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/app_storage.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';

class ProductSearchController extends GetxController {
  final input = TextEditingController();
  final hotKeywords = <String>[].obs;
  final history = <String>[].obs;
  final results = <ProductModel>[].obs;
  final hotLoading = false.obs;
  final searching = false.obs;

  @override
  void onInit() {
    super.onInit();
    history.assignAll(AppStorage.instance.searchHistory);
    loadHot();
  }

  Future<void> loadHot() async {
    hotLoading.value = true;
    try {
      final values = await SearchService.hot();
      hotKeywords.assignAll(values);
      AppLogger.i('Loaded hot search keywords', {'count': values.length});
    } catch (error, stackTrace) {
      AppLogger.e(
        'Failed to load hot search keywords',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      hotLoading.value = false;
    }
  }

  Future<void> search([String? keyword]) async {
    final text = (keyword ?? input.text).trim();
    if (text.isEmpty) return;
    input.text = text;
    searching.value = true;
    try {
      await AppStorage.instance.addSearchKeyword(text);
      history.assignAll(AppStorage.instance.searchHistory);
      results.assignAll(await SearchService.search(text));
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '搜索失败');
    } finally {
      searching.value = false;
    }
  }

  Future<void> clearHistory() async {
    await AppStorage.instance.clearSearchHistory();
    history.clear();
  }

  void openProduct(ProductModel product) {
    Get.toNamed(
      AppRoutes.productDetail,
      parameters: {'id': '${product.realProductId}'},
    );
  }

  @override
  void onClose() {
    input.dispose();
    super.onClose();
  }
}

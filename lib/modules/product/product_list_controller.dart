import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../main/main_controller.dart';

class ProductListController extends GetxController {
  final loading = false.obs;
  final products = <ProductModel>[].obs;
  final rawProducts = <ProductModel>[].obs;
  final sessions = <SeckillSessionModel>[].obs;
  final currentSessionIndex = 0.obs;
  final sort = 'default'.obs;
  final tick = 0.obs;
  final filterVisible = false.obs;
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();

  Timer? _timer;

  int? get categoryId => int.tryParse(Get.parameters['categoryId'] ?? '');
  int? get brandId => int.tryParse(Get.parameters['brandId'] ?? '');
  String? get type => Get.parameters['type'];
  bool get isSeckillMode =>
      type == 'seckill' || Get.currentRoute == AppRoutes.seckill;

  String get pageTitle {
    if (isSeckillMode) return '限时秒杀';
    if (brandId != null) return '品牌优选';
    if (categoryId != null) return '分类商品';
    return '商品列表';
  }

  @override
  void onInit() {
    super.onInit();
    isSeckillMode ? loadSeckillData() : load();
  }

  @override
  void onClose() {
    _timer?.cancel();
    minPriceController.dispose();
    maxPriceController.dispose();
    super.onClose();
  }

  Future<void> loadSeckillData() async {
    loading.value = true;
    try {
      final values = await ProductService.seckillSessions();
      sessions.assignAll(values.where((item) => item.status != 'end'));
      final activeIndex = sessions.indexWhere(
        (item) => item.status == 'active',
      );
      currentSessionIndex.value = activeIndex >= 0 ? activeIndex : 0;
      await load();
      _startTimer();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '秒杀加载失败');
    } finally {
      loading.value = false;
    }
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final parameters = <String, dynamic>{
        'page': 1,
        'pageSize': 50,
        if (categoryId != null) 'categoryId': categoryId,
        if (brandId != null) 'brandId': brandId,
      };
      final list = isSeckillMode
          ? await ProductService.seckillProducts({
              ...parameters,
              'excludeEnded': 1,
              if (sessions.length > 1 &&
                  currentSessionIndex.value >= 0 &&
                  currentSessionIndex.value < sessions.length)
                'sessionId': sessions[currentSessionIndex.value].id,
            })
          : await ProductService.list(parameters);
      rawProducts.assignAll(
        isSeckillMode ? list.where((item) => item.status != 'end') : list,
      );
      _applyListState();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '商品加载失败');
    } finally {
      loading.value = false;
    }
  }

  Future<void> selectSession(int index) async {
    if (currentSessionIndex.value == index) return;
    currentSessionIndex.value = index;
    await load();
  }

  void setSort(String value) {
    sort.value = value;
    _applyListState();
  }

  void togglePriceSort() {
    sort.value = sort.value == 'priceAsc' ? 'priceDesc' : 'priceAsc';
    _applyListState();
  }

  void showFilterPanel() {
    filterVisible.value = true;
  }

  void hideFilterPanel() {
    filterVisible.value = false;
  }

  void resetFilter() {
    minPriceController.clear();
    maxPriceController.clear();
    _applyListState();
  }

  void confirmFilter() {
    final min = double.tryParse(minPriceController.text.trim());
    final max = double.tryParse(maxPriceController.text.trim());
    if (min != null && max != null && min > max) {
      EasyLoading.showToast('最低价不能高于最高价');
      return;
    }
    _applyListState();
    hideFilterPanel();
  }

  void _applyListState() {
    var list = rawProducts.toList();
    if (!isSeckillMode) {
      final min = double.tryParse(minPriceController.text.trim());
      final max = double.tryParse(maxPriceController.text.trim());
      if (min != null) {
        list = list
            .where((item) => (double.tryParse(item.displayPrice) ?? 0) >= min)
            .toList();
      }
      if (max != null) {
        list = list
            .where((item) => (double.tryParse(item.displayPrice) ?? 0) <= max)
            .toList();
      }
      switch (sort.value) {
        case 'priceAsc':
          list.sort(
            (a, b) => (double.tryParse(a.displayPrice) ?? 0).compareTo(
              double.tryParse(b.displayPrice) ?? 0,
            ),
          );
        case 'priceDesc':
          list.sort(
            (a, b) => (double.tryParse(b.displayPrice) ?? 0).compareTo(
              double.tryParse(a.displayPrice) ?? 0,
            ),
          );
        case 'sales':
          list.sort((a, b) => b.sales.compareTo(a.sales));
      }
    }
    products.assignAll(list);
  }

  void openProduct(ProductModel product) {
    Get.toNamed(
      AppRoutes.productDetail,
      parameters: {
        'id': '${product.realProductId}',
        if (product.routeSeckillId != null)
          'seckillId': '${product.routeSeckillId}',
      },
    );
  }

  void handleSeckillAction(ProductModel product) {
    if (product.status == 'waiting') {
      EasyLoading.showToast('活动尚未开始');
      return;
    }
    openProduct(product);
  }

  Future<void> addCart(ProductModel product) async {
    try {
      await CartService.add(product);
      EasyLoading.showSuccess('已加入购物车');
      await _refreshCartState();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '加入购物车失败');
    }
  }

  Future<void> _refreshCartState() async {
    if (Get.isRegistered<MainController>()) {
      await Get.find<MainController>().updateCartBadge();
    }
    if (Get.isRegistered<CartController>()) {
      await Get.find<CartController>().load();
    }
  }

  String countdownText(ProductModel product) {
    tick.value;
    final now = DateTime.now();
    final start = _parseDate(product.startTime);
    final end = _parseDate(product.endTime);
    if (start != null && now.isBefore(start)) {
      return '距开始 ${_formatInterval(start.difference(now))}';
    }
    if (end != null && now.isBefore(end)) {
      return '距结束 ${_formatInterval(end.difference(now))}';
    }
    return product.status == 'waiting' ? '即将开始' : '抢购中';
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick.value++);
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {}
    try {
      return DateTime.parse(value.replaceFirst(' ', 'T'));
    } catch (_) {}
    return null;
  }

  String _formatInterval(Duration duration) {
    final seconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    final time = [
      hours.toString().padLeft(2, '0'),
      minutes.toString().padLeft(2, '0'),
      secs.toString().padLeft(2, '0'),
    ].join(':');
    return days > 0 ? '$days天 $time' : time;
  }
}

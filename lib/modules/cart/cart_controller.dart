import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../core/storage/app_storage.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';
import '../main/main_controller.dart';

class CartController extends GetxController {
  final loading = false.obs;
  final loggedIn = AppStorage.instance.isLoggedIn.obs;
  final items = <CartItemModel>[].obs;

  double get total => items
      .where((item) => item.selected)
      .fold(0, (sum, item) => sum + item.lineTotal);
  int get selectedCount => items
      .where((item) => item.selected)
      .fold(0, (sum, item) => sum + item.quantity);
  bool get allSelected =>
      items.isNotEmpty && items.every((item) => item.selected);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loggedIn.value = AppStorage.instance.isLoggedIn;
    if (!loggedIn.value) {
      items.clear();
      loading.value = false;
      _syncMainCartBadge();
      return;
    }
    loading.value = true;
    try {
      items.assignAll(await CartService.list());
      _syncMainCartBadge();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '购物车加载失败');
    } finally {
      loading.value = false;
    }
  }

  Future<void> toggle(CartItemModel item) async {
    if (!_ensureLoggedIn()) return;
    await _mutate(
      () => CartService.update(
        cartId: item.cartId ?? item.id,
        selected: !item.selected,
      ),
    );
  }

  Future<void> step(CartItemModel item, int delta) async {
    if (!_ensureLoggedIn()) return;
    if (delta > 0 && item.stock <= 0) {
      EasyLoading.showToast('库存不足');
      return;
    }
    if (delta > 0 && item.quantity >= item.stock) {
      EasyLoading.showToast('库存不足');
      return;
    }
    final maxQuantity = item.stock > 0 ? item.stock : item.quantity;
    final quantity = (item.quantity + delta).clamp(1, maxQuantity);
    if (quantity == item.quantity) return;
    final index = _indexOf(item);
    if (index < 0) return;
    final previous = items[index];
    items[index] = previous.copyWith(quantity: quantity);
    _syncMainCartBadge();
    try {
      await CartService.update(
        cartId: item.cartId ?? item.id,
        quantity: quantity,
      );
      await load();
    } catch (error) {
      if (index < items.length) {
        items[index] = previous;
      } else {
        await load();
      }
      _syncMainCartBadge();
      EasyLoading.showToast(error is ApiException ? error.message : '操作失败');
    }
  }

  Future<void> delete(CartItemModel item) async {
    if (!_ensureLoggedIn()) return;
    final snapshot = items.toList();
    final index = _indexOf(item);
    if (index < 0) return;
    items.removeAt(index);
    _syncMainCartBadge();
    try {
      await CartService.delete(item.cartId ?? item.id);
      await load();
    } catch (error) {
      items.assignAll(snapshot);
      _syncMainCartBadge();
      EasyLoading.showToast(error is ApiException ? error.message : '操作失败');
    }
  }

  Future<void> confirmDelete(CartItemModel item) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('提示'),
        content: const Text('确定删除该商品吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await delete(item);
    }
  }

  Future<void> selectAll() async {
    if (!_ensureLoggedIn()) return;
    await _mutate(() => CartService.selectAll(!allSelected));
  }

  void checkout() {
    if (!_ensureLoggedIn()) return;
    if (selectedCount == 0) {
      EasyLoading.showToast('请选择商品');
      return;
    }
    Get.toNamed(
      AppRoutes.payment,
      arguments: items.where((item) => item.selected).toList(),
    );
  }

  Future<void> openLogin() async {
    await Get.toNamed(AppRoutes.login);
    await load();
  }

  bool _ensureLoggedIn() {
    loggedIn.value = AppStorage.instance.isLoggedIn;
    if (loggedIn.value) return true;
    openLogin();
    return false;
  }

  void goShopping() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().switchTo(0);
    } else {
      Get.offAllNamed(AppRoutes.main);
    }
  }

  Future<void> _mutate(Future<void> Function() action) async {
    try {
      await action();
      await load();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '操作失败');
    }
  }

  void _syncMainCartBadge() {
    if (!Get.isRegistered<MainController>()) return;
    Get.find<MainController>().cartCount.value = items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  int _indexOf(CartItemModel item) {
    return items.indexWhere(
      (value) => (value.cartId ?? value.id) == (item.cartId ?? item.id),
    );
  }
}

import 'package:get/get.dart';

import '../../core/storage/app_storage.dart';
import '../../data/services/services.dart';
import '../cart/cart_controller.dart';
import '../mine/mine_controller.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;
  final cartCount = 0.obs;
  final loadedTabs = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final initialIndex = Get.arguments is Map
        ? int.tryParse('${Get.arguments['initialIndex'] ?? ''}')
        : null;
    if (initialIndex != null && initialIndex >= 0 && initialIndex <= 3) {
      currentIndex.value = initialIndex;
    }
    loadedTabs.add(currentIndex.value);
    updateCartBadge();
  }

  void switchTo(int index) {
    currentIndex.value = index;
    loadedTabs.add(index);
    if (index == 2 && Get.isRegistered<CartController>()) {
      Get.find<CartController>().load();
    }
    if (index == 3 && Get.isRegistered<MineController>()) {
      Get.find<MineController>().refreshUser();
    }
    updateCartBadge();
  }

  Future<void> updateCartBadge() async {
    if (!AppStorage.instance.isLoggedIn) {
      cartCount.value = 0;
      return;
    }
    try {
      final items = await CartService.list();
      cartCount.value = items.fold(0, (sum, item) => sum + item.quantity);
    } catch (_) {}
  }
}

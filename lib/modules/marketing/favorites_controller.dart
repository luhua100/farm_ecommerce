import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../main/main_controller.dart';

class FavoritesController extends GetxController {
  final loading = false.obs;
  final products = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      products.assignAll(await FavoriteService.list());
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '收藏加载失败');
    } finally {
      loading.value = false;
    }
  }

  void openProduct(ProductModel product) {
    Get.toNamed(
      AppRoutes.productDetail,
      parameters: {'id': '${product.realProductId}'},
    );
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
}

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../main/main_controller.dart';

class CategoryController extends GetxController {
  final loading = false.obs;
  final categories = <CategoryModel>[].obs;
  final products = <ProductModel>[].obs;
  final selectedIndex = 0.obs;

  CategoryModel? get currentCategory => categories.isEmpty
      ? null
      : categories[selectedIndex.value.clamp(0, categories.length - 1)];

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final list = await HomeService.categories();
      categories.assignAll(list.where((category) => category.type != 'brand'));
      if (list.isNotEmpty) {
        await select(0);
      }
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '分类加载失败');
    } finally {
      loading.value = false;
    }
  }

  Future<void> select(int index) async {
    selectedIndex.value = index;
    final category = currentCategory;
    if (category == null) return;
    try {
      final list = await ProductService.list({
        'categoryId': category.id,
        'pageSize': 50,
      });
      products.assignAll(list);
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '商品加载失败');
    }
  }

  Future<void> selectById(int id) async {
    final index = categories.indexWhere((category) => category.id == id);
    if (index >= 0) {
      await select(index);
    }
  }

  void openProduct(ProductModel product) {
    Get.toNamed(
      AppRoutes.productDetail,
      parameters: {'id': '${product.realProductId}'},
    );
  }

  void openSearch() {
    Get.toNamed(AppRoutes.search);
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

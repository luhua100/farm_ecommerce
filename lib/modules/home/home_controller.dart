import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../category/category_controller.dart';
import '../main/main_controller.dart';

class HomeController extends GetxController {
  final loading = false.obs;
  final bannerIndex = 0.obs;
  final banners = <BannerModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final products = <ProductModel>[].obs;
  final seckillProducts = <ProductModel>[].obs;
  final hotProducts = <ProductModel>[].obs;
  final newProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    await Future.wait([
      _guard(_loadBanners),
      _guard(_loadCategories),
      _guard(_loadSeckill),
      _guard(_loadHotProducts),
      _guard(_loadNewProducts),
      _guard(_loadRecommendProducts),
    ]);
    loading.value = false;
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      EasyLoading.showToast(
        error is ApiException ? error.message : '首页部分数据加载失败',
      );
    }
  }

  Future<void> _loadBanners() async {
    banners.assignAll(await HomeService.banners());
  }

  Future<void> _loadCategories() async {
    categories.assignAll((await HomeService.categories()).take(4));
  }

  Future<void> _loadSeckill() async {
    final list = await ProductService.seckillProducts({
      'page': 1,
      'pageSize': 50,
      'excludeEnded': 1,
    });
    seckillProducts.assignAll(
      list.where((product) => product.status != 'end').take(2),
    );
  }

  Future<void> _loadHotProducts() async {
    hotProducts.assignAll(
      await ProductService.list({'page': 1, 'pageSize': 4, 'section': 'hot'}),
    );
  }

  Future<void> _loadNewProducts() async {
    newProducts.assignAll(
      await ProductService.list({'page': 1, 'pageSize': 4, 'section': 'new'}),
    );
  }

  Future<void> _loadRecommendProducts() async {
    products.assignAll(
      await ProductService.list({'page': 1, 'pageSize': 20, 'isHot': 1}),
    );
  }

  void openCategory(CategoryModel category) {
    if (Get.isRegistered<MainController>() &&
        Get.isRegistered<CategoryController>()) {
      Get.find<MainController>().switchTo(1);
      Get.find<CategoryController>().selectById(category.id);
      return;
    }
    Get.toNamed(
      AppRoutes.productList,
      parameters: {'categoryId': '${category.id}'},
    );
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

  void openBrand() {
    Get.toNamed(AppRoutes.brand);
  }

  void openSeckill() {
    Get.toNamed(AppRoutes.seckill);
  }

  void openBanner(BannerModel banner) {
    final link = banner.linkUrl?.trim() ?? '';
    if (link.startsWith('http://') || link.startsWith('https://')) {
      Get.toNamed(AppRoutes.webView, parameters: {'url': link});
      return;
    }
    final productId = banner.productId ?? banner.spuId;
    if (productId != null) {
      Get.toNamed(AppRoutes.productDetail, parameters: {'id': '$productId'});
      return;
    }
    EasyLoading.showToast('该轮播图未配置跳转');
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

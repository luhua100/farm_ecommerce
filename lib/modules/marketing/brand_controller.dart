import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';

enum BrandSortType { defaultSort, products, name }

class BrandController extends GetxController {
  final loading = false.obs;
  final banners = <BannerModel>[].obs;
  final brands = <BrandModel>[].obs;
  final categories = <String>['全部'].obs;
  final selectedCategory = 0.obs;
  final sortType = BrandSortType.defaultSort.obs;
  final bannerIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    loading.value = true;
    try {
      final results = await Future.wait([
        HomeService.banners(position: 'brand'),
        BrandService.list(),
      ]);
      banners.assignAll(results[0] as List<BannerModel>);
      brands.assignAll(results[1] as List<BrandModel>);
      final names = <String>{};
      for (final brand in brands) {
        final values = brand.categoryNames.isEmpty
            ? [brand.displayCategory]
            : brand.categoryNames;
        names.addAll(values.where((item) => item.isNotEmpty));
      }
      final sorted = names.toList()..sort((a, b) => a.compareTo(b));
      categories.assignAll(['全部', ...sorted]);
      if (selectedCategory.value >= categories.length) {
        selectedCategory.value = categories.length - 1;
      }
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '品牌加载失败');
    } finally {
      loading.value = false;
    }
  }

  List<BrandModel> get visibleBrands {
    var values = brands.toList();
    if (selectedCategory.value > 0 &&
        selectedCategory.value < categories.length) {
      final category = categories[selectedCategory.value];
      values = values
          .where(
            (brand) =>
                brand.categoryNames.contains(category) ||
                brand.displayCategory == category,
          )
          .toList();
    }
    switch (sortType.value) {
      case BrandSortType.products:
        values.sort((a, b) => b.productCount.compareTo(a.productCount));
      case BrandSortType.name:
        values.sort((a, b) => a.name.compareTo(b.name));
      case BrandSortType.defaultSort:
        break;
    }
    return values;
  }

  void selectCategory(int index) {
    selectedCategory.value = index;
  }

  void selectSort(BrandSortType value) {
    sortType.value = value;
  }

  void openBrand(BrandModel brand) {
    Get.toNamed(AppRoutes.productList, parameters: {'brandId': '${brand.id}'});
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
}

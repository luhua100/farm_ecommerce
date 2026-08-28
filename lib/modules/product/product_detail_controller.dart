import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/storage/app_storage.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';
import '../cart/cart_controller.dart';
import '../main/main_controller.dart';

class ProductDetailController extends GetxController {
  final loading = false.obs;
  final currentImage = 0.obs;
  final cartCount = 0.obs;
  final isFavorite = false.obs;
  final product = Rxn<ProductModel>();

  int get productId => int.tryParse(Get.parameters['id'] ?? '') ?? 0;
  int? get seckillId => int.tryParse(Get.parameters['seckillId'] ?? '');

  List<String> get mediaUrls {
    final value = product.value;
    if (value == null) return <String>[];
    final urls = value.images.where((item) => item.isNotEmpty).toList();
    if (urls.isEmpty && value.firstImage.isNotEmpty) urls.add(value.firstImage);
    return urls;
  }

  String get imageCounterText {
    final count = mediaUrls.length;
    if (count == 0) return '0/0';
    return '${currentImage.value + 1}/$count';
  }

  bool get isLoggedIn => AppStorage.instance.isLoggedIn;

  @override
  void onInit() {
    super.onInit();
    load();
    updateCartBadge();
  }

  Future<void> load() async {
    if (productId == 0 && seckillId == null) return;
    loading.value = true;
    try {
      product.value = seckillId != null
          ? await ProductService.seckillDetail(seckillId!)
          : await ProductService.detail(productId);
      currentImage.value = 0;
      await checkFavorite();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '商品详情加载失败');
    } finally {
      loading.value = false;
    }
  }

  Future<void> checkFavorite() async {
    final value = product.value;
    if (value == null || !isLoggedIn) return;
    try {
      isFavorite.value =
          (await ProductService.checkFavorite(
            value.realProductId,
          ))?.isFavorite ==
          true;
    } catch (_) {}
  }

  Future<void> updateCartBadge() async {
    if (!isLoggedIn) {
      cartCount.value = 0;
      return;
    }
    try {
      final items = await CartService.list();
      cartCount.value = items.fold(0, (sum, item) => sum + item.quantity);
    } catch (_) {}
  }

  Future<void> toggleFavorite() async {
    final value = product.value;
    if (value == null) return;
    if (!_ensureLogin()) return;
    try {
      if (isFavorite.value) {
        await ProductService.removeFavorite(value.realProductId);
      } else {
        await ProductService.addFavorite(value.realProductId);
      }
      isFavorite.toggle();
      EasyLoading.showSuccess(isFavorite.value ? '已收藏' : '已取消收藏');
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '操作失败');
    }
  }

  Future<void> addCart({
    ProductSpecOptionModel? option,
    int quantity = 1,
  }) async {
    final value = product.value;
    if (value == null) return;
    if (!_ensureLogin()) return;
    if (isSeckillProduct(value)) {
      EasyLoading.showToast('秒杀商品请直接购买');
      return;
    }
    final stock = option?.stock ?? value.stock;
    if (stock <= 0 || quantity > stock) {
      EasyLoading.showToast('库存不足');
      return;
    }
    try {
      await CartService.add(value, option: option, quantity: quantity);
      EasyLoading.showSuccess('已加入购物车');
      await updateCartBadge();
      if (Get.isRegistered<MainController>()) {
        await Get.find<MainController>().updateCartBadge();
      }
      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().load();
      }
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '加入购物车失败');
    }
  }

  void buyNow({ProductSpecOptionModel? option, int quantity = 1}) {
    final value = product.value;
    if (value == null) return;
    if (!_ensureLogin()) return;
    if (isWaitingSeckill(value)) {
      EasyLoading.showToast('秒杀活动尚未开始');
      return;
    }
    Get.toNamed(
      AppRoutes.payment,
      arguments: [
        CartItemModel(
          id: option?.skuId ?? value.skuId ?? value.id,
          productId: value.realProductId,
          spuId: value.spuId,
          skuId: option?.skuId ?? value.skuId ?? value.id,
          seckillId: seckillId,
          name: value.name,
          image: option?.image?.isNotEmpty == true
              ? option!.image!
              : value.firstImage,
          price: option?.price ?? value.seckillPrice ?? value.displayPrice,
          unit: option?.unit ?? value.unit,
          spec: option?.label.isNotEmpty == true
              ? option?.label
              : value.unit ?? '默认',
          quantity: quantity,
          stock: option?.stock ?? value.stock,
          selected: true,
          isDirectBuy: true,
        ),
      ],
    );
  }

  void openCart() {
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().switchTo(2);
    }
    Get.offAllNamed(AppRoutes.main);
  }

  Future<void> openCustomerService() async {
    final uri = Uri.parse('tel:07166666889');
    if (!await launchUrl(uri)) {
      EasyLoading.showToast('当前设备无法拨号');
    }
  }

  bool isSeckillProduct(ProductModel value) {
    return seckillId != null || value.routeSeckillId != null;
  }

  bool isWaitingSeckill(ProductModel value) {
    if (!isSeckillProduct(value)) return false;
    final startTime = value.startTime;
    if (startTime == null || startTime.isEmpty) return false;
    final parsed = _parseDate(startTime);
    return parsed != null && DateTime.now().isBefore(parsed);
  }

  bool get isSoldOut => (product.value?.stock ?? 0) <= 0;

  String buyButtonTitle(ProductModel value) {
    if (value.stock <= 0) return '已售罄';
    if (isWaitingSeckill(value)) return '即将开始';
    return '立即购买';
  }

  bool _ensureLogin() {
    if (isLoggedIn) return true;
    Get.toNamed(AppRoutes.login)?.then((_) {
      checkFavorite();
      updateCartBadge();
    });
    return false;
  }

  DateTime? _parseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {}
    try {
      return DateTime.parse(value.replaceFirst(' ', 'T'));
    } catch (_) {}
    return null;
  }
}

import 'package:get/get.dart';

import '../modules/after_sales/after_sale_detail_controller.dart';
import '../modules/after_sales/after_sale_list_controller.dart';
import '../modules/after_sales/refund_controller.dart';
import '../modules/after_sales/review_controller.dart';
import '../modules/address/address_edit_controller.dart';
import '../modules/address/address_list_controller.dart';
import '../modules/cart/cart_controller.dart';
import '../modules/category/category_controller.dart';
import '../modules/home/home_controller.dart';
import '../modules/login/login_controller.dart';
import '../modules/main/main_controller.dart';
import '../modules/marketing/brand_controller.dart';
import '../modules/marketing/coupons_controller.dart';
import '../modules/marketing/favorites_controller.dart';
import '../modules/marketing/member_controller.dart';
import '../modules/message/message_controller.dart';
import '../modules/mine/mine_controller.dart';
import '../modules/order/logistics_controller.dart';
import '../modules/order/order_detail_controller.dart';
import '../modules/order/order_list_controller.dart';
import '../modules/order/payment_controller.dart';
import '../modules/product/product_detail_controller.dart';
import '../modules/product/product_list_controller.dart';
import '../modules/search/search_controller.dart';
import '../modules/support/account_deletion_controller.dart';
import '../modules/support/settings_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    _lazyPut<MainController>(MainController.new, fenix: true);
    _lazyPut<HomeController>(HomeController.new, fenix: true);
    _lazyPut<CategoryController>(CategoryController.new, fenix: true);
    _lazyPut<CartController>(CartController.new, fenix: true);
    _lazyPut<MineController>(MineController.new, fenix: true);
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<HomeController>(HomeController.new, fenix: true);
}

class CategoryBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<CategoryController>(CategoryController.new, fenix: true);
}

class CartBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<CartController>(CartController.new, fenix: true);
}

class MineBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<MineController>(MineController.new, fenix: true);
}

class LoginBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<LoginController>(LoginController.new);
}

class SearchBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<ProductSearchController>(ProductSearchController.new);
}

class ProductListBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<ProductListController>(ProductListController.new);
}

class ProductDetailBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<ProductDetailController>(ProductDetailController.new);
}

class PaymentBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<PaymentController>(PaymentController.new);
}

class OrderListBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<OrderListController>(OrderListController.new);
}

class OrderDetailBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<OrderDetailController>(OrderDetailController.new);
}

class LogisticsBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<LogisticsController>(LogisticsController.new);
}

class AddressListBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<AddressListController>(AddressListController.new);
}

class AddressEditBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<AddressEditController>(AddressEditController.new);
}

class FavoritesBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<FavoritesController>(FavoritesController.new);
}

class CouponsBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<CouponsController>(CouponsController.new);
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<SettingsController>(SettingsController.new);
}

class AccountDeletionBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<AccountDeletionController>(AccountDeletionController.new);
}

class BrandBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<BrandController>(BrandController.new);
}

class MemberBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<MemberController>(MemberController.new);
}

class AfterSaleListBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<AfterSaleListController>(AfterSaleListController.new);
}

class AfterSaleDetailBinding extends Bindings {
  @override
  void dependencies() =>
      _lazyPut<AfterSaleDetailController>(AfterSaleDetailController.new);
}

class RefundBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<RefundController>(RefundController.new);
}

class ReviewBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<ReviewController>(ReviewController.new);
}

class MessageBinding extends Bindings {
  @override
  void dependencies() => _lazyPut<MessageController>(MessageController.new);
}

void _lazyPut<T extends Object>(T Function() builder, {bool fenix = false}) {
  if (!Get.isRegistered<T>()) {
    Get.lazyPut<T>(builder, fenix: fenix);
  }
}

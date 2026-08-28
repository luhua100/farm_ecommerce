import 'package:get/get.dart';

import '../modules/after_sales/after_sale_detail_page.dart';
import '../modules/after_sales/after_sale_list_page.dart';
import '../modules/after_sales/refund_page.dart';
import '../modules/after_sales/review_page.dart';
import '../modules/address/address_edit_page.dart';
import '../modules/address/address_list_page.dart';
import '../modules/cart/cart_page.dart';
import '../modules/category/category_page.dart';
import '../modules/home/home_page.dart';
import '../modules/login/login_page.dart';
import '../modules/main/main_page.dart';
import '../modules/marketing/brand_page.dart';
import '../modules/marketing/coupons_page.dart';
import '../modules/marketing/favorites_page.dart';
import '../modules/marketing/member_page.dart';
import '../modules/message/message_page.dart';
import '../modules/mine/mine_page.dart';
import '../modules/order/logistics_page.dart';
import '../modules/order/order_detail_page.dart';
import '../modules/order/order_list_page.dart';
import '../modules/order/payment_page.dart';
import '../modules/product/product_detail_page.dart';
import '../modules/product/product_list_page.dart';
import '../modules/search/search_page.dart';
import '../modules/splash/splash_page.dart';
import '../modules/support/account_deletion_page.dart';
import '../modules/support/about_page.dart';
import '../modules/support/placeholder_page.dart';
import '../modules/support/settings_page.dart';
import '../modules/support/web_page.dart';
import 'app_bindings.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.category,
      page: () => const CategoryPage(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartPage(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.mine,
      page: () => const MinePage(),
      binding: MineBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchPage(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: AppRoutes.productList,
      page: () => const ProductListPage(),
      binding: ProductListBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailPage(),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.payment,
      page: () => const PaymentPage(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: AppRoutes.orderList,
      page: () => const OrderListPage(),
      binding: OrderListBinding(),
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailPage(),
      binding: OrderDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.reviewCenter,
      page: () => const OrderListPage(),
      binding: OrderListBinding(),
    ),
    GetPage(
      name: AppRoutes.logistics,
      page: () => const LogisticsPage(),
      binding: LogisticsBinding(),
    ),
    GetPage(
      name: AppRoutes.address,
      page: () => const AddressListPage(),
      binding: AddressListBinding(),
    ),
    GetPage(
      name: AppRoutes.addressEdit,
      page: () => const AddressEditPage(),
      binding: AddressEditBinding(),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesPage(),
      binding: FavoritesBinding(),
    ),
    GetPage(
      name: AppRoutes.coupons,
      page: () => const CouponsPage(),
      binding: CouponsBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.accountDeletion,
      page: () => const AccountDeletionPage(),
      binding: AccountDeletionBinding(),
    ),
    GetPage(name: AppRoutes.about, page: () => const AboutPage()),
    GetPage(
      name: AppRoutes.brand,
      page: () => const BrandPage(),
      binding: BrandBinding(),
    ),
    GetPage(
      name: AppRoutes.member,
      page: () => const MemberPage(),
      binding: MemberBinding(),
    ),
    GetPage(
      name: AppRoutes.afterSales,
      page: () => const AfterSaleListPage(),
      binding: AfterSaleListBinding(),
    ),
    GetPage(
      name: AppRoutes.afterSaleDetail,
      page: () => const AfterSaleDetailPage(),
      binding: AfterSaleDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.refund,
      page: () => const RefundPage(),
      binding: RefundBinding(),
    ),
    GetPage(
      name: AppRoutes.review,
      page: () => const ReviewPage(),
      binding: ReviewBinding(),
    ),
    GetPage(
      name: AppRoutes.message,
      page: () => const MessagePage(),
      binding: MessageBinding(),
    ),
    GetPage(
      name: AppRoutes.seckill,
      page: () => const ProductListPage(),
      binding: ProductListBinding(),
    ),
    GetPage(
      name: AppRoutes.webView,
      page: () => WebPage(url: Get.parameters['url'] ?? ''),
    ),
    ..._placeholders,
  ];

  static final _placeholders = <GetPage>[
    _placeholder(AppRoutes.history, '浏览历史'),
  ];

  static GetPage _placeholder(String route, String title) {
    return GetPage(
      name: route,
      page: () => PlaceholderPage(title: title),
    );
  }
}

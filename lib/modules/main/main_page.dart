import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_asset_icon.dart';
import '../cart/cart_page.dart';
import '../category/category_page.dart';
import '../home/home_page.dart';
import '../mine/mine_page.dart';
import 'main_controller.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  static const _pages = [HomePage(), CategoryPage(), CartPage(), MinePage()];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: List.generate(
            _pages.length,
            (index) => controller.loadedTabs.contains(index)
                ? _pages[index]
                : const SizedBox.shrink(),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.switchTo,
          items: [
            const BottomNavigationBarItem(
              icon: AppAssetIcon('tabbar_home'),
              activeIcon: AppAssetIcon('tabbar_home_active'),
              label: '首页',
            ),
            const BottomNavigationBarItem(
              icon: AppAssetIcon('tabbar_category'),
              activeIcon: AppAssetIcon('tabbar_category_active'),
              label: '分类',
            ),
            BottomNavigationBarItem(
              icon: _TabIconWithBadge(
                asset: 'tabbar_cart',
                count: controller.cartCount.value,
              ),
              activeIcon: _TabIconWithBadge(
                asset: 'tabbar_cart_active',
                count: controller.cartCount.value,
              ),
              label: '购物车',
            ),
            const BottomNavigationBarItem(
              icon: AppAssetIcon('tabbar_mine'),
              activeIcon: AppAssetIcon('tabbar_mine_active'),
              label: '我的',
            ),
          ],
        ),
        backgroundColor: AppColors.background,
      ),
    );
  }
}

class _TabIconWithBadge extends StatelessWidget {
  const _TabIconWithBadge({required this.asset, required this.count});

  final String asset;
  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Badge(
      isLabelVisible: count > 0,
      label: Text(label),
      child: AppAssetIcon(asset),
    );
  }
}

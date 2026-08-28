import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/price_text.dart';
import 'cart_controller.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('购物车')),
      body: Obx(() {
        if (!controller.loggedIn.value) {
          return _LoginState(onLogin: controller.openLogin);
        }
        if (controller.loading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.items.isEmpty) {
          return _EmptyCart(onGoShopping: controller.goShopping);
        }
        return Column(
          children: [
            _SelectBar(controller: controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.load,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 12),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 0),
                  itemBuilder: (_, index) {
                    final item = controller.items[index];
                    return _CartItem(item: item, controller: controller);
                  },
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        if (!controller.loggedIn.value || controller.items.isEmpty) {
          return const SizedBox.shrink();
        }
        return SafeArea(
          child: Container(
            height: 72,
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  '合计：',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                PriceText(controller.total.toStringAsFixed(2), fontSize: 18),
                const Spacer(),
                FilledButton(
                  onPressed: controller.selectedCount > 0
                      ? controller.checkout
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    minimumSize: const Size(112, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('去结算'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _LoginState extends StatelessWidget {
  const _LoginState({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 12),
            const Text(
              '登录后查看购物车',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onLogin,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('去登录'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onGoShopping});

  final VoidCallback onGoShopping;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const EmptyState(title: '购物车空空如也'),
        Align(
          alignment: const Alignment(0, 0.35),
          child: FilledButton(
            onPressed: onGoShopping,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(140, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('去逛逛'),
          ),
        ),
      ],
    );
  }
}

class _SelectBar extends StatelessWidget {
  const _SelectBar({required this.controller});

  final CartController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 0.5),
      ),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: controller.selectAll,
            icon: Icon(
              controller.allSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: AppColors.primary,
            ),
            label: const Text('全选'),
          ),
          const SizedBox(width: 8),
          Text(
            '已选 ${controller.selectedCount} 件',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({required this.item, required this.controller});

  final CartItemModel item;
  final CartController controller;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.cartId ?? item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await controller.confirmDelete(item);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: AppColors.price,
        child: const Text('删除', style: TextStyle(color: Colors.white)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => controller.toggle(item),
              icon: Icon(
                item.selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: AppColors.primary,
              ),
              tooltip: '选择',
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppNetworkImage(item.image, width: 84, height: 84),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => Get.toNamed(
                  AppRoutes.productDetail,
                  parameters: {'id': '${item.displayProductId}'},
                ),
                child: SizedBox(
                  height: 95,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.22,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => controller.confirmDelete(item),
                            icon: const Icon(Icons.delete_outline, size: 19),
                            color: AppColors.textTertiary,
                            tooltip: '删除',
                            constraints: const BoxConstraints.tightFor(
                              width: 30,
                              height: 30,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      if (item.displaySpec.isNotEmpty)
                        Text(
                          item.displaySpec,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(child: PriceText(item.price, fontSize: 18)),
                          _Stepper(
                            value: item.quantity,
                            onMinus: item.quantity <= 1
                                ? null
                                : () => controller.step(item, -1),
                            onPlus: () => controller.step(item, 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.separator),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove, size: 15),
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add, size: 15),
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

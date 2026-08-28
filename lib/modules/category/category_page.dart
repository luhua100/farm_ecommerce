import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/product_card.dart';
import 'category_controller.dart';

class CategoryPage extends GetView<CategoryController> {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分类')),
      body: Obx(() {
        if (controller.loading.value && controller.categories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.categories.isEmpty) {
          return EmptyState(title: '暂无商品分类', onRetry: controller.load);
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _SearchButton(onTap: controller.openSearch),
            ),
            Expanded(
              child: Row(
                children: [
                  _CategoryList(controller: controller),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            controller.currentCategory?.name ?? '全部商品',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: controller.products.isEmpty
                              ? EmptyState(
                                  title: '该分类暂无商品',
                                  onRetry: controller.openSearch,
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    16,
                                  ),
                                  itemCount: controller.products.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 0.54,
                                      ),
                                  itemBuilder: (_, index) {
                                    final product = controller.products[index];
                                    return ProductCard(
                                      product: product,
                                      onTap: () =>
                                          controller.openProduct(product),
                                      onAddCart: () =>
                                          controller.addCart(product),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          height: 42,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text('搜索商品', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.controller});

  final CategoryController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      color: const Color(0xFFEEF2F0),
      child: ListView.builder(
        itemCount: controller.categories.length,
        itemBuilder: (_, index) {
          final category = controller.categories[index];
          final selected = index == controller.selectedIndex.value;
          return InkWell(
            onTap: () => controller.select(index),
            child: Container(
              constraints: const BoxConstraints(minHeight: 54),
              alignment: Alignment.center,
              color: selected ? AppColors.background : const Color(0xFFEEF2F0),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.18,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/product_card.dart';
import 'favorites_controller.dart';

class FavoritesPage extends GetView<FavoritesController> {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的收藏')),
      body: Obx(() {
        if (controller.loading.value && controller.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.products.isEmpty) {
          return EmptyState(title: '暂无收藏商品', onRetry: controller.load);
        }
        return RefreshIndicator(
          onRefresh: controller.load,
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.58,
            ),
            itemBuilder: (_, index) {
              final product = controller.products[index];
              return ProductCard(
                product: product,
                onTap: () => controller.openProduct(product),
                onAddCart: () => controller.addCart(product),
              );
            },
          ),
        );
      }),
    );
  }
}

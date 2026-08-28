import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/product_card.dart';
import 'search_controller.dart';

class SearchPage extends GetView<ProductSearchController> {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: controller.input,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: controller.search,
          decoration: const InputDecoration(
            hintText: '搜索新鲜农品',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.search(),
            child: const Text('搜索'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.searching.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.results.isNotEmpty) {
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.results.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.58,
            ),
            itemBuilder: (_, index) {
              final product = controller.results[index];
              return ProductCard(
                product: product,
                onTap: () => controller.openProduct(product),
                onAddCart: () {},
              );
            },
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Tags(
              title: '热门搜索',
              values: controller.hotKeywords,
              loading: controller.hotLoading.value,
              onTap: controller.search,
              onRetry: controller.loadHot,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  '搜索历史',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  onPressed: controller.clearHistory,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '清空历史',
                ),
              ],
            ),
            if (controller.history.isEmpty)
              const EmptyState(title: '暂无搜索历史')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.history
                    .map(
                      (item) => ActionChip(
                        label: Text(item),
                        onPressed: () => controller.search(item),
                      ),
                    )
                    .toList(),
              ),
          ],
        );
      }),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({
    required this.title,
    required this.values,
    required this.onTap,
    required this.onRetry,
    this.loading = false,
  });

  final String title;
  final List<String> values;
  final ValueChanged<String> onTap;
  final VoidCallback onRetry;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        if (loading)
          const SizedBox(
            height: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (values.isEmpty)
          OutlinedButton(onPressed: onRetry, child: const Text('重新加载'))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values
                .map(
                  (item) => ActionChip(
                    label: Text(item),
                    backgroundColor: AppColors.surface,
                    onPressed: () => onTap(item),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

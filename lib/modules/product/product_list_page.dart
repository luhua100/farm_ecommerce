import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/price_text.dart';
import '../../shared/widgets/product_card.dart';
import 'product_list_controller.dart';

class ProductListPage extends GetView<ProductListController> {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(controller.pageTitle)),
      body: Stack(
        children: [
          Column(
            children: [
              if (controller.isSeckillMode)
                _SessionBar(controller: controller)
              else
                _SortBar(controller: controller),
              _ResultLabel(controller: controller),
              Expanded(
                child: Obx(() {
                  if (controller.loading.value && controller.products.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.products.isEmpty) {
                    return EmptyState(
                      title: controller.isSeckillMode ? '暂无秒杀商品' : '暂无商品',
                      onRetry: controller.isSeckillMode
                          ? controller.loadSeckillData
                          : controller.load,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: controller.isSeckillMode
                        ? controller.loadSeckillData
                        : controller.load,
                    child: controller.isSeckillMode
                        ? ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.products.length,
                            itemBuilder: (_, index) {
                              final product = controller.products[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Obx(
                                  () => _SeckillProductCard(
                                    product: product,
                                    countdown: controller.countdownText(
                                      product,
                                    ),
                                    onTap: () =>
                                        controller.handleSeckillAction(product),
                                  ),
                                ),
                              );
                            },
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
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
              ),
            ],
          ),
          if (!controller.isSeckillMode) _FilterOverlay(controller: controller),
        ],
      ),
    );
  }
}

class _SessionBar extends StatelessWidget {
  const _SessionBar({required this.controller});

  final ProductListController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.sessions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, index) {
            final session = controller.sessions[index];
            final active = controller.currentSessionIndex.value == index;
            return GestureDetector(
              onTap: () => controller.selectSession(index),
              child: Container(
                width: 86,
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      session.time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active ? AppColors.primary : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session.displayStatusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active
                            ? AppColors.primary
                            : Colors.white.withValues(alpha: 0.82),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  const _SortBar({required this.controller});

  final ProductListController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Row(
        children: [
          _SortButton('综合', 'default', controller),
          _SortButton('销量', 'sales', controller),
          _PriceSortButton(controller: controller),
          _FilterButton(controller: controller),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.controller});

  final ProductListController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 48,
      child: TextButton.icon(
        onPressed: controller.showFilterPanel,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: AppColors.textSecondary,
        ),
        icon: const Icon(Icons.tune, size: 16),
        label: const Text('筛选', style: TextStyle(fontSize: 13)),
      ),
    );
  }
}

class _ResultLabel extends StatelessWidget {
  const _ResultLabel({required this.controller});

  final ProductListController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => Text(
          controller.products.isEmpty
              ? (controller.isSeckillMode ? '暂无秒杀商品' : '暂无商品')
              : '共 ${controller.products.length} 件商品',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton(this.text, this.value, this.controller);

  final String text;
  final String value;
  final ProductListController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final selected = controller.sort.value == value;
        return TextButton(
          onPressed: () => controller.setSort(value),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        );
      }),
    );
  }
}

class _PriceSortButton extends StatelessWidget {
  const _PriceSortButton({required this.controller});

  final ProductListController controller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        final value = controller.sort.value;
        final selected = value == 'priceAsc' || value == 'priceDesc';
        final arrow = value == 'priceAsc'
            ? Icons.arrow_upward
            : value == 'priceDesc'
            ? Icons.arrow_downward
            : Icons.unfold_more;
        return TextButton.icon(
          onPressed: controller.togglePriceSort,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: selected
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
          label: Text(
            '价格',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          icon: Icon(arrow, size: 15),
        );
      }),
    );
  }
}

class _FilterOverlay extends StatelessWidget {
  const _FilterOverlay({required this.controller});

  final ProductListController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.filterVisible.value) return const SizedBox.shrink();
      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: controller.hideFilterPanel,
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.5)),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _FilterPanel(controller: controller),
          ),
        ],
      );
    });
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.controller});

  final ProductListController controller;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.8;
    return Material(
      color: Colors.white,
      child: SizedBox(
        width: width,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 58,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Text(
                      '筛选',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: controller.hideFilterPanel,
                      icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                      tooltip: '关闭',
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
              const Divider(height: 0.5, color: Color(0xFFEDF2F7)),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  '价格区间',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _PriceField(
                        controller: controller.minPriceController,
                        hintText: '最低价',
                      ),
                    ),
                    const SizedBox(
                      width: 26,
                      child: Center(
                        child: Text(
                          '-',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _PriceField(
                        controller: controller.maxPriceController,
                        hintText: '最高价',
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Divider(height: 0.5, color: Color(0xFFEDF2F7)),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilledButton(
                          onPressed: controller.resetFilter,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF5F7F4),
                            foregroundColor: AppColors.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('重置'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: FilledButton(
                          onPressed: controller.confirmFilter,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('确定'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF111827), fontSize: 13),
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEDF2F7), width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEDF2F7), width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 0.8),
          ),
        ),
      ),
    );
  }
}

class _SeckillProductCard extends StatelessWidget {
  const _SeckillProductCard({
    required this.product,
    required this.countdown,
    required this.onTap,
  });

  final ProductModel product;
  final String countdown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final waiting = product.status == 'waiting';
    final progress = ((product.progress ?? 0).clamp(0, 100)) / 100.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: SizedBox(
                width: 108,
                height: double.infinity,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: AppNetworkImage(
                        product.firstImage,
                        width: 120,
                        height: 120,
                      ),
                    ),
                    Positioned(
                      left: 6,
                      top: 6,
                      child: Container(
                        height: 22,
                        constraints: const BoxConstraints(minWidth: 58),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color:
                              (waiting
                                      ? const Color(0xFFF59E0B)
                                      : AppColors.primary)
                                  .withValues(alpha: waiting ? 0.92 : 0.94),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Text(
                          waiting ? '即将开始' : '抢购中',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 62,
                        height: 28,
                        child: FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            backgroundColor: waiting
                                ? const Color(0xFFF59E0B)
                                : AppColors.primary,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            waiting ? '提醒我' : '去抢购',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 5),
                  Container(
                    height: 28,
                    width: 140,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFEFF),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      countdown,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      PriceText(
                        product.seckillPrice ?? product.displayPrice,
                        fontSize: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '¥${product.displayOriginalPrice ?? product.displayPrice}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    alignment: AlignmentGeometry.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          minHeight: 16,
                          value: progress,
                          backgroundColor: const Color(0xFFEDF6EF),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        '已抢${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: Color(0xFF17613F),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

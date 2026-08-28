import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/price_text.dart';
import '../../shared/widgets/product_card.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _SearchButton(onTap: () => Get.toNamed(AppRoutes.search)),
              const SizedBox(height: AppSpacing.md),
              _HeroCard(
                categoryCount: controller.categories.length,
                productCount: controller.products.length,
              ),
              if (controller.banners.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _BannerPager(
                  banners: controller.banners,
                  currentIndex: controller.bannerIndex.value,
                  onChanged: (index) => controller.bannerIndex.value = index,
                  onTap: controller.openBanner,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              _CategoryStrip(
                categories: controller.categories,
                onBrand: controller.openBrand,
                onCategory: controller.openCategory,
              ),
              if (controller.seckillProducts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _SectionTitle(
                  title: '限时秒杀',
                  subtitle: '超值优惠',
                  actionText: '更多',
                  onAction: controller.openSeckill,
                ),
                const SizedBox(height: AppSpacing.sm),
                _SeckillList(
                  products: controller.seckillProducts,
                  onTap: controller.openProduct,
                ),
              ],
              if (controller.hotProducts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _SectionTitle(title: '爆品推荐', subtitle: '近期更受欢迎'),
                const SizedBox(height: AppSpacing.sm),
                _HorizontalProductStrip(
                  products: controller.hotProducts,
                  onTap: controller.openProduct,
                ),
              ],
              if (controller.newProducts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _SectionTitle(title: '新品上架', subtitle: '新鲜好物上新'),
                const SizedBox(height: AppSpacing.sm),
                _HorizontalProductStrip(
                  products: controller.newProducts,
                  onTap: controller.openProduct,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              const _SectionTitle(title: '为你推荐'),
              const SizedBox(height: AppSpacing.sm),
              if (controller.loading.value && controller.products.isEmpty)
                const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _RecommendGrid(controller: controller),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
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
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text(
                  '搜索农产品',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.categoryCount, required this.productCount});

  final int categoryCount;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '自家好物',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '新鲜农品，放心到家',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '自家直卖 · 时令新鲜 · 初级农产品',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 38,
            child: Row(
              children: [
                _HeroStat(value: '$categoryCount', label: '分类'),
                _HeroStat(value: '$productCount', label: '农品'),
                const _HeroStat(value: '72h', label: '服务'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerPager extends StatelessWidget {
  const _BannerPager({
    required this.banners,
    required this.currentIndex,
    required this.onChanged,
    required this.onTap,
  });

  final List<BannerModel> banners;
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final ValueChanged<BannerModel> onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 180,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CarouselSlider.builder(
              itemCount: banners.length,
              itemBuilder: (_, index, __) {
                final banner = banners[index];
                return GestureDetector(
                  onTap: () => onTap(banner),
                  child: SizedBox.expand(child: AppNetworkImage(banner.image)),
                );
              },
              options: CarouselOptions(
                height: 180,
                viewportFraction: 1,
                autoPlay: banners.length > 1,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 260),
                enableInfiniteScroll: banners.length > 1,
                enlargeCenterPage: false,
                padEnds: false,
                onPageChanged: (index, _) => onChanged(index),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(banners.length, (index) {
                  final selected = currentIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 14 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categories,
    required this.onBrand,
    required this.onCategory,
  });

  final List<CategoryModel> categories;
  final VoidCallback onBrand;
  final ValueChanged<CategoryModel> onCategory;

  @override
  Widget build(BuildContext context) {
    final items = categories
        .where((category) => category.type != 'brand')
        .take(4);
    return SizedBox(
      height: 80,
      child: Row(
        children: [
          _CategoryEntry.brand(onTap: onBrand),
          const SizedBox(width: AppSpacing.xs),
          ...items.expand(
            (category) => [
              _CategoryEntry(
                category: category,
                onTap: () => onCategory(category),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _CategoryEntry extends StatelessWidget {
  const _CategoryEntry({required this.category, required this.onTap})
    : isBrand = false;

  const _CategoryEntry.brand({required this.onTap})
    : category = null,
      isBrand = true;

  final CategoryModel? category;
  final VoidCallback onTap;
  final bool isBrand;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isBrand
                    ? const Color(0xFF173D2B)
                    : const Color(0xFFEDF6EF),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: isBrand
                  ? const Icon(
                      Icons.workspace_premium,
                      color: Colors.white,
                      size: 22,
                    )
                  : AppNetworkImage(category?.image),
            ),
            const SizedBox(height: 6),
            Text(
              isBrand ? '品牌馆' : category?.name ?? '',
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                height: 1.12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const Spacer(),
          if (actionText != null)
            TextButton(onPressed: onAction, child: Text(actionText!)),
        ],
      ),
    );
  }
}

class _SeckillList extends StatelessWidget {
  const _SeckillList({required this.products, required this.onTap});

  final List<ProductModel> products;
  final ValueChanged<ProductModel> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: products
          .map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SeckillCard(
                product: product,
                onTap: () => onTap(product),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SeckillCard extends StatelessWidget {
  const _SeckillCard({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final waiting = product.status == 'waiting';
    final progress = ((product.progress ?? 0).clamp(0, 100)) / 100.0;
    return Material(
      color: const Color(0xFFF7FAF5),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 146,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xFFE2EADF), width: 0.5),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: AppNetworkImage(
                      product.firstImage,
                      width: 128,
                      height: 128,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      height: 20,
                      constraints: const BoxConstraints(minWidth: 56),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: BoxDecoration(
                        color: waiting
                            ? const Color(0xFFC17023).withValues(alpha: 0.94)
                            : AppColors.primary.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        waiting ? '即将开始' : '抢购中',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 9),
              Expanded(
                child: StreamBuilder<int>(
                  stream: Stream.periodic(
                    const Duration(seconds: 1),
                    (value) => value,
                  ),
                  builder: (context, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF18211B),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1.22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              height: 28,
                              constraints: const BoxConstraints(minWidth: 56),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                waiting ? '提醒我' : '去抢购',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 24,
                          width: 120,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF6EF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _countdownText(product),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            PriceText(product.displayPrice, fontSize: 18),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                '¥${product.displayOriginalPrice ?? product.displayPrice}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF8B9A8B),
                                  fontSize: 11,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Stack(
                            children: [
                              Container(
                                height: 24,
                                color: const Color(0xFFEDF6EF),
                              ),
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  height: 14,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(
                                height: 24,
                                child: Center(
                                  child: Text(
                                    '已抢${(progress * 100).round()}%',
                                    style: const TextStyle(
                                      color: Color(0xFF17613F),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalProductStrip extends StatelessWidget {
  const _HorizontalProductStrip({required this.products, required this.onTap});

  final List<ProductModel> products;
  final ValueChanged<ProductModel> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 182,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) {
          final product = products[index];
          return _SmallProductCard(
            product: product,
            onTap: () => onTap(product),
          );
        },
      ),
    );
  }
}

class _SmallProductCard extends StatelessWidget {
  const _SmallProductCard({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 138,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImage(product.firstImage, width: 138, height: 96),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.22,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text(
                  product.displaySubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.22,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: PriceText(product.displayPrice, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendGrid extends StatelessWidget {
  const _RecommendGrid({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.products.isEmpty) {
      return const SizedBox(height: 1);
    }
    return GridView.builder(
      itemCount: controller.products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.64,
      ),
      itemBuilder: (_, index) {
        final product = controller.products[index];
        return ProductCard(
          product: product,
          onTap: () => controller.openProduct(product),
          onAddCart: () => controller.addCart(product),
        );
      },
    );
  }
}

String _countdownText(ProductModel product) {
  final now = DateTime.now();
  final start = _parseDate(product.startTime);
  final end = _parseDate(product.endTime);
  if (start != null && now.isBefore(start)) {
    return '距开始 ${_formatInterval(start.difference(now))}';
  }
  if (end != null && now.isBefore(end)) {
    return '距结束 ${_formatInterval(end.difference(now))}';
  }
  return product.status == 'waiting' ? '即将开始' : '抢购中';
}

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final text = value.trim();
  return DateTime.tryParse(text) ??
      DateTime.tryParse(text.replaceFirst(' ', 'T'));
}

String _formatInterval(Duration duration) {
  final seconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
  final days = seconds ~/ 86400;
  final hours = (seconds % 86400) ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final secs = seconds % 60;
  final time =
      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  return days > 0 ? '$days天 $time' : time;
}

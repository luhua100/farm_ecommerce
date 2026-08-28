import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_state.dart';
import 'brand_controller.dart';

class BrandPage extends GetView<BrandController> {
  const BrandPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F4),
      appBar: AppBar(title: const Text('品牌优选')),
      body: Obx(() {
        if (controller.loading.value && controller.brands.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            children: [
              _HeroCard(controller: controller),
              if (controller.banners.isNotEmpty) ...[
                const SizedBox(height: 11),
                _BannerPager(controller: controller),
              ],
              const SizedBox(height: 12),
              _CategoryTabs(controller: controller),
              const SizedBox(height: 0),
              _BrandSection(controller: controller),
            ],
          ),
        );
      }),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.controller});

  final BrandController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 177,
      padding: const EdgeInsets.fromLTRB(15, 17, 15, 13),
      decoration: BoxDecoration(
        color: const Color(0xFF173D2B),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173D2B).withValues(alpha: 0.16),
            blurRadius: 19,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '农品优选',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '按品类挑好品牌',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '按品类选购自家与本地初级农产品',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 13),
          Divider(height: 0.5, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  value: '${controller.brands.length}',
                  title: '品牌/品种',
                ),
              ),
              Expanded(
                child: _HeroStat(
                  value: '${(controller.categories.length - 1).clamp(0, 999)}',
                  title: '农品分类',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.title});

  final String value;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _BannerPager extends StatelessWidget {
  const _BannerPager({required this.controller});

  final BrandController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 121,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            CarouselSlider.builder(
              itemCount: controller.banners.length,
              itemBuilder: (_, index, __) =>
                  AppNetworkImage(controller.banners[index].image),
              options: CarouselOptions(
                height: 121,
                viewportFraction: 1,
                autoPlay: controller.banners.length > 1,
                autoPlayInterval: const Duration(seconds: 3),
                onPageChanged: (index, _) =>
                    controller.bannerIndex.value = index,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 6,
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.banners.length,
                    (index) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == controller.bannerIndex.value
                            ? AppColors.primary
                            : Colors.white,
                      ),
                    ),
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

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.controller});

  final BrandController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 7),
          itemBuilder: (_, index) {
            final selected = controller.selectedCategory.value == index;
            return GestureDetector(
              onTap: () => controller.selectCategory(index),
              child: Container(
                height: 31,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : const Color(0xFFE4EADF),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  controller.categories[index],
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF66736A),
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  const _BrandSection({required this.controller});

  final BrandController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4EADF), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '农品优选',
                      style: TextStyle(
                        color: Color(0xFF18211B),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '例如食用油里的金龙鱼、茶叶里的毛尖',
                      style: TextStyle(color: Color(0xFF8B9A8B), fontSize: 11),
                    ),
                  ],
                ),
              ),
              _SortControl(controller: controller),
            ],
          ),
          const SizedBox(height: 11),
          Obx(() {
            final brands = controller.visibleBrands;
            if (brands.isEmpty) {
              return SizedBox(
                height: 110,
                child: EmptyState(title: '暂无农品', onRetry: controller.loadData),
              );
            }
            return Column(
              children: brands
                  .map(
                    (brand) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _BrandCard(controller: controller, brand: brand),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _SortControl extends StatelessWidget {
  const _SortControl({required this.controller});

  final BrandController controller;

  @override
  Widget build(BuildContext context) {
    const items = [
      (BrandSortType.defaultSort, '综合'),
      (BrandSortType.products, '商品数'),
      (BrandSortType.name, '名称'),
    ];
    return Container(
      width: 132,
      height: 30,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Obx(
        () => Row(
          children: items.map((item) {
            final selected = controller.sortType.value == item.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectSort(item.$1),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    item.$2,
                    style: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFF66736A),
                      fontSize: 11.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({required this.controller, required this.brand});

  final BrandController controller;
  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE4EADF), width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => controller.openBrand(brand),
            child: SizedBox(
              height: 66,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                child: Row(
                  children: [
                    _BrandLogo(brand: brand),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  brand.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF18211B),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                height: 20,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDF6EF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  brand.displayCategory,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            brand.description ?? '${brand.displayCategory}优选',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF8B9A8B),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (brand.products.isNotEmpty)
            SizedBox(
              height: 126,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
                itemCount: brand.products.take(3).length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final product = brand.products[index];
                  return _BrandProduct(
                    product: product,
                    onTap: () => controller.openProduct(product),
                  );
                },
              ),
            ),
          InkWell(
            onTap: () => controller.openBrand(brand),
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFEDF2E9), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${brand.productCount}件关联商品',
                    style: const TextStyle(
                      color: Color(0xFF8B9A8B),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '查看商品 ›',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.brand});

  final BrandModel brand;

  @override
  Widget build(BuildContext context) {
    final logo = brand.logo ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(7),
      child: SizedBox(
        width: 44,
        height: 44,
        child: logo.isEmpty
            ? ColoredBox(
                color: const Color(0xFF173D2B),
                child: Center(
                  child: Text(
                    brand.name.isEmpty
                        ? '品'
                        : String.fromCharCode(brand.name.runes.first),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            : AppNetworkImage(logo, fit: BoxFit.contain),
      ),
    );
  }
}

class _BrandProduct extends StatelessWidget {
  const _BrandProduct({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AppNetworkImage(product.firstImage, width: 82, height: 66),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF3C4A3F),
                fontSize: 11,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '¥${product.displayPrice}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

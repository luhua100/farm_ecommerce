import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/price_text.dart';
import 'product_detail_controller.dart';

class ProductDetailPage extends GetView<ProductDetailController> {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('商品详情')),
      body: Obx(() {
        final product = controller.product.value;
        if (controller.loading.value && product == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (product == null) {
          return EmptyState(title: '商品不存在', onRetry: controller.load);
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _MediaPager(controller: controller),
            const SizedBox(height: 16),
            _InfoCard(product: product),
            const SizedBox(height: 16),
            _AttrsCard(product: product),
            const SizedBox(height: 16),
            _DescriptionCard(product: product),
            const SizedBox(height: 16),
            _ReviewCard(product: product),
            const SizedBox(height: 18),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final product = controller.product.value;
        if (product == null) return const SizedBox.shrink();
        return _BottomBar(controller: controller, product: product);
      }),
    );
  }
}

class _MediaPager extends StatelessWidget {
  const _MediaPager({required this.controller});

  final ProductDetailController controller;

  @override
  Widget build(BuildContext context) {
    final urls = controller.mediaUrls;
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            if (urls.isEmpty)
              const AppNetworkImage('')
            else
              CarouselSlider.builder(
                itemCount: urls.length,
                itemBuilder: (_, index, __) => AppNetworkImage(urls[index]),
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, _) =>
                      controller.currentImage.value = index,
                ),
              ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Obx(
                () => Container(
                  width: 48,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.imageCounterText,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      product.origin,
      product.brandName,
      product.unit,
      if (product.displayOriginalPrice != null &&
          product.displayOriginalPrice != product.displayPrice)
        '原价 ¥${product.displayOriginalPrice}',
    ].whereType<String>().where((item) => item.isNotEmpty).join(' · ');
    return _ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PriceText(product.displayPrice, fontSize: 24),
              if (product.unit?.isNotEmpty == true) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    product.unit!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          if (product.displayTags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.displayTags
                  .take(4)
                  .map((tag) => _TagChip(text: tag))
                  .toList(),
            ),
          ],
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '已售 ${product.sales}   库存 ${product.stock}',
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

class _AttrsCard extends StatelessWidget {
  const _AttrsCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final attrs = <(String, String)>[
      ('产地', product.origin ?? ''),
      if (product.brandName?.isNotEmpty == true) ('品牌', product.brandName!),
      ('保质期', product.shelfLifeDays == null ? '' : '${product.shelfLifeDays}天'),
    ];
    return _ContentCard(
      child: SizedBox(
        height: 76,
        child: Row(
          children: attrs
              .map(
                (item) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.$1}\n${item.$2}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final blocks = (product.description ?? '')
        .split(RegExp(r'\r?\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    return _ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('商品描述'),
          const SizedBox(height: 10),
          if (blocks.isEmpty)
            const Text(
              '暂无商品描述',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            )
          else
            ...blocks.map((block) {
              final lower = block.toLowerCase();
              if (lower.startsWith('http://') || lower.startsWith('https://')) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppNetworkImage(block, fit: BoxFit.fitWidth),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  block,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final review = product.reviews.isEmpty ? null : product.reviews.first;
    return _ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle('商品评价 (${product.reviews.length})'),
          const SizedBox(height: 10),
          if (review == null)
            const Text(
              '暂无评价',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            )
          else
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 72),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${review.user ?? '匿名用户'}  ${List.filled(review.rating <= 0 ? 1 : review.rating, '★').join()}\n${review.content ?? ''}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller, required this.product});

  final ProductDetailController controller;
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final soldOut = product.stock <= 0;
    final isSeckill = controller.isSeckillProduct(product);
    final waitingSeckill = controller.isWaitingSeckill(product);
    final buyDisabled = soldOut || waitingSeckill;
    return SafeArea(
      top: false,
      child: Container(
        height: 88,
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 18),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.separator)),
        ),
        child: Row(
          children: [
            _BottomIcon(
              label: '客服',
              asset: 'assets/images/detail_chat.png',
              onTap: controller.openCustomerService,
            ),
            _CartIcon(controller: controller),
            Obx(
              () => _BottomIcon(
                label: '收藏',
                asset: controller.isFavorite.value
                    ? 'assets/images/care_selected.png'
                    : 'assets/images/care_normal.png',
                onTap: controller.toggleFavorite,
              ),
            ),
            const SizedBox(width: 8),
            if (!isSeckill) ...[
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: soldOut
                        ? null
                        : () => _showSpecSheet(
                            context,
                            product: product,
                            confirmTitle: '加入购物车',
                            onConfirm: (option, quantity) => controller.addCart(
                              option: option,
                              quantity: quantity,
                            ),
                          ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE9F8F5),
                      foregroundColor: const Color(0xFF0F9F89),
                      disabledBackgroundColor: const Color(0xFFE5E7EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Color(0xFFC8EDE6),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Text(soldOut ? '已售罄' : '加入购物车'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: buyDisabled
                      ? null
                      : () => _showSpecSheet(
                          context,
                          product: product,
                          confirmTitle: '立即购买',
                          onConfirm: (option, quantity) => controller.buyNow(
                            option: option,
                            quantity: quantity,
                          ),
                        ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(controller.buyButtonTitle(product)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomIcon extends StatelessWidget {
  const _BottomIcon({
    required this.label,
    required this.asset,
    required this.onTap,
    this.badge,
  });

  final String label;
  final String asset;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(asset, width: 22, height: 22),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 0,
                right: 2,
                child: Container(
                  height: 16,
                  constraints: const BoxConstraints(minWidth: 16),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.price,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(color: Colors.white, fontSize: 9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.controller});

  final ProductDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.cartCount.value;
      return _BottomIcon(
        label: '购物车',
        asset: 'assets/images/detail_cart.png',
        onTap: controller.openCart,
        badge: count <= 0 ? null : (count > 99 ? '99+' : '$count'),
      );
    });
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 0.5),
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

Future<void> _showSpecSheet(
  BuildContext context, {
  required ProductModel product,
  required String confirmTitle,
  required FutureOrVoidSpecCallback onConfirm,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _SpecSheet(
      product: product,
      confirmTitle: confirmTitle,
      onConfirm: onConfirm,
    ),
  );
}

typedef FutureOrVoidSpecCallback =
    void Function(ProductSpecOptionModel? option, int quantity);

class _SpecSheet extends StatefulWidget {
  const _SpecSheet({
    required this.product,
    required this.confirmTitle,
    required this.onConfirm,
  });

  final ProductModel product;
  final String confirmTitle;
  final FutureOrVoidSpecCallback onConfirm;

  @override
  State<_SpecSheet> createState() => _SpecSheetState();
}

class _SpecSheetState extends State<_SpecSheet> {
  ProductSpecOptionModel? selected;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    selected = widget.product.specs.isEmpty ? null : widget.product.specs.first;
  }

  @override
  Widget build(BuildContext context) {
    final image = selected?.image?.isNotEmpty == true
        ? selected!.image!
        : widget.product.firstImage;
    final price = widget.product.seckillPrice?.isNotEmpty == true
        ? widget.product.seckillPrice!
        : selected?.price ?? widget.product.displayPrice;
    final stock = selected?.stock ?? widget.product.stock;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AppNetworkImage(image, width: 82, height: 82),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      PriceText(price, fontSize: 20),
                      const SizedBox(height: 4),
                      Text(
                        '库存 $stock',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.product.specs.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                '规格',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.product.specs.map((spec) {
                  final checked = selected == spec;
                  return ChoiceChip(
                    label: Text(spec.label),
                    selected: checked,
                    onSelected: (_) => setState(() {
                      selected = spec;
                      quantity = _clampQuantity(quantity, spec.stock);
                    }),
                    selectedColor: const Color(0xFFECFDF5),
                    labelStyle: TextStyle(
                      color: checked
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: checked ? FontWeight.w700 : FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: checked ? AppColors.primary : AppColors.separator,
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  '数量',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                _QuantityStepper(
                  value: quantity,
                  max: stock,
                  onChanged: (value) =>
                      setState(() => quantity = _clampQuantity(value, stock)),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: () {
                  if (stock <= 0) {
                    EasyLoading.showToast('库存不足');
                    return;
                  }
                  Navigator.of(context).pop();
                  widget.onConfirm(selected, _clampQuantity(quantity, stock));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(23),
                  ),
                ),
                child: Text(widget.confirmTitle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _clampQuantity(int value, int stock) {
    if (stock <= 0) return 1;
    return value.clamp(1, stock);
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.separator),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value <= 1 ? null : () => onChanged(value - 1),
            icon: const Icon(Icons.remove, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            onPressed: value >= max
                ? () => EasyLoading.showToast('库存不足')
                : () => onChanged(value + 1),
            icon: const Icon(Icons.add, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 34, height: 34),
          ),
        ],
      ),
    );
  }
}

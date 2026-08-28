import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import 'app_network_image.dart';
import 'price_text.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddCart,
    this.compact = false,
  });

  final ProductModel product;
  final VoidCallback? onTap;
  final VoidCallback? onAddCart;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageSize = constraints.maxWidth;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  child: SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: AppNetworkImage(product.firstImage),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.18,
                          ),
                        ),
                        if (!compact && product.displaySubtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.displaySubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.15,
                            ),
                          ),
                        ],
                        const Spacer(),
                        SizedBox(
                          // height: 32,
                          child: Row(
                            children: [
                              Expanded(
                                child: PriceText(
                                  product.displayPrice,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton.filled(
                                onPressed: onAddCart,
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  fixedSize: const Size(32, 32),
                                  minimumSize: const Size(32, 32),
                                  padding: EdgeInsets.zero,
                                ),
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  size: 17,
                                  color: Colors.white,
                                ),
                                tooltip: '加入购物车',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

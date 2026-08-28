import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/common_models.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/empty_state.dart';
import 'review_controller.dart';

class ReviewPage extends GetView<ReviewController> {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F7),
      appBar: AppBar(title: const Text('评价')),
      body: Obx(() {
        final order = controller.order.value;
        if (controller.loading.value && order == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (order == null) {
          return EmptyState(title: '订单信息不存在', onRetry: controller.loadOrder);
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          children: [
            _GoodsCard(items: order.displayItems),
            const SizedBox(height: 10),
            _RatingCard(controller: controller),
            const SizedBox(height: 10),
            _ContentCard(controller: controller),
            const SizedBox(height: 10),
            _ImagesCard(controller: controller),
          ],
        );
      }),
      bottomNavigationBar: Obx(
        () => Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
          color: const Color(0xFFF6F8F7),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 42,
              child: ElevatedButton(
                onPressed: controller.submitting.value
                    ? null
                    : controller.submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(controller.submitting.value ? '提交中...' : '提交评价'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoodsCard extends StatelessWidget {
  const _GoodsCard({required this.items});

  final List<CartItemModel> items;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '本次评价商品',
      child: items.isEmpty
          ? const Text(
              '暂无商品信息',
              style: TextStyle(color: AppColors.textTertiary),
            )
          : Column(children: items.map(_GoodsRow.new).toList()),
    );
  }
}

class _GoodsRow extends StatelessWidget {
  const _GoodsRow(this.item);

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AppNetworkImage(item.displayImage, width: 54, height: 54),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.displaySpec} × ${item.quantity}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.controller});

  final ReviewController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '商品评分',
      child: Obx(
        () => Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (details) =>
                  _selectRatingByPosition(context, details.localPosition.dx),
              onTapDown: (details) =>
                  _selectRatingByPosition(context, details.localPosition.dx),
              child: SizedBox(
                height: 46,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final value = index + 1;
                    final active = value <= controller.rating.value;
                    return SizedBox(
                      width: 46,
                      height: 46,
                      child: IconButton(
                        onPressed: () => controller.selectRating(value),
                        icon: Icon(
                          Icons.star,
                          color: active
                              ? const Color(0xFFFFB020)
                              : AppColors.separator,
                          size: 34,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _ratingText(controller.rating.value),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.primary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  void _selectRatingByPosition(BuildContext context, double dx) {
    final box = context.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 230;
    const starWidth = 46.0;
    const starRowWidth = starWidth * 5;
    final left = ((width - starRowWidth) / 2).clamp(0.0, width);
    final value = ((dx - left) / starWidth).ceil().clamp(1, 5);
    controller.selectRating(value);
  }

  String _ratingText(int value) {
    return switch (value) {
      1 => '非常差',
      2 => '不满意',
      3 => '一般',
      4 => '满意',
      _ => '非常满意',
    };
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.controller});

  final ReviewController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: '评价内容',
      child: TextField(
        minLines: 6,
        maxLines: 6,
        maxLength: 500,
        onChanged: (value) => controller.content.value = value,
        decoration: const InputDecoration(
          hintText: '请分享您的购物体验，帮助其他买家做出选择~',
          filled: false,
          border: InputBorder.none,
          counterStyle: TextStyle(color: AppColors.textTertiary),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _ImagesCard extends StatelessWidget {
  const _ImagesCard({required this.controller});

  final ReviewController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _SectionCard(
        title: '上传图片',
        trailing: '${controller.images.length}/3',
        child: Row(
          children: [
            ...controller.images.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(right: 9),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        entry.value.bytes,
                        width: 78,
                        height: 78,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: -6,
                      top: -6,
                      child: GestureDetector(
                        onTap: () => controller.removeImage(entry.key),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.images.length < 3)
              InkWell(
                onTap: controller.pickingImages.value
                    ? null
                    : controller.pickImages,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 78,
                  height: 78,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAF9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.separator),
                  ),
                  child: controller.pickingImages.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '上传图片',
                              style: TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              )
            else
              const Text(
                '最多上传3张',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (trailing != null)
                Text(
                  trailing!,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

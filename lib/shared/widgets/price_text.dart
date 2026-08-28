import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PriceText extends StatelessWidget {
  const PriceText(
    this.price, {
    super.key,
    this.fontSize = 18,
    this.prefix = '¥',
  });

  final String price;
  final double fontSize;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$prefix$price',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: AppColors.price,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

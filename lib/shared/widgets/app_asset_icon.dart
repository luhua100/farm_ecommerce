import 'package:flutter/material.dart';

class AppAssetIcon extends StatelessWidget {
  const AppAssetIcon(this.name, {super.key, this.size = 24});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/$name.png',
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}

import 'package:flutter/material.dart';

import '../../shared/widgets/empty_state.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyState(title: '$title 功能待继续对齐 iOS 版本'),
    );
  }
}

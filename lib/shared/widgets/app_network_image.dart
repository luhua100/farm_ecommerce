import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheBustKey,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Object? cacheBustKey;

  @override
  Widget build(BuildContext context) {
    final src = _withCacheBust(ApiClient.instance.assetUrl(url));
    if (src.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: AppColors.background,
        child: const Icon(Icons.image_outlined, color: AppColors.textTertiary),
      );
    }
    if (kIsWeb) {
      return Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        errorBuilder: (_, __, ___) => _ImageError(width: width, height: height),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _ImageLoading(width: width, height: height);
        },
      );
    }
    return CachedNetworkImage(
      imageUrl: src,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 160),
      fadeOutDuration: const Duration(milliseconds: 80),
      placeholder: (_, __) => _ImageLoading(width: width, height: height),
      errorWidget: (_, __, ___) => _ImageError(width: width, height: height),
    );
  }

  String _withCacheBust(String value) {
    final key = cacheBustKey;
    if (value.isEmpty || key == null) return value;
    final uri = Uri.tryParse(value);
    if (uri == null) return value;
    return uri
        .replace(queryParameters: {...uri.queryParameters, '_v': '$key'})
        .toString();
  }
}

class _ImageLoading extends StatelessWidget {
  const _ImageLoading({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.background,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.background,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.textTertiary,
      ),
    );
  }
}

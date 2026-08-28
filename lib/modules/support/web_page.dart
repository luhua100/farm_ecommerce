import 'package:dio/dio.dart';
import 'package:docx_file_viewer/docx_file_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_theme.dart';

class WebPage extends StatefulWidget {
  const WebPage({super.key, required this.url});

  final String url;

  @override
  State<WebPage> createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  WebViewController? _controller;
  var _progress = 0;

  String get _title {
    if (widget.url.contains('fram_privite_user')) return '用户协议';
    if (widget.url.contains('fram_privite') ||
        widget.url.contains('privacy_policy') ||
        widget.url.contains('privacy-policy')) {
      return '隐私政策';
    }
    return '预告';
  }

  bool get _isDocument =>
      Uri.tryParse(widget.url)?.path.endsWith('.docx') == true;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && !_isDocument) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (progress) => setState(() => _progress = progress),
            onPageFinished: (_) => _injectFitScript(),
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(_title)),
      body: _isDocument
          ? _DocxDocumentView(url: widget.url)
          : _controller == null
          ? _ExternalOpenView(url: widget.url)
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_progress < 100)
                  LinearProgressIndicator(
                    value: _progress <= 0 ? null : _progress / 100,
                    minHeight: 2,
                    color: AppColors.primary,
                  ),
              ],
            ),
    );
  }

  Future<void> _injectFitScript() async {
    const script = '''
    (function() {
      var meta = document.querySelector('meta[name="viewport"]');
      if (!meta) {
        meta = document.createElement('meta');
        meta.name = 'viewport';
        document.head.appendChild(meta);
      }
      meta.content = 'width=device-width, initial-scale=1, maximum-scale=1';
      var style = document.getElementById('flutter-agreement-fit-style');
      if (!style) {
        style = document.createElement('style');
        style.id = 'flutter-agreement-fit-style';
        document.head.appendChild(style);
      }
      style.innerHTML = 'html,body{margin:0!important;padding:0!important;width:100%!important;font-size:clamp(15px,4vw,18px)!important;line-height:1.75!important;-webkit-text-size-adjust:100%!important;word-break:break-word!important;} img,video,table{max-width:100%!important;height:auto!important;} *{box-sizing:border-box!important;}';
    })();
    ''';
    await _controller?.runJavaScript(script);
  }
}

class _DocxDocumentView extends StatefulWidget {
  const _DocxDocumentView({required this.url});

  final String url;

  @override
  State<_DocxDocumentView> createState() => _DocxDocumentViewState();
}

class _DocxDocumentViewState extends State<_DocxDocumentView> {
  late final Future<Uint8List> _future = _loadDocx();

  Future<Uint8List> _loadDocx() async {
    if (widget.url.startsWith('assets/')) {
      final data = await rootBundle.load(widget.url);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
    final response = await Dio().get<List<int>>(
      widget.url,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null || data.isEmpty) {
      throw StateError('协议加载失败');
    }
    return Uint8List.fromList(data);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return _DocumentErrorView(url: widget.url);
        }
        return DocxView.bytes(
          snapshot.data!,
          config: DocxViewConfig(
            pageMode: DocxPageMode.continuous,
            enableZoom: true,
            enableSelection: true,
            minScale: 0.9,
            maxScale: 2.5,
            showPageBreaks: false,
            backgroundColor: const Color(0xFFF6F7F8),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            customFontFallbacks: const [
              'Roboto',
              'Noto Sans CJK SC',
              'PingFang SC',
              'Microsoft YaHei',
              'Arial',
            ],
            theme: const DocxViewTheme(
              backgroundColor: Color(0xFFF6F7F8),
              defaultTextStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                height: 1.75,
              ),
              headingStyles: {
                1: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  height: 1.45,
                  fontWeight: FontWeight.w800,
                ),
                2: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
                3: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
                4: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  height: 1.55,
                  fontWeight: FontWeight.w700,
                ),
              },
              tableBorderColor: AppColors.separator,
              tableHeaderBackground: Color(0xFFEFF6F2),
              bulletColor: AppColors.primary,
              linkStyle: TextStyle(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DocumentErrorView extends StatelessWidget {
  const _DocumentErrorView({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.description_outlined,
              color: AppColors.textTertiary,
              size: 52,
            ),
            const SizedBox(height: 14),
            const Text(
              '协议加载失败',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '请检查网络后重试，或使用外部浏览器打开。',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              ),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('外部打开'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExternalOpenView extends StatelessWidget {
  const _ExternalOpenView({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public, color: AppColors.primary, size: 52),
            const SizedBox(height: 14),
            const Text(
              '点击打开页面',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              url,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              ),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('打开'),
            ),
          ],
        ),
      ),
    );
  }
}

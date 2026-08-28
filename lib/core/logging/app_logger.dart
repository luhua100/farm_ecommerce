import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// App 内统一日志入口。
///
/// 统一放在这里的好处是：业务代码不用关心 logger 插件配置，网络层、
/// 控制器或临时排查代码都可以直接调用 `AppLogger.d/i/w/e`。
class AppLogger {
  AppLogger._();

  /// Release 包关闭日志，避免生产环境输出请求参数、接口响应等调试信息。
  /// Debug/Profile 下使用更易读的格式，并关闭 emoji，方便 Android Studio 过滤。
  static final Logger _logger = Logger(
    level: kReleaseMode ? Level.off : Level.debug,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 6,
      lineLength: 110,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void d(String message, [Object? data]) {
    _logger.d(_format(message, data));
  }

  static void i(String message, [Object? data]) {
    _logger.i(_format(message, data));
  }

  static void w(String message, [Object? data]) {
    _logger.w(_format(message, data));
  }

  static void e(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) {
    _logger.e(_format(message, data), error: error, stackTrace: stackTrace);
  }

  /// Dio 网络日志拦截器。
  ///
  /// 输出请求、响应和异常三类日志；请求头、请求体和响应体在输出前都会经过脱敏处理。
  /// 当前在 `ApiClient` 初始化时挂载到全局 Dio 实例。
  static Interceptor dioInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        d('HTTP ${options.method} ${options.uri}', {
          'headers': _sanitizeHeaders(options.headers),
          'query': options.queryParameters,
          'body': options.data,
        });
        handler.next(options);
      },
      onResponse: (response, handler) {
        i(
          'HTTP ${response.requestOptions.method} ${response.statusCode} ${response.requestOptions.uri}',
          {'response': response.data},
        );
        handler.next(response);
      },
      onError: (error, handler) {
        e(
          'HTTP ${error.requestOptions.method} ${error.response?.statusCode ?? '-'} ${error.requestOptions.uri}',
          error: error,
          stackTrace: error.stackTrace,
          data: {
            'request': {
              'query': error.requestOptions.queryParameters,
              'body': error.requestOptions.data,
            },
            'response': error.response?.data,
            'message': error.message,
          },
        );
        handler.next(error);
      },
    );
  }

  static String _format(String message, Object? data) {
    if (data == null) return message;
    return '$message\n${_pretty(data)}';
  }

  /// 将 Map/List 等结构化数据转成缩进 JSON，便于排查接口参数。
  /// 如果遇到不能 JSON 编码的对象，就退回到 `toString()`。
  static String _pretty(Object? value) {
    final sanitized = _sanitize(value);
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(sanitized);
    } catch (_) {
      return sanitized.toString();
    }
  }

  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    return headers.map(
      (key, value) =>
          MapEntry(key, _isSensitiveKey(key) ? _mask(value) : value),
    );
  }

  /// 日志输出前的统一清洗。
  ///
  /// - token、手机号、验证码等敏感字段会打码。
  /// - 上传图片/FormData 只打印文件名和长度，不打印二进制内容。
  /// - 过长字符串会截断，避免一条接口日志把控制台刷满。
  static Object? _sanitize(Object? value) {
    if (value == null || value is num || value is bool) return value;
    if (value is Uint8List) return '<bytes ${value.length}>';
    if (value is FormData) {
      return {
        'fields': {
          for (final field in value.fields)
            field.key: _isSensitiveKey(field.key)
                ? _mask(field.value)
                : field.value,
        },
        'files': [
          for (final file in value.files)
            {
              'field': file.key,
              'filename': file.value.filename,
              'length': file.value.length,
            },
        ],
      };
    }
    if (value is MultipartFile) {
      return {'filename': value.filename, 'length': value.length};
    }
    if (value is Map) {
      return value.map((key, item) {
        final textKey = key.toString();
        return MapEntry(
          textKey,
          _isSensitiveKey(textKey) ? _mask(item) : _sanitize(item),
        );
      });
    }
    if (value is Iterable && value is! String) {
      if (value is List<int> && value.length > 50) {
        return '<bytes ${value.length}>';
      }
      final list = value.take(20).map(_sanitize).toList();
      if (value.length > 20) list.add('<and ${value.length - 20} more>');
      return list;
    }
    final text = value.toString();
    if (text.length > 1200) return '${text.substring(0, 1200)}...<truncated>';
    return text;
  }

  static bool _isSensitiveKey(String key) {
    final lower = key.toLowerCase();
    return lower.contains('authorization') ||
        lower.contains('token') ||
        lower.contains('password') ||
        lower.contains('code') ||
        lower.contains('phone') ||
        lower.contains('mobile');
  }

  /// 简单保留首尾字符，既能帮助确认字段是否传对，又不会泄露完整敏感值。
  static String _mask(Object? value) {
    final text = value?.toString() ?? '';
    if (text.isEmpty) return '';
    if (text.length <= 4) return '****';
    return '${text.substring(0, 2)}****${text.substring(text.length - 2)}';
  }
}

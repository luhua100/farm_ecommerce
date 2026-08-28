import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fluwx/fluwx.dart';

import '../../data/services/services.dart';
import '../logging/app_logger.dart';
import '../network/api_exception.dart';

/// 微信 APP 支付统一入口。
///
/// 负责注册微信 SDK、调起支付、接收微信回调，并以服务端查询结果作为最终
/// 支付依据。页面控制器只需要传入订单号，不需要分别处理微信参数和回调。
class WechatAppPaymentService {
  WechatAppPaymentService._();

  static final WechatAppPaymentService instance = WechatAppPaymentService._();

  static const _configuredAppId = String.fromEnvironment('WECHAT_APP_ID');

  final Fluwx _fluwx = Fluwx();
  String? _registeredAppId;
  bool _paying = false;

  /// 建议在应用启动时注册。未提供编译参数时，会在首次支付拿到服务端 AppID 后注册。
  Future<void> initialize({String? appId}) async {
    if (kIsWeb) return;
    final value = (appId ?? _configuredAppId).trim();
    if (value.isEmpty || value == _registeredAppId) return;

    final registered = await _fluwx.registerApi(
      appId: value,
      doOnIOS: defaultTargetPlatform == TargetPlatform.iOS,
      doOnAndroid: defaultTargetPlatform == TargetPlatform.android,
    );
    if (!registered) {
      AppLogger.e('WeChat SDK registration failed', data: {'appId': value});
      throw ApiException('微信支付初始化失败，请检查应用 AppID、包名和签名');
    }
    _registeredAppId = value;
    AppLogger.i('WeChat SDK registered', {'appId': value});
  }

  /// 调起微信 APP 支付，并在微信返回后向服务端确认真实支付状态。
  Future<bool> pay(String orderNo) async {
    if (kIsWeb) throw ApiException('网页版不支持微信 APP 支付');
    if (_paying) throw ApiException('支付正在处理中，请勿重复操作');
    if (orderNo.trim().isEmpty) throw ApiException('订单号不能为空');

    _paying = true;
    FluwxCancelable? subscriber;
    try {
      if (!await _fluwx.isWeChatInstalled) {
        throw ApiException('未安装微信，请安装后再支付');
      }

      final result = await OrderService.pay(orderNo, payType: 'app');
      if (result?.synced == true) return true;

      final params = result?.appPayParams;
      if (params == null || !params.isValid) {
        AppLogger.e(
          'Invalid WeChat APP payment parameters',
          data: {'orderNo': orderNo, 'paymentMode': result?.paymentMode},
        );
        throw ApiException('微信支付参数不完整，请检查后台 APP 支付配置');
      }

      await initialize(appId: params.appId);

      final responseCompleter = Completer<WeChatPaymentResponse>();
      subscriber = _fluwx.addSubscriber((response) {
        if (response is! WeChatPaymentResponse ||
            responseCompleter.isCompleted) {
          return;
        }
        responseCompleter.complete(response);
      });

      AppLogger.i('Launching WeChat APP payment', {
        'orderNo': orderNo,
        'partnerId': params.partnerId,
        'prepayId': params.prepayId,
      });
      final launched = await _fluwx.pay(
        which: Payment(
          appId: params.appId,
          partnerId: params.partnerId,
          prepayId: params.prepayId,
          packageValue: params.packageValue,
          nonceStr: params.nonceStr,
          timestamp: params.timestamp,
          sign: params.sign,
          signType: params.signType,
          extData: params.extData ?? orderNo,
        ),
      );
      if (!launched) {
        throw ApiException('无法调起微信支付，请检查应用包名和签名配置');
      }

      final response = await responseCompleter.future.timeout(
        const Duration(minutes: 10),
        onTimeout: () => throw ApiException('支付结果待确认，请稍后在订单中查看'),
      );
      AppLogger.i('Received WeChat payment callback', {
        'orderNo': orderNo,
        'errCode': response.errCode,
        'errStr': response.errStr,
      });

      if (response.errCode == -2) throw ApiException('已取消支付');
      if (!response.isSuccessful) {
        throw ApiException(
          response.errStr?.trim().isNotEmpty == true
              ? response.errStr!.trim()
              : '微信支付未完成，请重试',
        );
      }

      return _confirmPayment(orderNo);
    } on ApiException {
      rethrow;
    } catch (error, stackTrace) {
      AppLogger.e(
        'WeChat APP payment failed',
        error: error,
        stackTrace: stackTrace,
        data: {'orderNo': orderNo},
      );
      throw ApiException('微信支付调起失败，请稍后重试');
    } finally {
      subscriber?.cancel();
      _paying = false;
    }
  }

  Future<bool> _confirmPayment(String orderNo) async {
    Object? lastError;
    for (final delay in const [
      Duration.zero,
      Duration(milliseconds: 800),
      Duration(seconds: 2),
    ]) {
      if (delay > Duration.zero) await Future<void>.delayed(delay);
      try {
        final result = await OrderService.syncWechatPayment(
          orderNo,
          payType: 'app',
        );
        if (result?.synced == true) {
          AppLogger.i('WeChat payment confirmed by server', {
            'orderNo': orderNo,
          });
          return true;
        }
      } catch (error, stackTrace) {
        lastError = error;
        AppLogger.w('Waiting for WeChat payment confirmation', {
          'orderNo': orderNo,
          'error': error.toString(),
          'stackTrace': stackTrace.toString(),
        });
      }
    }

    AppLogger.w('WeChat payment result is pending', {
      'orderNo': orderNo,
      if (lastError != null) 'error': lastError.toString(),
    });
    throw ApiException('支付结果确认中，请稍后在订单中查看');
  }
}

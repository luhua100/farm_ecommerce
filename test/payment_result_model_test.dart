import 'package:farm_android/data/models/common_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentResultModel', () {
    test('parses nested WeChat APP payment parameters', () {
      final model = PaymentResultModel.fromJson({
        'paymentMode': 'wechat_app',
        'payParams': {
          'appId': 'wx_app_id',
          'partnerId': '1900000109',
          'prepayId': 'wx_prepaid_order',
          'nonceStr': 'nonce',
          'timeStamp': '1720000000',
          'package': 'Sign=WXPay',
          'sign': 'signature',
        },
      });

      expect(model.paymentMode, 'wechat_app');
      expect(model.appPayParams?.isValid, isTrue);
      expect(model.appPayParams?.timestamp, 1720000000);
      expect(model.appPayParams?.packageValue, 'Sign=WXPay');
    });

    test('keeps H5 payment response compatibility', () {
      final model = PaymentResultModel.fromJson({
        'payment_mode': 'wechat_h5',
        'pay_params': {'h5_url': 'https://example.com/pay'},
      });

      expect(model.paymentMode, 'wechat_h5');
      expect(model.h5Url, 'https://example.com/pay');
      expect(model.appPayParams, isNull);
    });

    test('parses already synchronized response', () {
      final model = PaymentResultModel.fromJson({
        'synced': true,
        'paymentMode': 'wechat_synced',
      });

      expect(model.synced, isTrue);
      expect(model.appPayParams, isNull);
    });
  });
}

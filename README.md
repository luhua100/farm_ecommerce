# 楚智农购 Android

Flutter Android 客户端，使用 GetX、Dio、EasyLoading、SharedPreferences 和 fluwx。

## 微信 APP 支付

Android 正式包名为 `com.climby.farm`。微信开放平台移动应用中配置的包名必须与此一致，应用签名必须来自最终发布使用的 release keystore。

服务端按场景分别配置：

```text
小程序：payType=jsapi
原生应用：payType=app
手机浏览器：payType=h5
```

应用启动时可以通过编译参数提前注册微信 SDK：

```shell
flutter run --dart-define=WECHAT_APP_ID=微信开放平台移动应用AppID
flutter build apk --release --dart-define=WECHAT_APP_ID=微信开放平台移动应用AppID
```

未传编译参数时，客户端会在创建支付订单并收到服务端 APP 支付参数后，使用其中的 AppID 注册 SDK。服务端 `WECHAT_PAY_APP_APP_ID` 必须与微信开放平台移动应用 AppID 完全一致。

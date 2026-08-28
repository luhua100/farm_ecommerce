import 'dart:async';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../core/payment/wechat_app_payment_service.dart';
import '../../core/storage/app_storage.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';

class PaymentController extends GetxController {
  final loading = false.obs;
  final addresses = <AddressModel>[].obs;
  final items = <CartItemModel>[].obs;
  final address = Rxn<AddressModel>();
  final preview = Rxn<OrderPreviewModel>();
  final selectedCouponId = Rxn<int>();
  final orderNo = RxnString();
  final remainSeconds = 600.obs;
  final submitting = false.obs;

  Timer? _timer;

  String get payable {
    final value = preview.value?.payableAmount;
    if (value?.isNotEmpty == true) return value!;
    return rawTotal.toStringAsFixed(2);
  }

  double get rawTotal => items.fold(0, (sum, item) => sum + item.lineTotal);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get expired => remainSeconds.value <= 0;

  String get payButtonTitle => expired ? '订单已超时' : '确认支付 ¥$payable';

  bool get canPay =>
      !expired && items.isNotEmpty && !loading.value && !submitting.value;

  @override
  void onInit() {
    super.onInit();
    loadData();
    _startCountdown();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> loadData() async {
    loading.value = true;
    try {
      await loadAddresses();
      final arguments = Get.arguments;
      if (arguments is List<CartItemModel>) {
        items.assignAll(arguments);
      } else if (arguments is List) {
        items.assignAll(arguments.whereType<CartItemModel>());
      } else {
        final cartItems = await CartService.list();
        items.assignAll(cartItems.where((item) => item.selected));
      }
      if (items.isEmpty) {
        EasyLoading.showToast('暂无待结算商品');
      }
      await refreshPreview();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '确认订单加载失败');
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadAddresses() async {
    final values = await AddressService.list();
    addresses.assignAll(values);
    final currentId = address.value?.id;
    if (currentId != null) {
      address.value = values.firstWhereOrNull((item) => item.id == currentId);
    }
    address.value ??= values.firstWhereOrNull((item) => item.isDefault);
    address.value ??= values.firstOrNull;
  }

  Future<void> refreshPreview() async {
    if (items.isEmpty) {
      preview.value = null;
      selectedCouponId.value = null;
      return;
    }
    try {
      final value = await OrderService.preview(
        items: items,
        userCouponId: selectedCouponId.value,
      );
      preview.value = value;
      selectedCouponId.value = value?.selectedCouponId;
    } catch (error) {
      preview.value = null;
      EasyLoading.showToast(error is ApiException ? error.message : '订单金额计算失败');
    }
  }

  void selectAddress(AddressModel value) {
    address.value = value;
  }

  Future<void> addAddress() async {
    await Get.toNamed(AppRoutes.addressEdit);
    await loadAddresses();
  }

  Future<void> selectCoupon(int id) async {
    if (orderNo.value?.isNotEmpty == true) {
      EasyLoading.showToast('订单已创建，优惠券不可更改');
      return;
    }
    selectedCouponId.value = id;
    await refreshPreview();
  }

  Future<void> clearCoupon() async {
    if (orderNo.value?.isNotEmpty == true) {
      EasyLoading.showToast('订单已创建，优惠券不可更改');
      return;
    }
    selectedCouponId.value = -1;
    await refreshPreview();
  }

  Future<void> pay() async {
    if (submitting.value) return;
    if (!AppStorage.instance.isLoggedIn) {
      await Get.toNamed(AppRoutes.login);
      return;
    }
    if (expired) {
      EasyLoading.showToast('订单已超时，请重新下单');
      return;
    }
    if (items.isEmpty) {
      EasyLoading.showToast('请选择商品');
      return;
    }
    final selectedAddress = address.value;
    if (selectedAddress == null) {
      EasyLoading.showToast('请选择收货地址');
      return;
    }
    try {
      submitting.value = true;
      var no = orderNo.value ?? '';
      if (no.isEmpty) {
        final created = await OrderService.create(
          addressId: selectedAddress.id,
          items: items,
          userCouponId: selectedCouponId.value,
        );
        no = created?.displayOrderNo ?? '';
        if (no.isEmpty) {
          EasyLoading.showToast('订单创建成功，但返回的订单号为空');
          return;
        }
        orderNo.value = no;
      }
      await WechatAppPaymentService.instance.pay(no);
      EasyLoading.showToast('支付成功');
      await Get.toNamed(AppRoutes.orderDetail, parameters: {'orderNo': no});
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '支付失败');
    } finally {
      submitting.value = false;
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    remainSeconds.value = 600;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      remainSeconds.value = (remainSeconds.value - 1).clamp(0, 600);
      if (remainSeconds.value > 0) return;
      timer.cancel();
      final no = orderNo.value ?? '';
      if (no.isNotEmpty) {
        await OrderService.cancel(no);
      }
    });
  }
}

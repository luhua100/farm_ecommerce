import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';

class CouponsController extends GetxController {
  CouponsController({bool receiveMode = false}) : receiveMode = receiveMode.obs;

  final RxBool receiveMode;
  final loading = false.obs;
  final activeStatus = 0.obs;
  final coupons = <CouponModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    receiveMode.value = Get.parameters['mode'] == 'receive';
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final list = receiveMode.value
          ? await CouponService.center()
          : await CouponService.mine(status: activeStatus.value);
      coupons.assignAll(
        receiveMode.value
            ? list
            : list.where((item) => item.status == activeStatus.value),
      );
    } catch (error) {
      coupons.clear();
      EasyLoading.showToast(error is ApiException ? error.message : '优惠券加载失败');
    } finally {
      loading.value = false;
    }
  }

  Future<void> switchStatus(int status) async {
    if (activeStatus.value == status) return;
    activeStatus.value = status;
    coupons.clear();
    await load();
  }

  Future<void> receive(CouponModel coupon) async {
    if (coupon.received) return;
    try {
      await CouponService.receive(coupon.id);
      EasyLoading.showSuccess('领取成功');
      await load();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '领取失败');
    }
  }

  void openReceiveCenter() {
    receiveMode.value = true;
    coupons.clear();
    load();
  }

  void goUse() {
    Get.offAllNamed(AppRoutes.main);
  }
}

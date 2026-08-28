import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';

class LogisticsController extends GetxController {
  final orderNo =
      (Get.parameters['orderNo'] ?? Get.arguments?.toString() ?? '').obs;
  final loading = false.obs;
  final logistics = Rxn<LogisticsModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (orderNo.value.isEmpty) {
      EasyLoading.showToast('订单号不能为空');
      return;
    }
    loading.value = true;
    try {
      logistics.value = await LogisticsService.detail(orderNo.value);
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '物流加载失败');
    } finally {
      loading.value = false;
    }
  }
}

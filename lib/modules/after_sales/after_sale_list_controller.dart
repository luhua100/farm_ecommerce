import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';

class AfterSaleListController extends GetxController {
  final loading = false.obs;
  final items = <AfterSaleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      items.assignAll(await AfterSalesService.list());
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '售后记录加载失败');
    } finally {
      loading.value = false;
    }
  }

  void openDetail(AfterSaleModel model) {
    Get.toNamed(AppRoutes.afterSaleDetail, parameters: {'id': '${model.id}'});
  }
}

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';

class AddressListController extends GetxController {
  final loading = false.obs;
  final addresses = <AddressModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      addresses.assignAll(await AddressService.list());
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '地址加载失败');
    } finally {
      loading.value = false;
    }
  }

  void addAddress() {
    Get.toNamed(AppRoutes.addressEdit)?.then((_) => load());
  }

  void editAddress(AddressModel address) {
    Get.toNamed(
      AppRoutes.addressEdit,
      parameters: {'id': '${address.id}'},
    )?.then((_) => load());
  }

  Future<void> setDefault(AddressModel address) async {
    try {
      await AddressService.setDefault(address.id);
      await load();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '设置失败');
    }
  }

  Future<void> delete(AddressModel address) async {
    try {
      await AddressService.delete(address.id);
      addresses.removeWhere((item) => item.id == address.id);
      EasyLoading.showSuccess('已删除');
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '删除失败');
    }
  }
}

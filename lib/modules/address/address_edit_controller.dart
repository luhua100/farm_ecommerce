import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';

class AddressEditController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final detailController = TextEditingController();
  final isDefault = false.obs;
  final province = ''.obs;
  final city = ''.obs;
  final district = ''.obs;

  int? get addressId => int.tryParse(Get.parameters['id'] ?? '');

  String get title => addressId == null ? '新增地址' : '编辑地址';

  String get regionText {
    final text = [
      province.value,
      city.value,
      district.value,
    ].where((item) => item.isNotEmpty).join(' ');
    return text.isEmpty ? '请选择省市区' : text;
  }

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_limitPhone);
    loadAddress();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    detailController.dispose();
    super.onClose();
  }

  Future<void> loadAddress() async {
    final id = addressId;
    if (id == null) return;
    try {
      final addresses = await AddressService.list();
      final address = addresses.firstWhereOrNull((item) => item.id == id);
      if (address == null) return;
      nameController.text = address.name;
      phoneController.text = address.phone;
      detailController.text = address.detail;
      province.value = address.province;
      city.value = address.city;
      district.value = address.district;
      isDefault.value = address.isDefault;
    } catch (_) {}
  }

  void setRegion(RegionSelection selection) {
    province.value = selection.province;
    city.value = selection.city;
    district.value = selection.district;
  }

  Future<void> save() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final detail = detailController.text.trim();
    if (name.isEmpty) {
      EasyLoading.showToast('请输入收货人');
      return;
    }
    if (!RegExp(r'^1\d{10}$').hasMatch(phone)) {
      EasyLoading.showToast('请输入正确的手机号');
      return;
    }
    if (province.value.isEmpty ||
        city.value.isEmpty ||
        district.value.isEmpty) {
      EasyLoading.showToast('请选择所在地区');
      return;
    }
    if (detail.isEmpty) {
      EasyLoading.showToast('请输入详细地址');
      return;
    }
    final address = AddressModel(
      id: addressId ?? 0,
      name: name,
      phone: phone,
      province: province.value,
      city: city.value,
      district: district.value,
      detail: detail,
      isDefault: isDefault.value,
    );
    try {
      if (addressId == null) {
        await AddressService.add(address);
      } else {
        await AddressService.update(address);
      }
      EasyLoading.showSuccess('保存成功');
      Get.back(result: true);
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '保存失败');
    }
  }

  void _limitPhone() {
    final text = phoneController.text;
    if (text.length <= 11) return;
    phoneController.text = text.substring(0, 11);
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: phoneController.text.length),
    );
  }
}

class RegionSelection {
  const RegionSelection({
    required this.province,
    required this.city,
    required this.district,
  });

  final String province;
  final String city;
  final String district;
}

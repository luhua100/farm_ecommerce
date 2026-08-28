import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';

class AfterSaleDetailController extends GetxController {
  final id = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
  final loading = false.obs;
  final model = Rxn<AfterSaleModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (id <= 0) {
      EasyLoading.showToast('售后单不存在');
      return;
    }
    loading.value = true;
    try {
      model.value = await AfterSalesService.detail(id);
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '售后详情加载失败');
    } finally {
      loading.value = false;
    }
  }

  Future<void> submitReturnLogistics() async {
    final item = model.value;
    if (item == null) return;
    final result = await Get.dialog<Map<String, String>>(
      _ReturnLogisticsDialog(),
    );
    if (result == null) return;
    try {
      await AfterSalesService.submitReturnLogistics(
        afterSaleId: item.id,
        company: result['company'] ?? '',
        trackingNo: result['trackingNo'] ?? '',
      );
      EasyLoading.showToast('已提交');
      await load();
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '提交失败');
    }
  }
}

class _ReturnLogisticsDialog extends StatefulWidget {
  @override
  State<_ReturnLogisticsDialog> createState() => _ReturnLogisticsDialogState();
}

class _ReturnLogisticsDialogState extends State<_ReturnLogisticsDialog> {
  final companyController = TextEditingController();
  final trackingController = TextEditingController();

  @override
  void dispose() {
    companyController.dispose();
    trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('填写退货物流'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: companyController,
            decoration: const InputDecoration(hintText: '物流公司（选填）'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: trackingController,
            decoration: const InputDecoration(hintText: '物流单号'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('取消')),
        TextButton(
          onPressed: () {
            final trackingNo = trackingController.text.trim();
            if (trackingNo.isEmpty) {
              EasyLoading.showToast('请填写物流单号');
              return;
            }
            Get.back(
              result: {
                'company': companyController.text.trim(),
                'trackingNo': trackingNo,
              },
            );
          },
          child: const Text('提交'),
        ),
      ],
    );
  }
}

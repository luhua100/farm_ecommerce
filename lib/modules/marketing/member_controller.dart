import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/network/api_exception.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';

class MemberController extends GetxController {
  final loading = false.obs;
  final member = Rxn<MemberInfoModel>();
  final points = <PointsHistoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final result = await Future.wait<dynamic>([
        MemberService.me(),
        MemberService.points(),
      ]);
      member.value = result[0] as MemberInfoModel?;
      points.assignAll(result[1] as List<PointsHistoryModel>);
    } catch (error) {
      EasyLoading.showToast(error is ApiException ? error.message : '会员信息加载失败');
    } finally {
      loading.value = false;
    }
  }
}

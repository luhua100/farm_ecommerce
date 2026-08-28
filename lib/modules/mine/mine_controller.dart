import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../../core/storage/app_storage.dart';
import '../../data/models/common_models.dart';
import '../../data/services/services.dart';
import '../../routes/app_routes.dart';

class MineController extends GetxController {
  final user = Rxn<UserModel>();
  final stats = OrderStatsModel().obs;
  final member = MemberInfoModel(levelName: '登录解锁会员权益').obs;
  final unreadCount = 0.obs;
  final profileVersion = 0.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = AppStorage.instance.user;
    refreshUser();
  }

  Future<void> refreshUser() async {
    user.value = AppStorage.instance.user;
    if (!AppStorage.instance.isLoggedIn) {
      stats.value = OrderStatsModel();
      member.value = MemberInfoModel(levelName: '登录解锁会员权益');
      unreadCount.value = 0;
      return;
    }
    try {
      final value = await UserService.userInfo();
      if (value != null) {
        user.value = value;
        await AppStorage.instance.saveUser(value);
        profileVersion.value++;
      }
    } catch (_) {}
    await Future.wait([_loadStats(), _loadMember(), _loadUnreadCount()]);
  }

  Future<void> _loadStats() async {
    try {
      stats.value = await OrderService.stats() ?? OrderStatsModel();
    } catch (_) {}
  }

  Future<void> _loadMember() async {
    try {
      member.value = await MemberService.me() ?? MemberInfoModel();
    } catch (_) {}
  }

  Future<void> _loadUnreadCount() async {
    try {
      unreadCount.value = await MessageService.unreadCount();
    } catch (_) {}
  }

  void requireLoginOr(String route, {Map<String, String>? parameters}) {
    if (!AppStorage.instance.isLoggedIn) {
      Get.toNamed(AppRoutes.login)?.then((_) => refreshUser());
      return;
    }
    Get.toNamed(route, parameters: parameters);
  }

  Future<void> logout() async {
    await AppStorage.instance.clearLogin();
    user.value = null;
    stats.value = OrderStatsModel();
    member.value = MemberInfoModel(levelName: '登录解锁会员权益');
    unreadCount.value = 0;
    profileVersion.value++;
    EasyLoading.showSuccess('已退出登录');
  }

  bool get isLoggedIn {
    final currentUser = user.value;
    return currentUser != null || AppStorage.instance.isLoggedIn;
  }

  String get displayName =>
      isLoggedIn ? (user.value?.displayName ?? '用户') : '登录/注册';

  String get phoneText {
    if (!isLoggedIn) return '登录后享受更多权益';
    final phone = user.value?.phone ?? '';
    if (phone.length == 11) {
      return '${phone.substring(0, 3)}****${phone.substring(7)}';
    }
    return phone.isEmpty ? '已登录' : phone;
  }

  void openSettingsOrLogin() {
    Get.toNamed(
      isLoggedIn ? AppRoutes.settings : AppRoutes.login,
    )?.then((_) => refreshUser());
  }

  void openMessage() {
    if (!AppStorage.instance.isLoggedIn) {
      Get.toNamed(AppRoutes.login)?.then((_) => refreshUser());
      return;
    }
    Get.toNamed(AppRoutes.message)?.then((_) => refreshUser());
  }

  void openOrders([String status = 'all']) {
    requireLoginOr(AppRoutes.orderList, parameters: {'status': status});
  }
}

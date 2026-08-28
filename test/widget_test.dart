import 'package:farm_android/routes/app_pages.dart';
import 'package:farm_android/routes/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers main shopping routes', () {
    final routes = AppPages.pages.map((page) => page.name).toSet();

    expect(routes, contains(AppRoutes.main));
    expect(routes, contains(AppRoutes.productDetail));
    expect(routes, contains(AppRoutes.cart));
    expect(routes, contains(AppRoutes.mine));
    expect(routes, contains(AppRoutes.login));
    expect(routes, contains(AppRoutes.accountDeletion));
  });
}

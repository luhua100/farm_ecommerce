import '../../core/network/api_client.dart';
import '../models/common_models.dart';

class HomeService {
  static Future<List<BannerModel>> banners({String position = 'home'}) {
    return ApiClient.instance.requestArray(
      '/api/v2/banners',
      parameters: {'position': position},
      showLoading: false,
      fromJson: BannerModel.fromJson,
    );
  }

  static Future<List<CategoryModel>> categories() {
    return ApiClient.instance.requestArray(
      '/api/v2/categories',
      showLoading: false,
      fromJson: CategoryModel.fromJson,
    );
  }
}

class ProductService {
  static Future<List<ProductModel>> list(
    Map<String, dynamic> parameters,
  ) async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/products',
      parameters: parameters,
      showLoading: false,
    );
    return parseList(data, ProductModel.fromJson);
  }

  static Future<ProductModel?> detail(int id) {
    return ApiClient.instance.requestObject(
      '/api/v2/products/$id',
      fromJson: ProductModel.fromJson,
    );
  }

  static Future<ProductModel?> seckillDetail(int id) async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/seckill/products/$id',
    );
    if (data is! Map) return null;
    return _makeSeckillProduct(Map<String, dynamic>.from(data));
  }

  static Future<List<ProductModel>> seckillProducts(
    Map<String, dynamic> parameters,
  ) async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/seckill/products',
      parameters: parameters,
      showLoading: false,
    );
    return parseList(data, _makeSeckillProduct);
  }

  static Future<List<SeckillSessionModel>> seckillSessions() {
    return ApiClient.instance.requestArray(
      '/api/v2/seckill/sessions',
      showLoading: false,
      fromJson: SeckillSessionModel.fromJson,
    );
  }

  static Future<void> addFavorite(int productId) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/favorites',
      parameters: {'productId': productId},
      showLoading: false,
    );
  }

  static Future<void> removeFavorite(int productId) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/favorites',
      method: 'DELETE',
      parameters: {'productId': productId},
      showLoading: false,
    );
  }

  static Future<FavoriteCheckModel?> checkFavorite(int productId) {
    return ApiClient.instance.requestObject(
      '/api/v2/favorites/check',
      parameters: {'productId': productId},
      showLoading: false,
      fromJson: FavoriteCheckModel.fromJson,
    );
  }

  static ProductModel _makeSeckillProduct(Map<String, dynamic> data) {
    final source = data['product'] is Map
        ? Map<String, dynamic>.from(data['product'] as Map)
        : Map<String, dynamic>.from(data);
    if (source['id'] != null && data['product'] is Map) {
      source['productId'] = source['id'];
    }
    source
      ..['id'] = data['id'] ?? source['id']
      ..['seckillPrice'] =
          data['seckillPrice'] ??
          data['seckill_price'] ??
          source['seckillPrice']
      ..['stock'] = data['stock'] ?? source['stock']
      ..['soldCount'] =
          data['soldCount'] ?? data['sold_count'] ?? source['soldCount']
      ..['limitPerUser'] =
          data['limitPerUser'] ??
          data['limit_per_user'] ??
          source['limitPerUser']
      ..['status'] = data['status'] ?? source['status']
      ..['startTime'] =
          data['startTime'] ?? data['start_time'] ?? source['startTime']
      ..['endTime'] = data['endTime'] ?? data['end_time'] ?? source['endTime']
      ..['progress'] = data['progress'] ?? source['progress'];
    return ProductModel.fromJson(source);
  }
}

class SearchService {
  static Future<List<String>> hot() async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/search/hot',
      showLoading: false,
    );
    final values = _parseKeywords(data);
    if (values.isNotEmpty) return values;
    try {
      final products = await ProductService.list({
        'page': 1,
        'pageSize': 6,
        'section': 'hot',
      });
      return _dedupe(products.map((item) => item.name));
    } catch (_) {
      return <String>[];
    }
  }

  static Future<List<ProductModel>> search(String keyword) async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/search',
      parameters: {'keyword': keyword, 'pageSize': 50},
    );
    return parseList(data, ProductModel.fromJson);
  }

  static List<String> _parseKeywords(dynamic data) {
    if (data is List) return _dedupe(data.map(_keywordFrom));
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final direct = _keywordFrom(map);
      if (direct.isNotEmpty) return [direct];
      for (final key in [
        'list',
        'records',
        'items',
        'rows',
        'data',
        'keywords',
        'hotKeywords',
        'hot_keywords',
      ]) {
        final value = map[key];
        if (value is List) {
          final values = _dedupe(value.map(_keywordFrom));
          if (values.isNotEmpty) return values;
        }
      }
    }
    return <String>[];
  }

  static String _keywordFrom(dynamic item) {
    if (item is Map) {
      return asString(
        item['keyword'] ??
            item['name'] ??
            item['title'] ??
            item['word'] ??
            item['searchWord'] ??
            item['search_word'],
      ).trim();
    }
    return item?.toString().trim() ?? '';
  }

  static List<String> _dedupe(Iterable<String> values) {
    final result = <String>[];
    for (final value in values) {
      final text = value.trim();
      if (text.isEmpty || result.contains(text)) continue;
      result.add(text);
    }
    return result;
  }
}

class CartService {
  static Future<List<CartItemModel>> list() {
    return ApiClient.instance.requestArray(
      '/api/v2/cart',
      showLoading: false,
      fromJson: CartItemModel.fromJson,
    );
  }

  static Future<void> add(
    ProductModel product, {
    ProductSpecOptionModel? option,
    int quantity = 1,
  }) {
    final selected =
        option ?? (product.specs.isNotEmpty ? product.specs.first : null);
    return ApiClient.instance.requestEmpty(
      '/api/v2/cart/items',
      parameters: {
        'productId': product.realProductId,
        'quantity': quantity,
        'spec': selected?.label ?? product.unit ?? '',
        'specPrice': selected?.price ?? product.displayPrice,
        'skuId': selected?.skuId ?? product.skuId ?? product.id,
      },
      showLoading: false,
    );
  }

  static Future<void> update({
    required int cartId,
    int? quantity,
    bool? selected,
  }) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/cart/items',
      method: 'PUT',
      parameters: {
        'cartId': cartId,
        if (quantity != null) 'quantity': quantity,
        if (selected != null) 'selected': selected,
      },
      showLoading: false,
    );
  }

  static Future<void> delete(int cartId) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/cart/items',
      method: 'DELETE',
      parameters: {'cartId': cartId},
    );
  }

  static Future<void> selectAll(bool selected) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/cart/select-all',
      method: 'PUT',
      parameters: {'selected': selected},
      showLoading: false,
    );
  }
}

class UserService {
  static Future<void> sendPhoneCode(String phone) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/ios/user/send-code',
      parameters: {'phone': phone, 'platform': 'ios'},
    );
  }

  static Future<LoginResultModel?> loginWithPhone(String phone, String code) {
    return ApiClient.instance.requestObject(
      '/api/v2/ios/user/login',
      method: 'POST',
      parameters: {'provider': 'phone', 'phone': phone, 'code': code},
      fromJson: LoginResultModel.fromJson,
    );
  }

  static Future<UserModel?> userInfo() {
    return ApiClient.instance.requestObject(
      '/api/v2/user/info',
      showLoading: false,
      fromJson: UserModel.fromJson,
    );
  }

  static Future<void> updateInfo({
    required String nickname,
    required String avatar,
  }) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/user/info',
      method: 'PUT',
      parameters: {'nickname': nickname, 'avatar': avatar},
    );
  }

  static Future<void> sendAccountDeletionCode() {
    return ApiClient.instance.requestEmpty(
      '/api/v2/ios/user/account/send-code',
    );
  }

  static Future<void> deleteAccount(String code) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/user/account',
      method: 'DELETE',
      parameters: {'code': code},
    );
  }

  static Future<String> uploadAvatar({
    required List<int> bytes,
    String fileName = 'avatar.jpg',
  }) async {
    final data = await ApiClient.instance.uploadImage(
      '/api/v2/uploads/image',
      bytes: bytes,
      fileName: fileName,
    );
    return asString(data['url']);
  }
}

class OrderService {
  static List<Map<String, dynamic>> _itemPayload(List<CartItemModel> items) {
    return items.map((item) {
      final value = <String, dynamic>{
        'quantity': item.quantity,
        'productId': item.displayProductId,
        'skuId': item.skuId ?? item.id,
      };
      if (!item.isDirectBuy) {
        value['cartId'] = item.cartId ?? item.id;
      }
      if (item.seckillId != null) {
        value['seckillId'] = item.seckillId;
      }
      return value;
    }).toList();
  }

  static Future<List<OrderModel>> list({String? status}) async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/orders',
      parameters: {
        'pageSize': 50,
        if (status != null && status != 'all') 'status': status,
      },
      showLoading: false,
    );
    return parseList(data, OrderModel.fromJson);
  }

  static Future<OrderModel?> detail(String orderNo) {
    return ApiClient.instance.requestObject(
      '/api/v2/orders/$orderNo',
      showLoading: false,
      fromJson: OrderModel.fromJson,
    );
  }

  static Future<void> cancel(String orderNo) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/orders/cancel',
      parameters: {'orderNo': orderNo},
    );
  }

  static Future<void> receive(String orderNo) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/orders/receive',
      parameters: {'orderNo': orderNo},
    );
  }

  static Future<OrderStatsModel?> stats() {
    return ApiClient.instance.requestObject(
      '/api/v2/orders/stats/summary',
      showLoading: false,
      fromJson: OrderStatsModel.fromJson,
    );
  }

  static Future<void> buyAgain(String orderNo) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/orders/buy-again',
      parameters: {'orderNo': orderNo},
      showLoading: false,
    );
  }

  static Future<OrderPreviewModel?> preview({
    required List<CartItemModel> items,
    int? userCouponId,
  }) {
    return ApiClient.instance.requestObject(
      '/api/v2/orders/preview',
      method: 'POST',
      parameters: {
        'items': _itemPayload(items),
        if (userCouponId != null) 'userCouponId': userCouponId,
      },
      showLoading: false,
      fromJson: OrderPreviewModel.fromJson,
    );
  }

  static Future<OrderCreateResultModel?> create({
    required List<CartItemModel> items,
    int? addressId,
    int? userCouponId,
  }) {
    return ApiClient.instance.requestObject(
      '/api/v2/orders',
      method: 'POST',
      parameters: {
        'items': _itemPayload(items),
        if (addressId != null) 'addressId': addressId,
        if (userCouponId != null && userCouponId > 0)
          'userCouponId': userCouponId,
      },
      fromJson: OrderCreateResultModel.fromJson,
    );
  }

  static Future<PaymentResultModel?> pay(
    String orderNo, {
    String payType = 'app',
  }) {
    return ApiClient.instance.requestObject(
      '/api/v2/orders/pay',
      method: 'POST',
      parameters: {'orderNo': orderNo, 'payType': payType},
      fromJson: PaymentResultModel.fromJson,
    );
  }

  static Future<PaymentResultModel?> syncWechatPayment(
    String orderNo, {
    String payType = 'app',
  }) {
    return ApiClient.instance.requestObject(
      '/api/v2/orders/sync-wechat-payment',
      method: 'POST',
      parameters: {'orderNo': orderNo, 'payType': payType},
      showLoading: false,
      fromJson: PaymentResultModel.fromJson,
    );
  }
}

class ReviewService {
  static Future<void> submit({
    required String orderNo,
    required int rating,
    required String content,
    List<String> images = const [],
  }) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/reviews',
      parameters: {
        'orderNo': orderNo,
        'rating': rating,
        'content': content,
        'images': images,
      },
    );
  }

  static Future<String> uploadImage({
    required List<int> bytes,
    String fileName = 'review.jpg',
  }) async {
    final data = await ApiClient.instance.uploadImage(
      '/api/v2/uploads/image',
      bytes: bytes,
      fileName: fileName,
      showLoading: false,
    );
    return ApiClient.instance.assetUrl(asString(data['url']));
  }
}

class AddressService {
  static Future<List<AddressModel>> list() {
    return ApiClient.instance.requestArray(
      '/api/v2/addresses',
      showLoading: false,
      fromJson: AddressModel.fromJson,
    );
  }

  static Future<AddressModel?> add(AddressModel address) {
    return ApiClient.instance.requestObject(
      '/api/v2/addresses',
      method: 'POST',
      parameters: address.toJson(),
      fromJson: AddressModel.fromJson,
    );
  }

  static Future<void> update(AddressModel address) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/addresses',
      method: 'PUT',
      parameters: address.toJson(),
    );
  }

  static Future<void> delete(int id) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/addresses',
      method: 'DELETE',
      parameters: {'addressId': id},
    );
  }

  static Future<void> setDefault(int id) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/addresses/default',
      method: 'PUT',
      parameters: {'addressId': id},
      showLoading: false,
    );
  }
}

class FavoriteService {
  static Future<List<ProductModel>> list() async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/favorites',
      parameters: {'pageSize': 50},
      showLoading: false,
    );
    return parseList(data, ProductModel.fromJson);
  }
}

class CouponService {
  static Future<List<CouponModel>> center() {
    return ApiClient.instance.requestArray(
      '/api/v2/coupons',
      showLoading: false,
      fromJson: CouponModel.fromJson,
    );
  }

  static Future<List<CouponModel>> mine({int? status}) async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/coupons/me',
      parameters: {'pageSize': 50, if (status != null) 'status': status},
      showLoading: false,
    );
    return parseList(data, CouponModel.fromJson);
  }

  static Future<void> receive(int id) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/coupons/receive',
      parameters: {'couponId': id},
      showLoading: false,
    );
  }
}

class BrandService {
  static Future<List<BrandModel>> list() async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/brands',
      parameters: {'pageSize': 50},
      showLoading: false,
    );
    return parseList(data, BrandModel.fromJson);
  }

  static Future<void> toggleFollow(int id) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/brands/follow',
      parameters: {'brandId': id},
      showLoading: false,
    );
  }
}

class MessageService {
  static Future<List<MessageModel>> list({String type = 'all'}) async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/messages',
      parameters: {'pageSize': 50, if (type != 'all') 'type': type},
      showLoading: false,
    );
    return parseList(data, MessageModel.fromJson);
  }

  static Future<void> markRead(int id) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/messages/read',
      parameters: {'messageId': id},
      showLoading: false,
    );
  }

  static Future<void> delete(int id) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/messages',
      method: 'DELETE',
      parameters: {'messageId': id},
      showLoading: false,
    );
  }

  static Future<int> unreadCount() async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/messages/unread-count',
      showLoading: false,
    );
    if (data is int) return data;
    if (data is num) return data.toInt();
    if (data is Map) return asInt(data['count']);
    return 0;
  }
}

class MemberService {
  static Future<MemberInfoModel?> me() {
    return ApiClient.instance.requestObject(
      '/api/v2/members/me',
      showLoading: false,
      fromJson: MemberInfoModel.fromJson,
    );
  }

  static Future<List<PointsHistoryModel>> points() async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/members/points',
      parameters: {'pageSize': 20},
      showLoading: false,
    );
    return parseList(data, PointsHistoryModel.fromJson);
  }
}

class AfterSalesService {
  static Future<List<AfterSaleModel>> list() async {
    final data = await ApiClient.instance.requestData(
      '/api/v2/after-sales',
      parameters: {'pageSize': 50},
      showLoading: false,
    );
    return parseList(data, AfterSaleModel.fromJson);
  }

  static Future<AfterSaleModel?> detail(int id) {
    return ApiClient.instance.requestObject(
      '/api/v2/after-sales/$id',
      showLoading: false,
      fromJson: AfterSaleModel.fromJson,
    );
  }

  static Future<void> apply({
    required OrderModel order,
    required String type,
    required String reason,
    required String description,
    List<String> images = const [],
  }) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/after-sales',
      parameters: {
        'orderNo': order.orderNo,
        'type': type,
        'reason': reason,
        'description': description,
        'images': images,
        'items': _refundItems(order.displayItems),
      },
    );
  }

  static Future<String> uploadProof({
    required List<int> bytes,
    String fileName = 'after-sale.jpg',
  }) async {
    final data = await ApiClient.instance.uploadImage(
      '/api/v2/uploads/image',
      bytes: bytes,
      fileName: fileName,
      showLoading: false,
    );
    return ApiClient.instance.assetUrl(asString(data['url']));
  }

  static Future<void> submitReturnLogistics({
    required int afterSaleId,
    required String company,
    required String trackingNo,
  }) {
    return ApiClient.instance.requestEmpty(
      '/api/v2/after-sales/$afterSaleId/return-logistics',
      parameters: {'company': company, 'trackingNo': trackingNo},
    );
  }

  static List<Map<String, dynamic>> _refundItems(List<CartItemModel> items) {
    return items
        .map(
          (item) => {
            'orderItemId': item.displayOrderItemId,
            'skuId': item.skuId,
            'quantity': item.quantity,
            'refundAmount': item.lineTotal.toStringAsFixed(2),
          },
        )
        .toList();
  }
}

class LogisticsService {
  static Future<LogisticsModel?> detail(String orderNo) {
    return ApiClient.instance.requestObject(
      '/api/v2/logistics/$orderNo',
      showLoading: false,
      fromJson: LogisticsModel.fromJson,
    );
  }
}

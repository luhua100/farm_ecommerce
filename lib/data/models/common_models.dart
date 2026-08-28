class BannerModel {
  BannerModel({
    required this.id,
    required this.image,
    this.linkUrl,
    this.productId,
    this.spuId,
  });

  final int id;
  final String image;
  final String? linkUrl;
  final int? productId;
  final int? spuId;

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
    id: asInt(json['id']),
    image: asString(json['image'] ?? json['pic'] ?? json['url']),
    linkUrl: optionalString(json['linkUrl'] ?? json['link_url']),
    productId: optionalInt(json['productId'] ?? json['product_id']),
    spuId: optionalInt(json['spuId'] ?? json['spu_id']),
  );
}

class CategoryModel {
  CategoryModel({required this.id, required this.name, this.image, this.type});

  final int id;
  final String name;
  final String? image;
  final String? type;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: asInt(json['id']),
    name: asString(json['name'] ?? json['title']),
    image: optionalString(json['image'] ?? json['icon']),
    type: optionalString(json['type']),
  );
}

class ProductModel {
  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.productId,
    this.spuId,
    this.skuId,
    this.images = const [],
    this.originalPrice,
    this.marketPrice,
    this.seckillPrice,
    this.unit,
    this.origin,
    this.brandName,
    this.categoryId,
    this.stock = 0,
    this.sales = 0,
    this.displayTags = const [],
    this.description,
    this.specs = const [],
    this.reviews = const [],
    this.status,
    this.startTime,
    this.endTime,
    this.progress,
    this.limitPerUser,
    this.shelfLifeDays,
  });

  final int id;
  final int? productId;
  final int? spuId;
  final int? skuId;
  final String name;
  final String image;
  final List<String> images;
  final String price;
  final String? originalPrice;
  final String? marketPrice;
  final String? seckillPrice;
  final String? unit;
  final String? origin;
  final String? brandName;
  final int? categoryId;
  final int stock;
  final int sales;
  final List<String> displayTags;
  final String? description;
  final List<ProductSpecOptionModel> specs;
  final List<ReviewModel> reviews;
  final String? status;
  final String? startTime;
  final String? endTime;
  final int? progress;
  final int? limitPerUser;
  final int? shelfLifeDays;

  int get realProductId => productId ?? spuId ?? id;
  int? get seckillActivityId => productId == null ? null : id;
  int? get routeSeckillId =>
      seckillPrice?.isNotEmpty == true ? seckillActivityId ?? id : null;
  String get displayPrice => _firstNotEmpty([seckillPrice, price, '0']);
  String? get displayOriginalPrice => originalPrice ?? marketPrice;
  String get firstImage =>
      image.isNotEmpty ? image : (images.isNotEmpty ? images.first : '');
  String get displaySubtitle => [
    origin,
    unit,
  ].whereType<String>().where((item) => item.isNotEmpty).join(' · ');

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: asInt(json['id']),
    productId: optionalInt(json['productId'] ?? json['product_id']),
    spuId: optionalInt(json['spuId'] ?? json['spu_id']),
    skuId: optionalInt(json['skuId'] ?? json['sku_id']),
    name: asString(json['name'] ?? json['productName'] ?? json['product_name']),
    image: asString(json['image'] ?? json['mainImage'] ?? json['main_image']),
    images: asStringList(json['images']),
    price: asString(
      json['price'] ?? json['originalPrice'] ?? json['original_price'],
      fallback: '0',
    ),
    originalPrice: optionalString(
      json['originalPrice'] ?? json['original_price'],
    ),
    marketPrice: optionalString(json['marketPrice'] ?? json['market_price']),
    seckillPrice: optionalString(json['seckillPrice'] ?? json['seckill_price']),
    unit: optionalString(json['unit']),
    origin: optionalString(json['origin']),
    brandName: optionalString(json['brandName'] ?? json['brand_name']),
    categoryId: optionalInt(json['categoryId'] ?? json['category_id']),
    stock: asInt(json['stock']),
    sales: asInt(json['sales'] ?? json['soldCount'] ?? json['sold_count']),
    displayTags: asStringList(
      json['displayTags'] ?? json['display_tags'] ?? json['tags'],
    ),
    description: optionalString(json['description'] ?? json['detail']),
    specs: asMapList(
      json['specs'],
    ).map(ProductSpecOptionModel.fromJson).toList(),
    reviews: asMapList(json['reviews']).map(ReviewModel.fromJson).toList(),
    status: optionalString(json['status']),
    startTime: optionalString(json['startTime'] ?? json['start_time']),
    endTime: optionalString(json['endTime'] ?? json['end_time']),
    progress: optionalInt(json['progress']),
    limitPerUser: optionalInt(json['limitPerUser'] ?? json['limit_per_user']),
    shelfLifeDays: optionalInt(
      json['shelfLifeDays'] ?? json['shelf_life_days'],
    ),
  );
}

class ProductSpecOptionModel {
  ProductSpecOptionModel({
    required this.value,
    required this.label,
    this.price,
    this.stock = 0,
    this.skuId,
    this.image,
    this.unit,
  });

  final String value;
  final String label;
  final String? price;
  final int stock;
  final int? skuId;
  final String? image;
  final String? unit;

  factory ProductSpecOptionModel.fromJson(Map<String, dynamic> json) =>
      ProductSpecOptionModel(
        value: asString(json['value'] ?? json['label']),
        label: asString(json['label'] ?? json['value'] ?? json['name']),
        price: optionalString(json['price']),
        stock: asInt(json['stock']),
        skuId: optionalInt(json['skuId'] ?? json['sku_id']),
        image: optionalString(json['image']),
        unit: optionalString(json['unit']),
      );
}

class SeckillSessionModel {
  SeckillSessionModel({
    required this.id,
    required this.name,
    required this.time,
    required this.status,
    required this.statusText,
    this.startTime,
    this.endTime,
  });

  final int id;
  final String name;
  final String time;
  final String status;
  final String statusText;
  final String? startTime;
  final String? endTime;

  String get displayStatusText {
    if (statusText.isNotEmpty) return statusText;
    return status == 'active' ? '抢购中' : '即将开始';
  }

  factory SeckillSessionModel.fromJson(Map<String, dynamic> json) =>
      SeckillSessionModel(
        id: asInt(json['id']),
        name: asString(json['name']),
        time: asString(json['time']),
        status: asString(json['status']),
        statusText: asString(json['statusText'] ?? json['status_text']),
        startTime: optionalString(json['startTime'] ?? json['start_time']),
        endTime: optionalString(json['endTime'] ?? json['end_time']),
      );
}

class ReviewModel {
  ReviewModel({this.user, this.content, this.rating = 0, this.time});

  final String? user;
  final String? content;
  final int rating;
  final String? time;

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    user: optionalString(json['user'] ?? json['nickname']),
    content: optionalString(json['content']),
    rating: asInt(json['rating']),
    time: optionalString(
      json['time'] ?? json['createdAt'] ?? json['created_at'],
    ),
  );
}

class CartItemModel {
  CartItemModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.orderItemId,
    this.cartId,
    this.productId,
    this.spuId,
    this.skuId,
    this.seckillId,
    this.unit,
    this.spec,
    this.categoryName,
    this.quantity = 1,
    this.stock = 0,
    this.selected = true,
    this.isDirectBuy = false,
  });

  final int id;
  final int? orderItemId;
  final int? cartId;
  final int? productId;
  final int? spuId;
  final int? skuId;
  final int? seckillId;
  final String name;
  final String image;
  final String price;
  final String? unit;
  final String? spec;
  final String? categoryName;
  final int quantity;
  final int stock;
  final bool selected;
  final bool isDirectBuy;

  int get displayProductId => productId ?? spuId ?? id;
  int get displayOrderItemId => orderItemId ?? id;
  String get displayName => name;
  String get displayImage => image;
  String get displaySpec => (spec?.isNotEmpty == true ? spec : unit) ?? '';
  double get priceValue => double.tryParse(price) ?? 0;
  double get lineTotal => priceValue * quantity;

  CartItemModel copyWith({int? quantity, bool? selected}) => CartItemModel(
    id: id,
    orderItemId: orderItemId,
    cartId: cartId,
    productId: productId,
    spuId: spuId,
    skuId: skuId,
    seckillId: seckillId,
    name: name,
    image: image,
    price: price,
    unit: unit,
    spec: spec,
    categoryName: categoryName,
    quantity: quantity ?? this.quantity,
    stock: stock,
    selected: selected ?? this.selected,
    isDirectBuy: isDirectBuy,
  );

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: asInt(json['id']),
    orderItemId: optionalInt(json['orderItemId'] ?? json['order_item_id']),
    cartId: optionalInt(json['cartId'] ?? json['cart_id']),
    productId: optionalInt(json['productId'] ?? json['product_id']),
    spuId: optionalInt(json['spuId'] ?? json['spu_id']),
    skuId: optionalInt(json['skuId'] ?? json['sku_id']),
    seckillId: optionalInt(json['seckillId'] ?? json['seckill_id']),
    name: asString(json['name'] ?? json['productName'] ?? json['product_name']),
    image: asString(
      json['image'] ?? json['productImage'] ?? json['product_image'],
    ),
    price: asString(json['price'], fallback: '0'),
    unit: optionalString(json['unit']),
    spec: optionalString(json['spec']),
    categoryName: optionalString(json['categoryName'] ?? json['category_name']),
    quantity: asInt(json['quantity'], fallback: 1),
    stock: asInt(json['stock']),
    selected: asBool(json['selected'], fallback: true),
    isDirectBuy: asBool(json['isDirectBuy'] ?? json['is_direct_buy']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderItemId': orderItemId,
    'cartId': cartId,
    'productId': productId,
    'spuId': spuId,
    'skuId': skuId,
    'seckillId': seckillId,
    'name': name,
    'image': image,
    'price': price,
    'unit': unit,
    'spec': spec,
    'categoryName': categoryName,
    'quantity': quantity,
    'stock': stock,
    'selected': selected,
    'isDirectBuy': isDirectBuy,
  };
}

class UserModel {
  UserModel({this.id = 0, this.nickname, this.avatar, this.phone});

  final int id;
  final String? nickname;
  final String? avatar;
  final String? phone;

  String get displayName => nickname?.isNotEmpty == true ? nickname! : '未登录';

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: asInt(json['id']),
    nickname: optionalString(json['nickname'] ?? json['nickName']),
    avatar: optionalString(json['avatar']),
    phone: optionalString(
      json['phone'] ?? json['mobile'] ?? json['phoneNumber'],
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'avatar': avatar,
    'phone': phone,
  };
}

class LoginResultModel {
  LoginResultModel({required this.token, this.userInfo});

  final String token;
  final UserModel? userInfo;

  factory LoginResultModel.fromJson(Map<String, dynamic> json) =>
      LoginResultModel(
        token: asString(json['token']),
        userInfo: json['userInfo'] is Map
            ? UserModel.fromJson(
                Map<String, dynamic>.from(json['userInfo'] as Map),
              )
            : json['user_info'] is Map
            ? UserModel.fromJson(
                Map<String, dynamic>.from(json['user_info'] as Map),
              )
            : null,
      );
}

class AddressModel {
  AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.province,
    required this.city,
    required this.district,
    required this.detail,
    this.isDefault = false,
  });

  final int id;
  final String name;
  final String phone;
  final String province;
  final String city;
  final String district;
  final String detail;
  final bool isDefault;

  String get fullAddress => [
    province,
    city,
    district,
    detail,
  ].where((item) => item.isNotEmpty).join(' ');

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: asInt(json['id']),
    name: asString(json['name']),
    phone: asString(json['phone']),
    province: asString(json['province']),
    city: asString(json['city']),
    district: asString(json['district']),
    detail: asString(json['detail']),
    isDefault: asBool(json['isDefault'] ?? json['is_default']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'province': province,
    'city': city,
    'district': district,
    'detail': detail,
    'isDefault': isDefault,
  };

  AddressModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? province,
    String? city,
    String? district,
    String? detail,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      province: province ?? this.province,
      city: city ?? this.city,
      district: district ?? this.district,
      detail: detail ?? this.detail,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class CouponModel {
  CouponModel({
    required this.id,
    this.couponId,
    this.name = '',
    this.title,
    this.type,
    this.discount,
    this.discountValue = 0,
    this.amount,
    this.minAmount,
    this.startTime,
    this.startDate,
    this.endTime,
    this.endDate,
    this.status = 0,
    this.value,
    this.description,
    this.received = false,
  });

  final int id;
  final int? couponId;
  final String name;
  final String? title;
  final String? type;
  final String? discount;
  final double discountValue;
  final String? amount;
  final String? minAmount;
  final String? startTime;
  final String? startDate;
  final String? endTime;
  final String? endDate;
  final int status;
  final String? value;
  final String? description;
  final bool received;

  String get displayTitle => title?.isNotEmpty == true ? title! : name;

  String get displaySubtitle {
    final threshold = minAmount?.isNotEmpty == true ? '满$minAmount可用' : '无门槛';
    return [
      description?.isNotEmpty == true ? description : threshold,
      endTime ?? endDate,
    ].whereType<String>().where((item) => item.isNotEmpty).join(' · ');
  }

  String get displayBadge {
    if (discountValue > 0) return '-¥${_formatAmount(discountValue)}';
    if (type == 'discount' && value != null) {
      final number = double.tryParse(value!);
      if (number != null) return '${_formatAmount(number * 10)}折';
    }
    if (value?.isNotEmpty == true) return '¥$value';
    return discount ?? amount ?? '优惠券';
  }

  String get couponValue {
    if (type == 'discount' && value != null) {
      final number = double.tryParse(value!);
      if (number != null) return '${_formatAmount(number * 10)}折';
    }
    return '¥${value ?? amount ?? '0'}';
  }

  String get limitText =>
      minAmount?.isNotEmpty == true ? '满$minAmount可用' : '无门槛';

  String get expireText => '有效期至 ${endDate ?? endTime ?? '-'}';

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
    id: asInt(json['id']),
    couponId: optionalInt(json['couponId'] ?? json['coupon_id']),
    name: asString(json['name']),
    title: optionalString(json['title']),
    type: optionalString(json['type']),
    discount: optionalString(json['discount']),
    discountValue: asDouble(json['discount']),
    amount: optionalString(json['amount']),
    minAmount: optionalString(json['minAmount'] ?? json['min_amount']),
    startTime: optionalString(json['startTime'] ?? json['start_time']),
    startDate: optionalString(json['startDate']),
    endTime: optionalString(json['endTime'] ?? json['end_time']),
    endDate: optionalString(json['endDate']),
    status: asInt(json['status']),
    value: optionalString(json['value']),
    description: optionalString(json['description']),
    received: asBool(json['received']),
  );
}

class FavoriteCheckModel {
  FavoriteCheckModel({this.isFavorite = false});

  final bool isFavorite;

  factory FavoriteCheckModel.fromJson(Map<String, dynamic> json) =>
      FavoriteCheckModel(
        isFavorite: asBool(
          json['isFavorite'] ?? json['is_favorite'] ?? json['favorite'],
        ),
      );
}

class BrandModel {
  BrandModel({
    required this.id,
    required this.name,
    this.logo,
    this.description,
    this.followed = false,
    this.categoryName,
    this.categories = const [],
    this.productCount = 0,
    this.products = const [],
  });

  final int id;
  final String name;
  final String? logo;
  final String? description;
  final bool followed;
  final String? categoryName;
  final List<BrandCategoryModel> categories;
  final int productCount;
  final List<ProductModel> products;

  String get displayTitle => name;
  String get displaySubtitle => description ?? '';
  String get displayBadge => followed ? '已关注' : '品牌';
  String get displayCategory =>
      categoryName ?? (categories.isNotEmpty ? categories.first.name : '农品优选');
  List<String> get categoryNames =>
      categories.map((item) => item.name).toList();

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
    id: asInt(json['id']),
    name: asString(json['name']),
    logo: optionalString(json['logo']),
    description: optionalString(json['description']),
    followed: asBool(json['followed']),
    categoryName: optionalString(json['categoryName'] ?? json['category_name']),
    categories: asMapList(
      json['categories'],
    ).map(BrandCategoryModel.fromJson).toList(),
    productCount: asInt(json['productCount'] ?? json['product_count']),
    products: asMapList(json['products']).map(ProductModel.fromJson).toList(),
  );
}

class BrandCategoryModel {
  BrandCategoryModel({required this.id, required this.name});

  final int id;
  final String name;

  factory BrandCategoryModel.fromJson(Map<String, dynamic> json) =>
      BrandCategoryModel(id: asInt(json['id']), name: asString(json['name']));
}

class MessageModel {
  MessageModel({
    this.id = 0,
    this.title = '',
    this.content,
    this.type,
    this.orderId,
    this.orderNo,
    this.time,
    this.createdAt,
    this.isRead = false,
  });

  final int id;
  final String title;
  final String? content;
  final String? type;
  final int? orderId;
  final String? orderNo;
  final String? time;
  final String? createdAt;
  final bool isRead;

  String get displayTitle => title;
  String get displaySubtitle => content?.isNotEmpty == true
      ? content!
      : formatServerTime(time ?? createdAt);
  String get displayBadge => isRead ? '已读' : '未读';
  String get displayTime => formatServerTime(time ?? createdAt);

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: asInt(json['id']),
    title: asString(json['title']),
    content: optionalString(json['content']),
    type: optionalString(json['type']),
    orderId: optionalInt(json['orderId'] ?? json['order_id']),
    orderNo: optionalString(json['orderNo'] ?? json['order_no']),
    time: optionalString(json['time']),
    createdAt: optionalString(json['createdAt'] ?? json['created_at']),
    isRead: asBool(json['isRead'] ?? json['is_read']),
  );
}

class OrderCreateResultModel {
  OrderCreateResultModel({this.orderNo = '', this.orderNoSnake = ''});

  final String orderNo;
  final String orderNoSnake;

  String get displayOrderNo => orderNo.isNotEmpty ? orderNo : orderNoSnake;

  factory OrderCreateResultModel.fromJson(Map<String, dynamic> json) =>
      OrderCreateResultModel(
        orderNo: asString(json['orderNo']),
        orderNoSnake: asString(json['order_no']),
      );
}

class OrderPreviewModel {
  OrderPreviewModel({
    this.items = const [],
    this.itemCount = 0,
    this.originalAmount = '0.00',
    this.memberLevel,
    this.memberDiscountAmount = '0.00',
    this.selectedCouponId,
    this.couponDiscountAmount = '0.00',
    this.discountAmount = '0.00',
    this.freightAmount = '0.00',
    this.payableAmount = '0.00',
    this.totalAmount = '0.00',
    this.earnPoints = 0,
    this.availableCoupons = const [],
  });

  final List<CartItemModel> items;
  final int itemCount;
  final String originalAmount;
  final String? memberLevel;
  final String memberDiscountAmount;
  final int? selectedCouponId;
  final String couponDiscountAmount;
  final String discountAmount;
  final String freightAmount;
  final String payableAmount;
  final String totalAmount;
  final int earnPoints;
  final List<CouponModel> availableCoupons;

  factory OrderPreviewModel.fromJson(Map<String, dynamic> json) =>
      OrderPreviewModel(
        items: asMapList(json['items']).map(CartItemModel.fromJson).toList(),
        itemCount: asInt(json['itemCount'] ?? json['item_count']),
        originalAmount: asString(
          json['originalAmount'] ?? json['original_amount'],
          fallback: '0.00',
        ),
        memberLevel: optionalString(
          json['memberLevel'] ?? json['member_level'],
        ),
        memberDiscountAmount: asString(
          json['memberDiscountAmount'] ?? json['member_discount_amount'],
          fallback: '0.00',
        ),
        selectedCouponId: optionalInt(
          json['selectedCouponId'] ?? json['selected_coupon_id'],
        ),
        couponDiscountAmount: asString(
          json['couponDiscountAmount'] ?? json['coupon_discount_amount'],
          fallback: '0.00',
        ),
        discountAmount: asString(
          json['discountAmount'] ?? json['discount_amount'],
          fallback: '0.00',
        ),
        freightAmount: asString(
          json['freightAmount'] ?? json['freight_amount'],
          fallback: '0.00',
        ),
        payableAmount: asString(
          json['payableAmount'] ?? json['payable_amount'],
          fallback: '0.00',
        ),
        totalAmount: asString(
          json['totalAmount'] ?? json['total_amount'],
          fallback: '0.00',
        ),
        earnPoints: asInt(json['earnPoints'] ?? json['earn_points']),
        availableCoupons: asMapList(
          json['availableCoupons'] ?? json['available_coupons'],
        ).map(CouponModel.fromJson).toList(),
      );
}

class PaymentResultModel {
  PaymentResultModel({
    this.h5Url,
    this.appPayParams,
    this.paymentMode,
    this.synced = false,
  });

  final String? h5Url;
  final WechatAppPayParamsModel? appPayParams;
  final String? paymentMode;
  final bool synced;

  factory PaymentResultModel.fromJson(Map<String, dynamic> json) {
    final payParams = _nestedMap(json['payParams'] ?? json['pay_params']);
    final wxPayParams = _nestedMap(
      json['wxPayParams'] ?? json['wx_pay_params'],
    );
    final directH5Url = optionalString(
      json['h5Url'] ?? json['h5_url'] ?? json['mwebUrl'] ?? json['mweb_url'],
    );
    final nestedH5Url = _nestedH5Url(payParams) ?? _nestedH5Url(wxPayParams);
    final appParamsJson = _containsAppPayParams(payParams)
        ? payParams
        : _containsAppPayParams(wxPayParams)
        ? wxPayParams
        : _containsAppPayParams(json)
        ? json
        : null;
    return PaymentResultModel(
      h5Url: directH5Url?.isNotEmpty == true ? directH5Url : nestedH5Url,
      appPayParams: appParamsJson == null
          ? null
          : WechatAppPayParamsModel.fromJson(appParamsJson),
      paymentMode: optionalString(json['paymentMode'] ?? json['payment_mode']),
      synced: asBool(json['synced']),
    );
  }

  static Map<String, dynamic>? _nestedMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String? _nestedH5Url(Map<String, dynamic>? value) {
    if (value == null) return null;
    return optionalString(
      value['h5Url'] ??
          value['h5_url'] ??
          value['mwebUrl'] ??
          value['mweb_url'],
    );
  }

  static bool _containsAppPayParams(Map<String, dynamic>? value) {
    if (value == null) return false;
    return value.containsKey('prepayId') || value.containsKey('prepay_id');
  }
}

class WechatAppPayParamsModel {
  WechatAppPayParamsModel({
    required this.appId,
    required this.partnerId,
    required this.prepayId,
    required this.nonceStr,
    required this.timestamp,
    required this.packageValue,
    required this.sign,
    this.signType,
    this.extData,
  });

  final String appId;
  final String partnerId;
  final String prepayId;
  final String nonceStr;
  final int timestamp;
  final String packageValue;
  final String sign;
  final String? signType;
  final String? extData;

  bool get isValid =>
      appId.isNotEmpty &&
      partnerId.isNotEmpty &&
      prepayId.isNotEmpty &&
      nonceStr.isNotEmpty &&
      timestamp > 0 &&
      packageValue.isNotEmpty &&
      sign.isNotEmpty;

  factory WechatAppPayParamsModel.fromJson(Map<String, dynamic> json) {
    return WechatAppPayParamsModel(
      appId: asString(json['appId'] ?? json['appid']),
      partnerId: asString(
        json['partnerId'] ??
            json['partnerid'] ??
            json['mchId'] ??
            json['mchid'],
      ),
      prepayId: asString(
        json['prepayId'] ?? json['prepayid'] ?? json['prepay_id'],
      ),
      nonceStr: asString(
        json['nonceStr'] ?? json['noncestr'] ?? json['nonce_str'],
      ),
      timestamp: asInt(
        json['timeStamp'] ?? json['timestamp'] ?? json['time_stamp'],
      ),
      packageValue: asString(
        json['package'] ?? json['packageValue'] ?? json['package_value'],
        fallback: 'Sign=WXPay',
      ),
      sign: asString(json['sign'] ?? json['paySign'] ?? json['pay_sign']),
      signType: optionalString(json['signType'] ?? json['sign_type']),
      extData: optionalString(json['extData'] ?? json['ext_data']),
    );
  }
}

class OrderModel {
  OrderModel({
    this.id = 0,
    required this.orderNo,
    required this.status,
    required this.totalAmount,
    this.statusText,
    this.totalPrice,
    this.originalAmount,
    this.discountAmount,
    this.couponDiscount,
    this.freightAmount,
    this.createTime,
    this.createdAt,
    this.payTime,
    this.shipTime,
    this.completeTime,
    this.address,
    this.logistics,
    this.receiverName,
    this.receiverPhone,
    this.receiverAddress,
    this.afterSaleStatus,
    this.reviewed = false,
    this.afterSales = const [],
    this.items = const [],
  });

  final int id;
  final String orderNo;
  final String status;
  final String totalAmount;
  final String? statusText;
  final String? totalPrice;
  final String? originalAmount;
  final String? discountAmount;
  final String? couponDiscount;
  final String? freightAmount;
  final String? createTime;
  final String? createdAt;
  final String? payTime;
  final String? shipTime;
  final String? completeTime;
  final AddressModel? address;
  final LogisticsModel? logistics;
  final String? receiverName;
  final String? receiverPhone;
  final String? receiverAddress;
  final String? afterSaleStatus;
  final bool reviewed;
  final List<AfterSaleModel> afterSales;
  final List<CartItemModel> items;

  String get normalizedStatus {
    if (status == 'pending') return 'pending_pay';
    if (status == 'paid') return 'pending_ship';
    return status;
  }

  String get displayStatusText => statusText?.isNotEmpty == true
      ? statusText!
      : {
              'pending_pay': '待付款',
              'pending_ship': '待发货',
              'shipped': '待收货',
              'completed': '已完成',
              'cancelled': '已取消',
            }[normalizedStatus] ??
            normalizedStatus;

  List<CartItemModel> get displayItems => items;
  String get displayTime => formatServerTime(createTime ?? createdAt);
  String get displayPayTime => formatServerTime(payTime);
  String get displayShipTime => formatServerTime(shipTime);
  String get displayCompleteTime => formatServerTime(completeTime);
  String get displayAddress => address?.fullAddress ?? receiverAddress ?? '';
  String get displayTotalAmount => totalPrice ?? totalAmount;
  int get totalCount =>
      displayItems.fold(0, (sum, item) => sum + item.quantity);
  bool get canApplyAfterSale {
    final flag = afterSaleStatus ?? '';
    return normalizedStatus == 'completed' &&
        afterSales.isEmpty &&
        (flag.isEmpty || flag == 'none');
  }

  AfterSaleModel? get currentAfterSale =>
      afterSales.isNotEmpty ? afterSales.first : null;
  AfterSaleModel? get activeReturnAfterSale {
    for (final item in afterSales) {
      if (item.type == 'return_refund' && item.status == 'approved') {
        return item;
      }
    }
    return null;
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: asInt(json['id']),
    orderNo: asString(json['orderNo'] ?? json['order_no']),
    status: asString(json['status']),
    totalAmount: asString(
      json['totalAmount'] ?? json['total_amount'],
      fallback: '0.00',
    ),
    statusText: optionalString(json['statusText'] ?? json['status_text']),
    totalPrice: optionalString(json['totalPrice'] ?? json['total_price']),
    originalAmount: optionalString(
      json['originalAmount'] ?? json['original_amount'],
    ),
    discountAmount: optionalString(
      json['discountAmount'] ?? json['discount_amount'],
    ),
    couponDiscount: optionalString(
      json['couponDiscount'] ?? json['coupon_discount'],
    ),
    freightAmount: optionalString(
      json['freightAmount'] ?? json['freight_amount'],
    ),
    createTime: optionalString(json['createTime'] ?? json['create_time']),
    createdAt: optionalString(json['createdAt'] ?? json['created_at']),
    payTime: optionalString(json['payTime'] ?? json['pay_time']),
    shipTime: optionalString(json['shipTime'] ?? json['ship_time']),
    completeTime: optionalString(json['completeTime'] ?? json['complete_time']),
    address: _mapObject(
      json['address'] ?? json['addressSnapshot'] ?? json['address_snapshot'],
      AddressModel.fromJson,
    ),
    logistics: _mapObject(json['logistics'], LogisticsModel.fromJson),
    receiverName: optionalString(json['receiverName'] ?? json['receiver_name']),
    receiverPhone: optionalString(
      json['receiverPhone'] ?? json['receiver_phone'],
    ),
    receiverAddress: optionalString(
      json['receiverAddress'] ?? json['receiver_address'],
    ),
    afterSaleStatus: optionalString(
      json['afterSaleStatus'] ?? json['after_sale_status'],
    ),
    reviewed: asBool(json['reviewed']),
    afterSales: asMapList(
      json['afterSales'] ?? json['after_sales'],
    ).map(AfterSaleModel.fromJson).toList(),
    items: asMapList(
      json['items'] ?? json['products'],
    ).map(CartItemModel.fromJson).toList(),
  );
}

class LogisticsModel {
  LogisticsModel({
    this.company,
    this.trackingNo,
    this.status,
    this.statusText,
    this.traces = const [],
  });

  final String? company;
  final String? trackingNo;
  final String? status;
  final String? statusText;
  final List<LogisticsTraceModel> traces;

  String get displayStatusText {
    if (statusText?.isNotEmpty == true) return statusText!;
    final raw = (status ?? '').trim();
    if (raw.isEmpty) return '运输中';
    final normalized = raw.toLowerCase().replaceAll('-', '_');
    return {
          'pending': '待揽收',
          'created': '待揽收',
          'accepted': '已揽收',
          'picked_up': '已揽收',
          'pickup': '已揽收',
          'collected': '已揽收',
          'shipping': '运输中',
          'shipped': '运输中',
          'in_transit': '运输中',
          'transit': '运输中',
          'delivering': '派送中',
          'out_for_delivery': '派送中',
          'delivered': '已签收',
          'signed': '已签收',
          'signed_for': '已签收',
          'completed': '已完成',
          'exception': '物流异常',
          'failed': '派送失败',
          'cancelled': '已取消',
          'canceled': '已取消',
          'returned': '已退回',
          'returning': '退回中',
        }[normalized] ??
        (_containsNonAscii(raw) ? raw : '运输中');
  }

  factory LogisticsModel.fromJson(Map<String, dynamic> json) => LogisticsModel(
    company: optionalString(json['company']),
    trackingNo: optionalString(json['trackingNo'] ?? json['tracking_no']),
    status: optionalString(json['status']),
    statusText: optionalString(json['statusText'] ?? json['status_text']),
    traces: asMapList(
      json['traces'],
    ).map(LogisticsTraceModel.fromJson).toList(),
  );
}

bool _containsNonAscii(String value) => value.runes.any((item) => item > 127);

class LogisticsTraceModel {
  LogisticsTraceModel({this.time, this.content, this.desc});

  final String? time;
  final String? content;
  final String? desc;

  String get displayContent => content ?? desc ?? '';
  String get displayTime => formatServerTime(time);

  factory LogisticsTraceModel.fromJson(Map<String, dynamic> json) =>
      LogisticsTraceModel(
        time: optionalString(json['time']),
        content: optionalString(json['content']),
        desc: optionalString(json['desc']),
      );
}

class AfterSaleModel {
  AfterSaleModel({
    this.id = 0,
    this.afterSaleNo = '',
    this.type = '',
    this.status = '',
    this.reason = '',
    this.description,
    this.images = const [],
    this.refundAmount = '0.00',
    this.rejectReason,
    this.returnTrackingNo,
    this.completedAt,
    this.order,
    this.items = const [],
    this.logs = const [],
    this.refundOrders = const [],
    this.createdAt,
  });

  final int id;
  final String afterSaleNo;
  final String type;
  final String status;
  final String reason;
  final String? description;
  final List<String> images;
  final String refundAmount;
  final String? rejectReason;
  final String? returnTrackingNo;
  final String? completedAt;
  final AfterSaleOrderModel? order;
  final List<AfterSaleItemModel> items;
  final List<AfterSaleLogModel> logs;
  final List<RefundOrderModel> refundOrders;
  final String? createdAt;

  String get displayTitle => afterSaleNo.isEmpty ? '售后单' : afterSaleNo;
  String get displaySubtitle => '退款金额 ¥$refundAmount · $reason';
  String get displayBadge => statusText;
  String get statusText =>
      {
        'applied': '待审核',
        'approved': '已通过',
        'rejected': '已拒绝',
        'returned': '已寄回',
        'refunding': '退款中',
        'completed': '已完成',
      }[status] ??
      status;
  String get typeText =>
      {'refund_only': '仅退款', 'return_refund': '退货退款', 'exchange': '换货'}[type] ??
      type;
  bool get canSubmitReturnLogistics =>
      type == 'return_refund' && status == 'approved';

  factory AfterSaleModel.fromJson(Map<String, dynamic> json) => AfterSaleModel(
    id: asInt(json['id']),
    afterSaleNo: asString(json['afterSaleNo'] ?? json['after_sale_no']),
    type: asString(json['type']),
    status: asString(json['status']),
    reason: asString(json['reason']),
    description: optionalString(json['description']),
    images: asStringList(json['images']),
    refundAmount: asString(
      json['refundAmount'] ?? json['refund_amount'],
      fallback: '0.00',
    ),
    rejectReason: optionalString(json['rejectReason'] ?? json['reject_reason']),
    returnTrackingNo: optionalString(
      json['returnTrackingNo'] ?? json['return_tracking_no'],
    ),
    completedAt: optionalString(json['completedAt'] ?? json['completed_at']),
    order: _mapObject(json['order'], AfterSaleOrderModel.fromJson),
    items: asMapList(json['items']).map(AfterSaleItemModel.fromJson).toList(),
    logs: asMapList(json['logs']).map(AfterSaleLogModel.fromJson).toList(),
    refundOrders: asMapList(
      json['refundOrders'] ?? json['refund_orders'],
    ).map(RefundOrderModel.fromJson).toList(),
    createdAt: optionalString(json['createdAt'] ?? json['created_at']),
  );
}

class AfterSaleOrderModel {
  AfterSaleOrderModel({
    this.orderNo = '',
    this.status,
    this.totalPrice,
    this.createdAt,
  });

  final String orderNo;
  final String? status;
  final String? totalPrice;
  final String? createdAt;

  factory AfterSaleOrderModel.fromJson(Map<String, dynamic> json) =>
      AfterSaleOrderModel(
        orderNo: asString(json['orderNo'] ?? json['order_no']),
        status: optionalString(json['status']),
        totalPrice: optionalString(json['totalPrice'] ?? json['total_price']),
        createdAt: optionalString(json['createdAt'] ?? json['created_at']),
      );
}

class AfterSaleItemModel {
  AfterSaleItemModel({
    this.id = 0,
    this.orderItemId,
    this.skuId,
    this.quantity = 0,
    this.refundAmount = '0.00',
  });

  final int id;
  final int? orderItemId;
  final int? skuId;
  final int quantity;
  final String refundAmount;

  factory AfterSaleItemModel.fromJson(Map<String, dynamic> json) =>
      AfterSaleItemModel(
        id: asInt(json['id']),
        orderItemId: optionalInt(json['orderItemId'] ?? json['order_item_id']),
        skuId: optionalInt(json['skuId'] ?? json['sku_id']),
        quantity: asInt(json['quantity']),
        refundAmount: asString(
          json['refundAmount'] ?? json['refund_amount'],
          fallback: '0.00',
        ),
      );
}

class AfterSaleLogModel {
  AfterSaleLogModel({
    this.id = 0,
    this.fromStatus,
    this.toStatus,
    this.remark,
    this.createdAt,
  });

  final int id;
  final String? fromStatus;
  final String? toStatus;
  final String? remark;
  final String? createdAt;

  String get displayTime => formatServerTime(createdAt);
  String get displayStatus => _afterSaleStatusText(toStatus);

  factory AfterSaleLogModel.fromJson(Map<String, dynamic> json) =>
      AfterSaleLogModel(
        id: asInt(json['id']),
        fromStatus: optionalString(json['fromStatus'] ?? json['from_status']),
        toStatus: optionalString(json['toStatus'] ?? json['to_status']),
        remark: optionalString(json['remark']),
        createdAt: optionalString(json['createdAt'] ?? json['created_at']),
      );
}

class RefundOrderModel {
  RefundOrderModel({
    this.id = 0,
    this.refundNo = '',
    this.channel,
    this.amount = '0.00',
    this.status = '',
    this.reason,
    this.refundedAt,
  });

  final int id;
  final String refundNo;
  final String? channel;
  final String amount;
  final String status;
  final String? reason;
  final String? refundedAt;

  String get displayRefundedAt => formatServerTime(refundedAt);
  String get displayStatus =>
      {
        'pending': '待退款',
        'processing': '退款中',
        'success': '已退款',
        'completed': '已完成',
        'failed': '退款失败',
        'closed': '已关闭',
      }[status] ??
      status;

  factory RefundOrderModel.fromJson(Map<String, dynamic> json) =>
      RefundOrderModel(
        id: asInt(json['id']),
        refundNo: asString(json['refundNo'] ?? json['refund_no']),
        channel: optionalString(json['channel']),
        amount: asString(json['amount'], fallback: '0.00'),
        status: asString(json['status']),
        reason: optionalString(json['reason']),
        refundedAt: optionalString(json['refundedAt'] ?? json['refunded_at']),
      );
}

class OrderStatsModel {
  OrderStatsModel({
    this.pendingPay = 0,
    this.pendingShip = 0,
    this.pendingReceive = 0,
    this.pendingReview = 0,
  });

  final int pendingPay;
  final int pendingShip;
  final int pendingReceive;
  final int pendingReview;

  factory OrderStatsModel.fromJson(Map<String, dynamic> json) =>
      OrderStatsModel(
        pendingPay: asInt(json['pendingPay'] ?? json['pending_pay']),
        pendingShip: asInt(json['pendingShip'] ?? json['pending_ship']),
        pendingReceive: asInt(
          json['pendingReceive'] ?? json['pending_receive'] ?? json['shipped'],
        ),
        pendingReview: asInt(json['pendingReview'] ?? json['pending_review']),
      );
}

class MemberInfoModel {
  MemberInfoModel({
    this.levelName = '普通会员',
    this.points = 0,
    this.level = 0,
    this.discountText,
    this.discount = 1,
    this.icon = '👤',
    this.nextLevel,
    this.progressPercent = 0,
    this.levels = const [],
  });

  final String levelName;
  final int points;
  final int level;
  final String? discountText;
  final double discount;
  final String icon;
  final MemberLevelModel? nextLevel;
  final double progressPercent;
  final List<MemberLevelModel> levels;

  factory MemberInfoModel.fromJson(Map<String, dynamic> json) =>
      MemberInfoModel(
        levelName: asString(
          json['levelName'] ?? json['level_name'] ?? json['level'],
          fallback: '普通会员',
        ),
        points: asInt(json['points']),
        level: asInt(json['level']),
        discountText: optionalString(
          json['discountText'] ?? json['discount_text'] ?? json['discount'],
        ),
        discount: asDouble(json['discount'], fallback: 1),
        icon: asString(json['icon'], fallback: '👤'),
        nextLevel: _mapObject(
          json['nextLevel'] ?? json['next_level'],
          MemberLevelModel.fromJson,
        ),
        progressPercent: asDouble(
          json['progressPercent'] ?? json['progress_percent'],
        ),
        levels: asMapList(
          json['levels'],
        ).map(MemberLevelModel.fromJson).toList(),
      );
}

class MemberLevelModel {
  MemberLevelModel({
    this.level = 0,
    this.name = '',
    this.minPoints = 0,
    this.discount,
    this.discountValue,
    this.discountText,
    this.icon,
  });

  final int level;
  final String name;
  final int minPoints;
  final String? discount;
  final double? discountValue;
  final String? discountText;
  final String? icon;

  String get displayName => [
    icon,
    name,
  ].whereType<String>().where((item) => item.isNotEmpty).join(' ');
  String get displayDiscount {
    if (discount?.isNotEmpty == true) return discount!;
    if (discountText?.isNotEmpty == true) return discountText!;
    if (discountValue != null && discountValue! > 0 && discountValue! < 1) {
      return '${_formatAmount(discountValue! * 10)}折';
    }
    return '无';
  }

  factory MemberLevelModel.fromJson(Map<String, dynamic> json) =>
      MemberLevelModel(
        level: asInt(json['level']),
        name: asString(json['name']),
        minPoints: asInt(json['minPoints'] ?? json['min_points']),
        discount: optionalString(json['discount']),
        discountValue: optionalDouble(json['discount']),
        discountText: optionalString(
          json['discountText'] ?? json['discount_text'],
        ),
        icon: optionalString(json['icon']),
      );
}

class PointsHistoryModel {
  PointsHistoryModel({
    this.id = 0,
    this.title = '',
    this.points = 0,
    this.time,
    this.createdAt,
  });

  final int id;
  final String title;
  final int points;
  final String? time;
  final String? createdAt;

  String get displayTime => formatServerTime(time ?? createdAt);

  factory PointsHistoryModel.fromJson(Map<String, dynamic> json) =>
      PointsHistoryModel(
        id: asInt(json['id']),
        title: asString(json['title']),
        points: asInt(json['points']),
        time: optionalString(json['time']),
        createdAt: optionalString(json['createdAt'] ?? json['created_at']),
      );
}

int asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? optionalInt(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return asInt(value);
}

String asString(dynamic value, {String fallback = ''}) {
  final text = value?.toString() ?? '';
  return text.isEmpty ? fallback : text;
}

String? optionalString(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

bool asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return fallback;
}

double asDouble(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? optionalDouble(dynamic value) {
  if (value == null || value.toString().isEmpty) return null;
  return asDouble(value);
}

List<String> asStringList(dynamic value) {
  if (value is List) {
    return value
        .expand((item) => asStringList(item))
        .where((item) => item.isNotEmpty)
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) {
    return value
        .split(RegExp(r'[,，、\s]+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return <String>[];
}

List<Map<String, dynamic>> asMapList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  return <Map<String, dynamic>>[];
}

T? _mapObject<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  if (value is Map<String, dynamic>) return fromJson(value);
  if (value is Map) return fromJson(Map<String, dynamic>.from(value));
  return null;
}

String _firstNotEmpty(List<String?> values) {
  return values.firstWhere((item) => item != null && item.isNotEmpty) ?? '';
}

String _formatAmount(double value) {
  if (value.roundToDouble() == value) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _afterSaleStatusText(String? status) {
  return {
        'applied': '提交申请',
        'approved': '审核通过',
        'rejected': '审核拒绝',
        'returned': '买家已寄回',
        'refunding': '退款中',
        'completed': '处理完成',
      }[status] ??
      (status?.isNotEmpty == true ? status! : '售后进度');
}

String formatServerTime(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '';
  var normalized = text;
  if (RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}').hasMatch(text)) {
    normalized = text.replaceFirst(' ', 'T');
  }
  try {
    final date = DateTime.parse(normalized).toLocal();
    return [
      date.year.toString().padLeft(4, '0'),
      '-',
      date.month.toString().padLeft(2, '0'),
      '-',
      date.day.toString().padLeft(2, '0'),
      ' ',
      date.hour.toString().padLeft(2, '0'),
      ':',
      date.minute.toString().padLeft(2, '0'),
      ':',
      date.second.toString().padLeft(2, '0'),
    ].join();
  } catch (_) {
    return text
        .replaceFirst('T', ' ')
        .replaceFirst(RegExp(r'\.\d+Z$'), '')
        .replaceFirst(RegExp(r'Z$'), '');
  }
}

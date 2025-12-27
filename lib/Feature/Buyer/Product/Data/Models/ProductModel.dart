class ProductModel {
  final int id;
  final String name;
  final String code;
  final double price;
  final double priceAfterDiscount;
  final int discount;
  final String description;
  final String categoryName;
  final int? categoryId; // added
  final bool isDelivered;
  final bool isInstallment;
  final String status;
  final int totalRate;
  final double avgRate;
  final List<String> images;
  bool isFavorite;
  final String? currencyType;

  ProductModel({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    required this.priceAfterDiscount,
    required this.discount,
    required this.description,
    required this.categoryName,
    this.categoryId,
    required this.isDelivered,
    required this.isInstallment,
    required this.status,
    required this.totalRate,
    required this.avgRate,
    required this.images,
    required this.isFavorite,
    this.currencyType, // أضف هذا
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // helpers
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      final s = v.toString();
      return double.tryParse(s) ?? 0.0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    bool _toBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final s = v.toString().toLowerCase();
      if (s == '1' || s == 'true') return true;
      return false;
    }

    List<String> _extractImages(dynamic v) {
      try {
        if (v == null) return [];
        if (v is List) return v.map((e) => e.toString()).toList();
        if (v is String) return [v];
      } catch (_) {}
      return [];
    }

    // Attempt to find images under multiple possible keys
    List<String> imageList = [];
    imageList = _extractImages(json['images'])
        .followedBy(_extractImages(json['image']))
        .toList();
    if (imageList.isEmpty && json['photos'] != null) {
      imageList = _extractImages(json['photos']);
    }

    final id = _toInt(json['id'] ?? json['product_id'] ?? json['pid']);
    final name = (json['name'] ?? json['title'] ?? '').toString();
    final code = (json['code'] ?? json['sku'] ?? '').toString();
    final price = _toDouble(json['price'] ?? json['cost'] ?? 0);

    final priceAfterDiscount = _toDouble(json['priceAfterDiscount'] ?? json['price_after_discount'] ?? json['discount_price'] ?? json['discounted_price'] ?? 0);
    final discount = _toInt(json['discount'] ?? json['discount_percentage'] ?? 0);
    final description = (json['description'] ?? json['desc'] ?? '').toString();
    final categoryName = (json['categoryName'] ?? json['category_name'] ?? json['category'] ?? '').toString();
    final categoryId = json['category_id'] != null ? _toInt(json['category_id']) : (json['categoryId'] != null ? _toInt(json['categoryId']) : null);
    final isDelivered = _toBool(json['is_deliverd'] ?? json['is_delivered'] ?? json['delivered']);
    final isInstallment = _toBool(json['is_installment'] ?? json['installment'] ?? json['isInstallment']);
    final status = (json['status'] ?? '').toString();
    final totalRate = _toInt(json['total_rate'] ?? json['totalRate'] ?? json['ratings_count']);
    final avgRate = _toDouble(json['avg_rate'] ?? json['avgRate'] ?? json['rating'] ?? json['average_rate']);
    final isFavorite = (json['is_favorite'] ?? json['isFavorite'] ?? false) as dynamic;
    final currencyType = (json['currency_type'] ?? json['currencyType'] ?? json['currency'])?.toString();

    return ProductModel(
      id: id,
      name: name,
      code: code,
      price: price,
      priceAfterDiscount: priceAfterDiscount,
      discount: discount,
      description: description,
      categoryName: categoryName,
      categoryId: categoryId,
      isDelivered: isDelivered,
      isInstallment: isInstallment,
      status: status,
      totalRate: totalRate,
      avgRate: avgRate,
      images: imageList,
      isFavorite: isFavorite is bool ? isFavorite : (isFavorite is int ? isFavorite == 1 : false),
      currencyType: currencyType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'price': price,
      'priceAfterDiscount': priceAfterDiscount,
      'discount': discount,
      'description': description,
      'categoryName': categoryName,
      'categoryId': categoryId,
      'isDelivered': isDelivered,
      'isInstallment': isInstallment,
      'status': status,
      'totalRate': totalRate,
      'avgRate': avgRate,
      'images': images,
      'isFavorite': isFavorite,
      'currency_type': currencyType,
    };
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }
}
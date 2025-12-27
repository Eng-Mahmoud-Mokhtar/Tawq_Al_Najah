class OrderItem {
  final int itemId;
  final String productName;
  final String description;
  final int quantity;
  final double price;
  final double discount;
  final double fees;
  final double total;
  final String? image;

  OrderItem({
    required this.itemId,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.fees,
    required this.total,
    required this.image,
  });

  static double _toDouble(dynamic v) =>
      double.tryParse(v?.toString() ?? '0') ?? 0;

  static int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;

  static String? _pickImage(Map<String, dynamic> json) {
    final candidates = [
      'image',
      'img',
      'photo',
      'thumbnail',
      'product_image',
      'item_image',
      'cover',
    ];
    for (final k in candidates) {
      final v = json[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    final product = json['product'];
    if (product is Map<String, dynamic>) {
      for (final k in candidates) {
        final v = product[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
    }
    return null;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final name = (json['item_name'] ??
        json['product_name'] ??
        json['name'] ??
        json['title'] ??
        '')
        .toString();

    final desc = (json['description'] ??
        json['desc'] ??
        json['details'] ??
        json['item_description'] ??
        '')
        .toString();

    return OrderItem(
      itemId: _toInt(json['item_id'] ?? json['id']),
      productName: name,
      description: desc,
      quantity: _toInt(json['quantity'] ?? json['qty']),
      price: _toDouble(json['price']),
      discount: _toDouble(json['discount']),
      fees: _toDouble(json['fees']),
      total: _toDouble(json['total'] ?? json['final_total']),
      image: _pickImage(json),
    );
  }
}

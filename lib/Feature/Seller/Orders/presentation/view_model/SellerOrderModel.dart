class SellerOrderModel {
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String productImage;
  final String productName;
  final String description;
  final int quantity;
  final String totalPrice;
  final String shippingCost;
  final String orderDate;
  final String category;

  String status;
  String? confirmedDate;
  String? confirmedTime;
  String? shippedDate;
  String? shippedTime;
  String? deliveredDate;
  String? deliveredTime;

  SellerOrderModel({
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.productImage,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.totalPrice,
    required this.shippingCost,
    required this.orderDate,
    required this.status,
    required this.category,
    this.confirmedDate,
    this.confirmedTime,
    this.shippedDate,
    this.shippedTime,
    this.deliveredDate,
    this.deliveredTime,
  });

  bool get isDelivered => status == "delivered";

  SellerOrderModel copyWith({
    String? status,
    String? confirmedDate,
    String? confirmedTime,
    String? shippedDate,
    String? shippedTime,
    String? deliveredDate,
    String? deliveredTime,
  }) {
    return SellerOrderModel(
      orderId: orderId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      productImage: productImage,
      productName: productName,
      description: description,
      quantity: quantity,
      totalPrice: totalPrice,
      shippingCost: shippingCost,
      orderDate: orderDate,
      status: status ?? this.status,
      category: category,
      confirmedDate: confirmedDate ?? this.confirmedDate,
      confirmedTime: confirmedTime ?? this.confirmedTime,
      shippedDate: shippedDate ?? this.shippedDate,
      shippedTime: shippedTime ?? this.shippedTime,
      deliveredDate: deliveredDate ?? this.deliveredDate,
      deliveredTime: deliveredTime ?? this.deliveredTime,
    );
  }
}

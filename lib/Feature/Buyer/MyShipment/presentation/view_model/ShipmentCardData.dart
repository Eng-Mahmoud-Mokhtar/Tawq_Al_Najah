class ShipmentCardData {
  final String shipmentNumber;
  final String productImage;
  final String productName;
  final String description;
  final int quantity;
  final String category;
  final String price;
  final String totalPrice;
  final String shippingCost;
  final String orderDate;
  final bool isDelivered;

  final String orderConfirmedDate;
  final String orderConfirmedTime;
  final String shippedDate;
  final String shippedTime;
  final String deliveredDate;
  final String deliveredTime;

  ShipmentCardData({
    required this.shipmentNumber,
    required this.productImage,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.category,
    required this.price,
    required this.totalPrice,
    required this.shippingCost,
    required this.orderDate,
    required this.isDelivered,
    required this.orderConfirmedDate,
    required this.orderConfirmedTime,
    required this.shippedDate,
    required this.shippedTime,
    required this.deliveredDate,
    required this.deliveredTime,
  });
}

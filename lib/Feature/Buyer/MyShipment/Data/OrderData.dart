import '../Model/OrderItem.dart';
import '../Model/TrackOrder.dart';
import '../Model/UserInfo.dart';

class OrderData {
  final int orderId;
  final String orderNumber;
  final String orderDate;
  final String status;
  final bool isPaid;
  final double total;
  final double fees;
  final double finalTotal;
  final String paymentType;
  final int countItems;
  final UserInfo user;
  final List<OrderItem> items;
  final TrackOrder trackOrder;
  final String? orderImage;

  OrderData({
    required this.orderId,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.isPaid,
    required this.total,
    required this.fees,
    required this.finalTotal,
    required this.paymentType,
    required this.countItems,
    required this.user,
    required this.items,
    required this.trackOrder,
    required this.orderImage,
  });

  static double _toDouble(dynamic v) =>
      double.tryParse(v?.toString() ?? '0') ?? 0;

  static int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;

  static bool _toBool01(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    final s = v.toString();
    return s == '1' || s.toLowerCase() == 'true';
  }

  static String? _pickImage(Map<String, dynamic> order, Map<String, dynamic> root) {
    final candidates = [
      'image',
      'img',
      'photo',
      'thumbnail',
      'cover',
      'order_image',
    ];
    for (final k in candidates) {
      final v = order[k] ?? root[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return null;
  }

  factory OrderData.fromJson(Map<String, dynamic> json) {
    final order = (json['order'] is Map<String, dynamic>)
        ? (json['order'] as Map<String, dynamic>)
        : json;

    final userJson =
    (json['user'] is Map<String, dynamic>) ? json['user'] : null;

    final trackJson = (json['trackOrder'] is Map<String, dynamic>)
        ? (json['trackOrder'] as Map<String, dynamic>)
        : (json['track_order'] is Map<String, dynamic>)
        ? (json['track_order'] as Map<String, dynamic>)
        : null;

    final itemsRaw = (json['items'] is List)
        ? (json['items'] as List)
        : (json['order_items'] is List)
        ? (json['order_items'] as List)
        : const [];

    final itemsParsed = itemsRaw
        .whereType<Map>()
        .map((x) => OrderItem.fromJson(Map<String, dynamic>.from(x)))
        .toList();

    final parsedOrderId =
    _toInt(order['id'] ?? order['order_id'] ?? json['order_id'] ?? json['id']);

    return OrderData(
      orderId: parsedOrderId,
      orderNumber:
      (order['order_number'] ?? order['orderNumber'] ?? order['id'] ?? '')
          .toString(),
      orderDate:
      (order['created_at'] ?? order['createdAt'] ?? order['date'] ?? '')
          .toString(),
      status: (order['status'] ?? json['status'] ?? 'pending').toString(),
      isPaid: _toBool01(order['is_paid'] ?? order['isPaid']),
      total: _toDouble(order['total']),
      fees: _toDouble(order['fees'] ?? order['shipping_fees']),
      finalTotal: _toDouble(order['final_total'] ?? order['grand_total']),
      paymentType:
      (order['payment_type'] ?? order['paymentType'] ?? '').toString(),
      countItems: _toInt(
          order['count_items'] ?? order['countItems'] ?? itemsParsed.length),
      user: UserInfo.fromJson(
        userJson is Map<String, dynamic> ? Map<String, dynamic>.from(userJson) : null,
      ),
      items: itemsParsed,
      trackOrder:
      TrackOrder.fromJson(trackJson is Map<String, dynamic> ? trackJson : null),
      orderImage: _pickImage(order, json),
    );
  }

  bool get isDelivered => status == 'completed' || trackOrder.completed;

  bool get isCancelled =>
      status == 'cancelled' ||
          status == 'canceled' ||
          status == 'Cancelled' ||
          trackOrder.canceled == true;

  bool get isAccepted => trackOrder.accepted;
  bool get isShipped => trackOrder.shipped;
}

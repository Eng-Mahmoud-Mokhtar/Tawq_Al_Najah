class OrderReport {
  final String orderId, code, status, date, month;
  final double amount;
  final int quantity;
  OrderReport({
    required this.orderId,
    required this.amount,
    required this.code,
    required this.quantity,
    required this.status,
    required this.date,
    required this.month,
  });
}

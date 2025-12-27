class TrackOrder {
  final int id;
  final int orderId;
  final bool accepted;
  final String? acceptedTime;
  final bool shipped;
  final String? shippedTime;
  final bool completed;
  final String? completedTime;
  final bool? canceled;
  final String? canceledTime;

  TrackOrder({
    required this.id,
    required this.orderId,
    required this.accepted,
    required this.acceptedTime,
    required this.shipped,
    required this.shippedTime,
    required this.completed,
    required this.completedTime,
    required this.canceled,
    required this.canceledTime,
  });

  static int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;

  static bool _toBool01(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    final s = v.toString();
    return s == '1' || s.toLowerCase() == 'true';
  }

  factory TrackOrder.fromJson(Map<String, dynamic>? json) {
    final j = json ?? const <String, dynamic>{};

    final completedValue =
        j['completed'] ?? j['compeleted'] ?? j['is_completed'];
    final completedTimeValue =
        j['completed_time'] ?? j['compeleted_time'] ?? j['completedTime'];

    return TrackOrder(
      id: _toInt(j['id']),
      orderId: _toInt(j['order_id'] ?? j['orderId'] ?? j['order']),
      accepted: _toBool01(j['accepted']),
      acceptedTime: j['accepted_time']?.toString(),
      shipped: _toBool01(j['shipped']),
      shippedTime: j['shipped_time']?.toString(),
      completed: _toBool01(completedValue),
      completedTime: completedTimeValue?.toString(),
      canceled: j.containsKey('canceled') ? _toBool01(j['canceled']) : null,
      canceledTime: j['canceled_time']?.toString(),
    );
  }
}

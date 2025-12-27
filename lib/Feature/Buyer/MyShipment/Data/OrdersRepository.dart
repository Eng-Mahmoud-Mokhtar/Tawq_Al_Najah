import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'OrderData.dart';

class OrdersRepository {
  final Dio dio;
  final FlutterSecureStorage storage;
  final String baseUrl;

  OrdersRepository({
    required this.dio,
    required this.storage,
    required this.baseUrl,
  });

  Future<Map<String, dynamic>> _authHeaders() async {
    final token = await storage.read(key: 'user_token');
    return {
      'Accept': 'application/json',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer ${token.trim()}',
    };
  }

  Future<List<int>> fetchOrdersIdsByStatus(String status) async {
    final headers = await _authHeaders();
    final response = await dio.get(
      '$baseUrl/user/my-order',
      queryParameters: {'status': status},
      options: Options(headers: headers),
    );

    if (response.statusCode == 200 && response.data is Map) {
      final map = response.data as Map;
      if (map['status'] == 200) {
        final list = (map['data'] as List?) ?? const [];
        final ids = <int>[];
        for (final o in list) {
          if (o is Map) {
            final id = o['id'] ?? o['order_id'];
            final parsed = int.tryParse(id?.toString() ?? '');
            if (parsed != null && parsed > 0) ids.add(parsed);
          }
        }
        return ids;
      }
    }
    throw Exception('Failed to load orders');
  }

  Future<OrderData?> fetchOrderDetails(int orderId) async {
    if (orderId == 0) return null;
    final headers = await _authHeaders();
    final response = await dio.get(
      '$baseUrl/user/my-order-details/$orderId',
      options: Options(headers: headers),
    );
    if (response.statusCode == 200 && response.data is Map) {
      final map = response.data as Map;
      if (map['status'] == 200) {
        final data = map['data'];
        if (data is Map<String, dynamic>) return OrderData.fromJson(data);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> cancelOrderById(int orderId) async {
    final headers = await _authHeaders();
    final response = await dio.get(
      '$baseUrl/user/my-order-cancel/$orderId',
      options: Options(headers: headers, validateStatus: (_) => true),
    );

    if (response.data is Map) {
      return Map<String, dynamic>.from(response.data as Map);
    }
    return {'status': response.statusCode ?? 0, 'message': 'invalid response'};
  }
}

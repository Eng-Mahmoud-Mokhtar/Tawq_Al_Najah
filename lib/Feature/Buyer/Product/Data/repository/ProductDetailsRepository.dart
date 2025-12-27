import 'package:dio/dio.dart';
class ProductDetailsRepository {
  final Dio _dio;
  String? token;
  ProductDetailsRepository({Dio? dio, this.token}) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>> fetchProductDetails(int productId) async {
    final url = 'https://toknagah.viking-iceland.online/api/user/products/$productId';
    final response = await _dio.get(
        url,
        options: Options(headers: token != null ? {'Authorization': 'Bearer $token'} : {})
    );
    if (response.statusCode == 200) {
      return (response.data as Map<String, dynamic>)['data'];
    }
    throw Exception('Failed to load product');
  }
}
import 'package:dio/dio.dart';

class RatingRepository {
  final Dio _dio;
  RatingRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<void> submitRating({required int productId, required int rating, required String token}) async {
    final url = 'https://toknagah.viking-iceland.online/api/user/products/$productId/add-rate';
    try {
      final response = await _dio.post(
          url,
          data: {'rate': rating},
          options: Options(headers: {'Authorization': 'Bearer $token'})
      );
      print(response.statusCode == 200 ? 'Rating submitted' : 'Rating failed: ${response.statusCode}');
    } catch (e) {
      print('Rating error: $e');
      rethrow;
    }
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import '../Model/BannerModel.dart';

class BannerRepository {
  final Dio _dio;
  String? token;

  BannerRepository({Dio? dio, this.token}) : _dio = dio ?? Dio();

  Future<BannerModel> fetchHomeBanners() async {
    const url = 'https://toknagah.viking-iceland.online/api/user/home';
    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: token != null
              ? {'Authorization': 'Bearer $token', 'Accept': 'application/json'}
              : {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is String) {
          return BannerModel.fromJson(jsonDecode(data));
        }
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            return BannerModel.fromJson(data['data']);
          }
          return BannerModel.fromJson(data);
        }
        return BannerModel(banners: [], tawqalProducts: [], suggestedProducts: []);
      } else {
        throw Exception('Failed to fetch banners: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

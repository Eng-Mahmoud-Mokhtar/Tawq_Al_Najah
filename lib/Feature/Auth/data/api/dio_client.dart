import 'package:dio/dio.dart';

class DioClient {
  static Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://toknagah.viking-iceland.online/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }
}
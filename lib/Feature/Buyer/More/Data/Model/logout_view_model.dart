import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../Auth/presentation/login.dart';

class LogoutViewModel {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool isLoggingOut = false;

  Future<void> performLogout(BuildContext context, {required void Function(bool) onStateChanged}) async {
    if (isLoggingOut) return;
    isLoggingOut = true;
    onStateChanged(true); // لتحديث الزر

    try {
      final token = await _secureStorage.read(key: 'user_token');
      print('🟢 User token before logout: $token');

      final dio = Dio(
        BaseOptions(
          baseUrl: 'https://toknagah.viking-iceland.online/api',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      try {
        final response = await dio.post('/user/auth/logout');
        print('✅ Logout API response: ${response.data}');
      } on DioException catch (e) {
        if (e.response != null) {
          print('❌ Logout API failed or unauthorized: ${e.response?.data}');
        } else {
          print('❌ Logout API error: ${e.message}');
        }
      }
    } catch (e) {
      print('❌ Logout unknown error: $e');
    } finally {
      await _secureStorage.deleteAll();
      isLoggingOut = false;
      onStateChanged(false);
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }
}

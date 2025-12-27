import 'package:dio/dio.dart';
import '../models/forgot_password_model.dart';

class AuthRepositoryImpl {
  final Dio dio;

  AuthRepositoryImpl({required this.dio});

  Future<Map<String, dynamic>> sendResetCode(String email) async {
    final response = await dio.post(
      '/user/auth/forget-password',
      data: {'email': email},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final response = await dio.post(
      '/user/auth/verification-otp',
      data: {
        'email': email,
        'otp': int.tryParse(code) ?? 0,
      },
    );
    return response.data;
  }

  Future<Map<String, dynamic>> resetPassword(ResetPasswordRequest request) async {
    final response = await dio.post(
      '/user/auth/reset-password',
      data: request.toJson(),
    );
    return response.data;
  }
}
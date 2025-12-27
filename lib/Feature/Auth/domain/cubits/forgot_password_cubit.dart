import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../generated/l10n.dart';

class ForgotPasswordState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final String? email;

  ForgotPasswordState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.email,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    String? email,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      email: email ?? this.email,
    );
  }
}

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final Dio dio;

  ForgotPasswordCubit({required this.dio}) : super(ForgotPasswordState()) {
    _setupDio();
  }

  void _setupDio() {
    dio.options = BaseOptions(
      baseUrl: 'https://toknagah.viking-iceland.online/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  Future<void> sendResetCode(String email, BuildContext context) async {
    // التحقق من صحة الإيميل أولاً
    final validationError = _validateEmail(email, context);
    if (validationError != null) {
      emit(state.copyWith(
        isLoading: false,
        error: validationError,
      ));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final response = await dio.post(
        '/user/auth/forget-password',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 200) {
          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            email: email,
          ));
        } else {
          final errorMessage = _translateErrorMessage(
              responseData['message']?.toString() ?? 'Failed to send reset code',
              context
          );
          emit(state.copyWith(
            isLoading: false,
            error: errorMessage,
          ));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: S.of(context).serverError,
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e, context),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: S.of(context).unexpectedError,
      ));
    }
  }

  // دالة للتحقق من صحة الإيميل
  String? _validateEmail(String email, BuildContext context) {
    if (email.isEmpty) {
      return S.of(context).emailRequired;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(email)) {
      return S.of(context).enterValidEmail;
    }

    return null;
  }

  String _translateErrorMessage(String message, BuildContext context) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('email') && lowerMessage.contains('not found')) {
      return S.of(context).emailNotFound;
    }
    if (lowerMessage.contains('email') && lowerMessage.contains('required')) {
      return S.of(context).emailRequired;
    }
    if (lowerMessage.contains('valid') && lowerMessage.contains('email')) {
      return S.of(context).enterValidEmail;
    }

    return message;
  }

  String _getErrorMessage(DioException e, BuildContext context) {
    if (e.response != null) {
      final responseData = e.response!.data;
      if (responseData is Map<String, dynamic> && responseData['message'] != null) {
        return _translateErrorMessage(responseData['message'].toString(), context);
      }
      return S.of(context).serverError;
    }

    // ترجمة أخطاء الشبكة
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاتصال';
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return S.of(context).networkError;
      case DioExceptionType.badCertificate:
        return 'خطأ في شهادة SSL';
      case DioExceptionType.badResponse:
        return S.of(context).serverError;
      case DioExceptionType.cancel:
        return 'تم إلغاء الطلب';
      default:
        return S.of(context).networkError;
    }
  }

  // دالة مساعدة لمسح الخطأ
  void clearError() {
    emit(state.copyWith(error: null));
  }
}
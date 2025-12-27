import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:tawqalnajah/Feature/Auth/presentation/login.dart';
import '../../../../generated/l10n.dart';

class NewPasswordState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;
  final bool hasError;
  final String buttonText;

  NewPasswordState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
    this.hasError = false,
    this.buttonText = 'Reset Password',
  });

  NewPasswordState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
    bool? hasError,
    String? buttonText,
  }) {
    return NewPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      hasError: hasError ?? this.hasError,
      buttonText: buttonText ?? this.buttonText,
    );
  }
}

class NewPasswordCubit extends Cubit<NewPasswordState> {
  final Dio dio;
  final String email;
  final String otp;

  NewPasswordCubit({
    required this.dio,
    required this.email,
    required this.otp,
  }) : super(NewPasswordState()) {
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

  Future<void> resetPassword({
    required String newPassword,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      hasError: false,
      buttonText: 'Resetting...',
    ));

    final validationError = _validatePasswords(newPassword, confirmPassword, context);
    if (validationError != null) {
      emit(state.copyWith(
        isLoading: false,
        error: validationError,
        hasError: true,
        buttonText: S.of(context).resetPassword,
      ));
      return;
    }

    try {
      final response = await dio.post(
        '/user/auth/reset-password',
        data: {
          'email': email,
          'otp': int.tryParse(otp) ?? 0,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 200) {
          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            hasError: false,
            buttonText: 'Success',
          ));
          _showSuccessMessage(context);
          _navigateToLogin(context);
        } else {
          final errorMessage = _translateErrorMessage(
              responseData['message']?.toString() ?? 'Failed to reset password',
              context
          );
          emit(state.copyWith(
            isLoading: false,
            error: errorMessage,
            hasError: true,
            buttonText: S.of(context).resetFailed,
          ));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: S.of(context).serverError,
          hasError: true,
          buttonText: S.of(context).resetFailed,
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        buttonText: S.of(context).resetFailed,
      ));
      _handleDioError(e, context);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: S.of(context).unexpectedError,
        hasError: true,
        buttonText: S.of(context).resetFailed,
      ));
    }
  }

  String? _validatePasswords(String newPassword, String confirmPassword, BuildContext context) {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      return S.of(context).passwordRequired;
    }
    if (newPassword.length < 6) {
      return S.of(context).passwordMinLength;
    }
    if (newPassword != confirmPassword) {
      return S.of(context).passwordsDoNotMatch;
    }
    return null;
  }

  String _translateErrorMessage(String message, BuildContext context) {
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('otp') && lowerMessage.contains('invalid')) {
      return S.of(context).invalidOtp;
    }
    if (lowerMessage.contains('otp') && lowerMessage.contains('expired')) {
      return S.of(context).otpExpired;
    }
    if (lowerMessage.contains('password') && lowerMessage.contains('required')) {
      return S.of(context).passwordRequired;
    }
    if (lowerMessage.contains('password') && lowerMessage.contains('confirmation')) {
      return S.of(context).passwordsDoNotMatch;
    }
    if (lowerMessage.contains('password') && lowerMessage.contains('length')) {
      return S.of(context).passwordMinLength;
    }

    return message;
  }

  void _handleDioError(DioException e, BuildContext context) {
    String errorMessage;
    if (e.response != null) {
      final responseData = e.response!.data;
      if (responseData is Map<String, dynamic> && responseData['message'] != null) {
        errorMessage = _translateErrorMessage(responseData['message'].toString(), context);
      } else {
        errorMessage = S.of(context).serverError;
      }
    } else {
      errorMessage = _getNetworkErrorMessage(e, context);
    }
    emit(state.copyWith(
      error: errorMessage,
      hasError: true,
      buttonText: S.of(context).resetFailed,
    ));
  }

  String _getNetworkErrorMessage(DioException e, BuildContext context) {
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

  void toggleNewPasswordVisibility() {
    emit(state.copyWith(obscureNewPassword: !state.obscureNewPassword));
  }

  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword));
  }

  void clearError(BuildContext context) {
    emit(state.copyWith(
      error: null,
      hasError: false,
      buttonText: S.of(context).resetPassword,
    ));
  }
  void _showSuccessMessage(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).passwordResetSuccess),
          backgroundColor: Color(0xff1BCA02),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  void _navigateToLogin(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    });
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../generated/l10n.dart';
import '../../presentation/view_model/views/NewPassword.dart';

class VerifyCodeState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final bool canResend;
  final int countdown;
  final String? code;
  final bool hasError;
  final String buttonText;

  VerifyCodeState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.canResend = false,
    this.countdown = 300,
    this.code,
    this.hasError = false,
    this.buttonText = 'Verify',
  });

  VerifyCodeState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    bool? canResend,
    int? countdown,
    String? code,
    bool? hasError,
    String? buttonText,
  }) {
    return VerifyCodeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      canResend: canResend ?? this.canResend,
      countdown: countdown ?? this.countdown,
      code: code ?? this.code,
      hasError: hasError ?? this.hasError,
      buttonText: buttonText ?? this.buttonText,
    );
  }
}

class VerifyCodeCubit extends Cubit<VerifyCodeState> {
  final Dio dio;
  final String email;
  Timer? _timer;

  VerifyCodeCubit({required this.dio, required this.email})
      : super(VerifyCodeState()) {
    _setupDio();
    _startTimer();
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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown > 0) {
        emit(state.copyWith(countdown: state.countdown - 1));
      } else {
        emit(state.copyWith(canResend: true));
        timer.cancel();
      }
    });
  }

  Future<void> verifyCode(String code, BuildContext context) async {
    if (code.length != 4) {
      emit(state.copyWith(
        error: S.of(context).codeMustBe4Digits,
        hasError: true,
        buttonText: S.of(context).verify,
      ));
      return;
    }
    emit(state.copyWith(
      isLoading: true,
      error: null,
      hasError: false,
      buttonText: 'Verifying...',
    ));
    try {
      final response = await dio.post(
        '/user/auth/verification-otp',
        data: {
          'email': email,
          'otp': int.tryParse(code) ?? 0,
        },
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 200) {
          emit(state.copyWith(
            isLoading: false,
            isSuccess: true,
            code: code,
            hasError: false,
            buttonText: 'Success',
          ));
          _navigateToNewPassword(context, code);
        } else {
          final errorMessage = responseData['message'] ?? 'Verification failed';
          emit(state.copyWith(
            isLoading: false,
            error: errorMessage.toString(),
            hasError: true,
            buttonText: 'Failed',
          ));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Server error (${response.statusCode})',
          hasError: true,
          buttonText: 'Failed',
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        buttonText: 'Failed',
      ));
      _handleDioError(e, context);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
        hasError: true,
        buttonText: 'Failed',
      ));
    }
  }

  Future<void> resendCode(BuildContext context) async {
    if (!state.canResend) return;
    emit(state.copyWith(
      isLoading: true,
      error: null,
      canResend: false,
      hasError: false,
      buttonText: 'Sending...',
    ));
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
            countdown: 300,
            canResend: false,
            error: null,
            hasError: false,
            buttonText: 'Verify',
          ));
          _startTimer();
        } else {
          final errorMessage = responseData['message'] ?? 'Failed to resend code';
          emit(state.copyWith(
            isLoading: false,
            error: errorMessage.toString(),
            canResend: true,
            hasError: true,
            buttonText: 'Verify',
          ));
        }
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to resend code',
          canResend: true,
          hasError: true,
          buttonText: 'Verify',
        ));
      }
    } on DioException catch (e) {
      emit(state.copyWith(
        isLoading: false,
        canResend: true,
        buttonText: 'Verify',
      ));
      _handleDioError(e, context);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
        canResend: true,
        hasError: true,
        buttonText: 'Verify',
      ));
    }
  }

  void _handleDioError(DioException e, BuildContext context) {
    String errorMessage;
    if (e.response != null) {
      final responseData = e.response!.data;
      if (responseData is Map<String, dynamic> && responseData['message'] != null) {
        errorMessage = responseData['message'].toString();
      } else {
        errorMessage = 'Server error (${e.response!.statusCode})';
      }
    } else {
      errorMessage = _getNetworkErrorMessage(e);
    }
    emit(state.copyWith(
      error: errorMessage,
      canResend: true,
      hasError: true,
      buttonText: 'Failed',
    ));
  }

  String _getNetworkErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout';
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return 'No internet connection';
      case DioExceptionType.badCertificate:
        return 'SSL certificate error';
      case DioExceptionType.badResponse:
        return 'Server error';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error';
    }
  }

  void _navigateToNewPassword(BuildContext context, String code) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordScreen(
            email: email,
            otp: code,
          ),
        ),
      );
    });
  }

  String get formattedCountdown {
    final minutes = (state.countdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.countdown % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void clearError() {
    emit(state.copyWith(
      error: null,
      hasError: false,
      buttonText: 'Verify',
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
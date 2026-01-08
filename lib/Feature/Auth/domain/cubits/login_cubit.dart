import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../../generated/l10n.dart';
import '../../../Buyer/Home/presentation/view_model/views/HomeStructure.dart';
import '../../../Seller/Home/presentation/view_model/views/HomeStructure.dart';
import '../../data/models/login_model.dart';
class LoginState {
  final bool isLoading;
  final Map<String, String> errors;
  final bool isSuccess;
  final String? serverError;
  final Map<String, dynamic>? userData;
  final String? token;

  const LoginState({
    this.isLoading = false,
    this.errors = const {},
    this.isSuccess = false,
    this.serverError,
    this.userData,
    this.token,
  });

  LoginState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    bool? isSuccess,
    String? serverError,
    Map<String, dynamic>? userData,
    String? token,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      isSuccess: isSuccess ?? this.isSuccess,
      serverError: serverError ?? this.serverError,
      userData: userData ?? this.userData,
      token: token ?? this.token,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  final Dio dio;
  final BuildContext context;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  LoginCubit({required this.dio, required this.context}) : super(const LoginState()) {
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

  Future<void> loginUser(String email, String password) async {
    emit(state.copyWith(isLoading: true, errors: {}, serverError: null));

    final validationErrors = _validateForm(email, password);
    if (validationErrors.isNotEmpty) {
      emit(state.copyWith(isLoading: false, errors: validationErrors));
      return;
    }

    try {
      final loginModel = LoginModel(email: email, password: password);
      final response = await dio.post('/user/auth/login', data: loginModel.toJson());
      await _handleApiResponse(response);
    } on DioException catch (e) {
      emit(state.copyWith(isLoading: false));
      _handleDioError(e);
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _handleApiResponse(Response response) async {
    if (response.statusCode == 200) {
      final responseData = response.data;
      if (responseData['status'] == 200) {
        final userData = responseData['data']['user'];
        final token = responseData['data']['token'];

        await secureStorage.write(key: 'user_token', value: token);
        await secureStorage.write(key: 'user_data', value: userData.toString());
        await secureStorage.write(key: 'is_logged_in', value: 'true');
        await secureStorage.write(key: 'user_type', value: userData['type']);

        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          userData: userData,
          token: token,
        ));

        _handleSuccessfulLogin(userData);
      } else {
        _handleErrorResponse(responseData);
      }
    } else {
      emit(state.copyWith(isLoading: false));
      _handleErrorResponse(response.data ?? {'message': S.of(context).loginFailed});
    }
  }

  void _handleSuccessfulLogin(Map<String, dynamic> userData) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userData['type'] == 'saller') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeStructureSeller()),
              (route) => false,
        );
      } else if (userData['type'] == 'customer') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeStructure()),
              (route) => false,
        );
      }
    });
  }

  void _handleDioError(DioException e) {
    emit(state.copyWith(isLoading: false));
    if (e.response != null && e.response!.data != null) {
      _handleErrorResponse(e.response!.data);
    } else {
      _handleNetworkError();
    }
  }

  void _handleNetworkError() {
    emit(state.copyWith(
      isLoading: false,
      errors: {'network': S.of(context).networkError},
    ));
  }

  Map<String, String> _validateForm(String email, String password) {
    final s = S.of(context);
    final errors = <String, String>{};

    if (email.trim().isEmpty) {
      errors['email'] = s.emailRequired;
    } else if (!_isValidEmail(email)) {
      errors['email'] = s.invalidEmail;
    }

    if (password.isEmpty) {
      errors['password'] = s.passwordRequired;
    } else if (password.length < 6) {
      errors['password'] = s.passwordLength;
    }

    return errors;
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  void _handleErrorResponse(Map<String, dynamic> responseData) {
    final errors = <String, String>{};
    final s = S.of(context);

    if (responseData['errors'] != null) {
      final errorMap = responseData['errors'] as Map<String, dynamic>;
      errorMap.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          final errorMessage = value.first.toString().toLowerCase();
          errors[key] = _translateErrorMessage(errorMessage, s);
        } else if (value is String) {
          errors[key] = _translateErrorMessage(value.toLowerCase(), s);
        }
      });
    }

    if (errors.isEmpty && responseData['message'] != null) {
      final msg = responseData['message'].toString().toLowerCase();
      errors['general'] = _translateErrorMessage(msg, s);
    }

    if (responseData['data'] != null && responseData['data'] is String) {
      final msg = (responseData['data'] as String).toLowerCase();
      errors['general'] ??= _translateErrorMessage(msg, s);
    }

    emit(state.copyWith(
      isLoading: false,
      errors: errors,
      serverError: responseData['message']?.toString(),
    ));
  }

  String _translateErrorMessage(String errorMessage, S s) {
    if (errorMessage.contains('password') && errorMessage.contains('required')) {
      return s.passwordRequired;
    } else if (errorMessage.contains('email') && errorMessage.contains('required')) {
      return s.emailRequired;
    } else if (errorMessage.contains('valid') || errorMessage.contains('invalid')) {
      return s.invalidEmail;
    } else if (errorMessage.contains('fail') ||
        errorMessage.contains('incorrect') ||
        errorMessage.contains('invalid') ||
        errorMessage.contains('match') ||
        errorMessage.contains('creadtion')) {
      return s.invalidEmailOrPassword;
    } else if (errorMessage.contains('not found') || errorMessage.contains('exist')) {
      return s.accountNotFound;
    } else if (errorMessage.contains('verification') || errorMessage.contains('verify')) {
      return s.emailNotVerified;
    } else if (errorMessage.contains('suspended') || errorMessage.contains('blocked')) {
      return s.accountSuspended;
    } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      return s.networkError;
    } else if (errorMessage.contains('server') || errorMessage.contains('unavailable')) {
      return s.serverError;
    } else if (errorMessage.contains('timeout')) {
      return s.timeoutError;
    } else {
      return errorMessage;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:equatable/equatable.dart';
import '../../../../../Core/utiles/Colors.dart';
import '../../../../../generated/l10n.dart';
import '../../../../Auth/presentation/login.dart';
import '../../data/models/buyer_register_model.dart';

// Events
abstract class BuyerRegisterEvent extends Equatable {
  const BuyerRegisterEvent();
  @override
  List<Object> get props => [];
}

class BuyerRegisterSubmitted extends BuyerRegisterEvent {
  final Map<String, dynamic> formData;
  const BuyerRegisterSubmitted(this.formData);
  @override
  List<Object> get props => [formData];
}

// States
class BuyerRegisterState extends Equatable {
  final bool isLoading;
  final Map<String, String> errors;
  final bool isSuccess;
  final String? serverError;

  const BuyerRegisterState({
    this.isLoading = false,
    this.errors = const {},
    this.isSuccess = false,
    this.serverError,
  });

  BuyerRegisterState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    bool? isSuccess,
    String? serverError,
  }) {
    return BuyerRegisterState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      isSuccess: isSuccess ?? this.isSuccess,
      serverError: serverError ?? this.serverError,
    );
  }

  @override
  List<Object> get props => [isLoading, errors, isSuccess, serverError ?? ''];
}

// Cubit
class BuyerRegisterCubit extends Cubit<BuyerRegisterState> {
  final Dio dio;
  final BuildContext context;

  BuyerRegisterCubit({required this.dio, required this.context})
      : super(const BuyerRegisterState()) {
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

  Future<void> registerBuyer(Map<String, dynamic> formData) async {
    emit(state.copyWith(isLoading: true, errors: {}, serverError: null));
    final s = S.of(context);

    try {
      final validationErrors = _validateForm(formData);
      if (validationErrors.isNotEmpty) {
        emit(state.copyWith(isLoading: false, errors: validationErrors));
        return;
      }

      final buyerModel = BuyerRegisterModel(
        name: formData['name'],
        email: formData['email'],
        password: formData['password'],
        codePhone: formData['code_phone'],
        phone: formData['phone'],
        country: formData['country'],
        governorate: formData['governorate'],
        address: formData['address'],
        type: formData['type'],
        referralCode: formData['referral_code'],
      );

      final response = await dio.post(
        '/user/auth/register',
        data: buyerModel.toJson(),
      );

      _handleApiResponse(response);
    } on DioException catch (e) {
      emit(state.copyWith(isLoading: false));
      _handleDioError(e);
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      _showErrorDialog(s.unexpectedError);
    }
  }

  void _handleApiResponse(Response response) {
    final s = S.of(context);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data;

      if (responseData['status'] == 200 || responseData['status'] == 201) {
        emit(state.copyWith(isLoading: false, isSuccess: true));
        _showSuccessDialog(s.registrationSuccess);
      } else {
        _handleErrorResponse(responseData);
      }
    } else {
      emit(state.copyWith(isLoading: false));
      _handleErrorResponse(response.data ?? {'message': s.registrationFailed});
    }
  }

  void _handleDioError(DioException e) {
    emit(state.copyWith(isLoading: false));

    if (e.response != null) {
      if (e.response!.data != null) {
        _handleErrorResponse(e.response!.data);
      } else {
        _handleNetworkError(e);
      }
    } else {
      _handleNetworkError(e);
    }
  }

  void _handleNetworkError(DioException e) {
    final s = S.of(context);
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        errorMessage = s.networkError;
        break;
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = s.timeoutError;
        break;
      default:
        errorMessage = s.defaultError;
    }

    _showErrorDialog(errorMessage);
  }

  void _showSuccessDialog(String message) {
    final s = S.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: s.successTitle,
        desc: message,
        btnOkOnPress: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
          );
        },
        btnOkText: s.continueToLogin,
        btnOkColor: KprimaryColor,
      ).show();
    });
  }

  void _showErrorDialog(String message) {
    final s = S.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: s.failedTitle,
        desc: message,
        btnOkOnPress: () {},
        btnOkText: s.tryAgain,
        btnOkColor: const Color(0xffDD0C0C),
      ).show();
    });
  }

  Map<String, String> _validateForm(Map<String, dynamic> formData) {
    final s = S.of(context);
    final errors = <String, String>{};

    if (formData['name']?.toString().trim().isEmpty ?? true) {
      errors['name'] = s.usernameRequired;
    }

    if (formData['email']?.toString().trim().isEmpty ?? true) {
      errors['email'] = s.emailRequired;
    } else if (!_isValidEmail(formData['email'].toString())) {
      errors['email'] = s.invalidEmail;
    }

    if (formData['password']?.toString().isEmpty ?? true) {
      errors['password'] = s.passwordRequired;
    } else if ((formData['password'] as String).length < 6) {
      errors['password'] = s.passwordLength;
    }

    if (formData['code_phone']?.toString().isEmpty ?? true) {
      errors['code_phone'] = s.countryCodeRequired;
    }

    if (formData['phone']?.toString().trim().isEmpty ?? true) {
      errors['phone'] = s.phoneRequired;
    } else if (!_isValidPhoneNumber(formData['phone'].toString())) {
      errors['phone'] = s.invalidPhone;
    }

    if (formData['country']?.toString().trim().isEmpty ?? true) {
      errors['country'] = s.countryRequired;
    }

    if (formData['governorate']?.toString().trim().isEmpty ?? true) {
      errors['governorate'] = s.cityRequired;
    }

    if (formData['address']?.toString().trim().isEmpty ?? true) {
      errors['address'] = s.addressRequired;
    }

    return errors;
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool _isValidPhoneNumber(String phone) =>
      RegExp(r'^[0-9]{7,15}$').hasMatch(phone);

  void _handleErrorResponse(Map<String, dynamic> responseData) {
    final s = S.of(context);
    final errors = <String, String>{};

    if (responseData['errors'] != null) {
      final errorMap = responseData['errors'] as Map<String, dynamic>;
      errorMap.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          errors[key] = _getUserFriendlyErrorMessage(value.first.toString());
        } else if (value is String) {
          errors[key] = _getUserFriendlyErrorMessage(value);
        }
      });
    }

    final serverMessage =
        responseData['message']?.toString() ?? s.registrationFailed;

    if (errors.isEmpty) {
      emit(state.copyWith(
          isLoading: false,
          serverError: _getUserFriendlyErrorMessage(serverMessage)));
      _showErrorDialog(_getUserFriendlyErrorMessage(serverMessage));
    } else {
      emit(state.copyWith(
        isLoading: false,
        errors: errors,
        serverError: s.checkInfo,
      ));
      _showErrorDialog(s.checkFields);
    }
  }

  String _getUserFriendlyErrorMessage(String error) {
    final s = S.of(context);
    final errorLower = error.toLowerCase();

    if (errorLower.contains('username') && errorLower.contains('required')) {
      return s.usernameRequired;
    } else if (errorLower.contains('email') && errorLower.contains('already')) {
      return s.emailUsed;
    } else if (errorLower.contains('phone') && errorLower.contains('already')) {
      return s.phoneUsed;
    } else if (errorLower.contains('password') && errorLower.contains('weak')) {
      return s.passwordWeak;
    } else if (errorLower.contains('network') ||
        errorLower.contains('connection')) {
      return s.networkError;
    } else if (errorLower.contains('server') ||
        errorLower.contains('unavailable')) {
      return s.serverUnavailable;
    } else if (errorLower.contains('validation') ||
        errorLower.contains('required')) {
      return s.validationError;
    } else if (errorLower.contains('timeout')) {
      return s.timeoutError;
    }
    return s.defaultError;
  }
}

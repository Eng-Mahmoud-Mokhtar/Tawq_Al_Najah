import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:tawqalnajah/core/utiles/colors.dart';
import 'package:tawqalnajah/core/utiles/Images.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../Core/Widgets/CountryCubit.dart';

// ========================================
// CUBIT
// ========================================
class CountryContentWidget extends StatelessWidget {
  final double screenWidth;
  final Function(String countryCode, String countryShort)? onCountrySelected;

  const CountryContentWidget({
    super.key,
    required this.screenWidth,
    this.onCountrySelected
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CountryCubit>().state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).ChooseCountryCode,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: screenWidth * 0.05,
                color: Colors.grey,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.02),
        Container(
          height: screenWidth * 0.12,
          decoration: BoxDecoration(
            color: const Color(0xffFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffE9E9E9)),
          ),
          child: TextField(
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: S.of(context).Country,
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.035,
              ),
              prefixIcon: Icon(
                Icons.search_outlined,
                color: Colors.grey,
                size: screenWidth * 0.05,
              ),
            ),
            onChanged: (query) =>
                context.read<CountryCubit>().filterCountries(query),
          ),
        ),
        SizedBox(height: screenWidth * 0.02),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: state.filteredCountries.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'Assets/magnifying-glass.png',
                    width: screenWidth * 0.3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    S.of(context).NoResultstoShow,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.3),
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: state.filteredCountries.length,
              itemBuilder: (context, index) {
                var country = state.filteredCountries[index];
                return ListTile(
                  title: Row(
                    children: [
                      Text(
                        country['flag']!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: screenWidth * 0.12,
                        child: Text(
                          '+${country['code']!}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          country['name']!,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    context.read<CountryCubit>().selectCountry(country);
                    onCountrySelected?.call('+${country['code']!}', country['short']!);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

abstract class SocialPartnershipEvent extends Equatable {
  const SocialPartnershipEvent();
  @override
  List<Object> get props => [];
}

class SocialPartnershipSubmitted extends SocialPartnershipEvent {
  final Map<String, dynamic> formData;
  final BuildContext context;

  const SocialPartnershipSubmitted(this.formData, this.context);
  @override
  List<Object> get props => [formData, context];
}

class SocialPartnershipState extends Equatable {
  final bool isLoading;
  final Map<String, String> errors;
  final bool isSuccess;
  final String? serverError;
  final bool showGlobalError;
  final bool? shouldShowFinalDialog;

  const SocialPartnershipState({
    this.isLoading = false,
    this.errors = const {},
    this.isSuccess = false,
    this.serverError,
    this.showGlobalError = false,
    this.shouldShowFinalDialog,
  });

  SocialPartnershipState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    bool? isSuccess,
    String? serverError,
    bool? showGlobalError,
    bool? shouldShowFinalDialog,
  }) {
    return SocialPartnershipState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      isSuccess: isSuccess ?? this.isSuccess,
      serverError: serverError ?? this.serverError,
      showGlobalError: showGlobalError ?? this.showGlobalError,
      shouldShowFinalDialog:
      shouldShowFinalDialog ?? this.shouldShowFinalDialog,
    );
  }

  @override
  List<Object> get props => [
    isLoading,
    errors,
    isSuccess,
    serverError ?? '',
    showGlobalError,
    shouldShowFinalDialog ?? false,
  ];
}

class SocialPartnershipCubit extends Cubit<SocialPartnershipState> {
  final Dio dio;

  SocialPartnershipCubit({required this.dio})
      : super(const SocialPartnershipState()) {
    dio.options = BaseOptions(
      baseUrl: 'https://toknagah.viking-iceland.online/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
      validateStatus: (status) => true,
    );
    dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }

  Future<void> submitPartnershipRequest(
      Map<String, dynamic> formData, BuildContext context) async {
    final s = S.of(context);
    emit(state.copyWith(isLoading: true, errors: {}, serverError: null));

    try {
      final validationErrors = _validateForm(formData, s);
      if (validationErrors.isNotEmpty) {
        emit(state.copyWith(isLoading: false, errors: validationErrors));
        return;
      }

      final body = {
        "name": (formData['name'] ?? '').toString().trim(),
        "representative_name": (formData['representative_name'] ?? '').toString().trim(),
        "phone": (formData['phone'] ?? '').toString().trim(),
        "code_phone": (formData['code_phone'] ?? '').toString().trim(),
        "country": (formData['country'] ?? '').toString().trim(),
        "city": (formData['city'] ?? '').toString().trim(),
        "address": (formData['address'] ?? '').toString().trim(),
      };

      final response = await dio.post('/user/add-request-charity', data: body);

      _handleResponse(response, context);
    } on DioException catch (e) {
      _handleDioError(e, context);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        serverError: s.registrationFailed,
        showGlobalError: true,
        shouldShowFinalDialog: true,
      ));
    }
  }

  void _handleResponse(Response response, BuildContext context) {
    final data = response.data;
    final s = S.of(context);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data is Map && data['errors'] != null) {
        _handleApiError(data, context);
        return;
      }

      final success = data['success'] == true ||
          data['status'] == true ||
          data['message'] != null;

      if (success) {
        emit(state.copyWith(
          isLoading: false,
          isSuccess: true,
          errors: {},
          showGlobalError: false,
          shouldShowFinalDialog: false,
        ));
      } else {
        final errorMsg = data['message']?.toString() ?? s.registrationFailed;
        emit(state.copyWith(
          isLoading: false,
          serverError: errorMsg,
          showGlobalError: true,
          shouldShowFinalDialog: true,
        ));
      }
    } else {
      _handleApiError(response.data, context);
    }
  }

  String _getUserFriendlyErrorMessage(String error, S s) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('required')) {
      if (errorLower.contains('name')) return s.fieldRequired;
      if (errorLower.contains('representative')) return s.fieldRequired;
      if (errorLower.contains('phone')) return s.phoneRequired;
      if (errorLower.contains('country')) return s.countryRequired;
      if (errorLower.contains('city')) return s.cityRequired;
      if (errorLower.contains('address')) return s.locationRequired;
      return s.fieldRequired;
    } else if (errorLower.contains('unique')) {
      if (errorLower.contains('phone')) return s.phoneUsed;
      return s.phoneUsed; // Default for unique constraint errors
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

    return s.registrationFailed;
  }

  void _handleApiError(dynamic errorData, BuildContext context) {
    final s = S.of(context);
    final errors = <String, String>{};

    if (errorData is Map && errorData['errors'] != null) {
      final errorMap = errorData['errors'] as Map;
      errorMap.forEach((key, value) {
        final keyString = key.toString();
        if (value is List && value.isNotEmpty) {
          final errorMessage = value.first.toString();
          errors[keyString] = _getUserFriendlyErrorMessage(errorMessage, s);
        } else if (value is String) {
          errors[keyString] = _getUserFriendlyErrorMessage(value, s);
        }
      });

      emit(state.copyWith(
        isLoading: false,
        errors: errors,
        serverError: null,
        showGlobalError: false,
        shouldShowFinalDialog: true,
      ));
    } else {
      final errorMessage = errorData is Map && errorData['message'] != null
          ? _getUserFriendlyErrorMessage(errorData['message'].toString(), s)
          : s.registrationFailed;

      emit(state.copyWith(
        isLoading: false,
        serverError: errorMessage,
        showGlobalError: true,
        shouldShowFinalDialog: true,
      ));
    }
  }

  void _handleDioError(DioException e, BuildContext context) {
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

    emit(state.copyWith(
      isLoading: false,
      serverError: errorMessage,
      showGlobalError: true,
      shouldShowFinalDialog: true,
    ));
  }

  Map<String, String> _validateForm(Map<String, dynamic> formData, S s) {
    final errors = <String, String>{};

    if ((formData['name']?.toString().trim().isEmpty ?? true)) {
      errors['name'] = s.fieldRequired;
    }

    if ((formData['representative_name']?.toString().trim().isEmpty ?? true)) {
      errors['representative_name'] = s.fieldRequired;
    }

    if ((formData['code_phone']?.toString().trim().isEmpty ?? true)) {
      errors['code_phone'] = s.countryCodeRequired;
    }

    if ((formData['phone']?.toString().trim().isEmpty ?? true)) {
      errors['phone'] = s.phoneRequired;
    } else if (!_isValidPhoneNumber(formData['phone'].toString())) {
      errors['phone'] = s.invalidPhone;
    }

    if ((formData['country']?.toString().trim().isEmpty ?? true)) {
      errors['country'] = s.countryRequired;
    }

    if ((formData['city']?.toString().trim().isEmpty ?? true)) {
      errors['city'] = s.cityRequired;
    }

    if ((formData['address']?.toString().trim().isEmpty ?? true)) {
      errors['address'] = s.locationRequired;
    }

    return errors;
  }

  bool _isValidPhoneNumber(String phone) =>
      RegExp(r'^[0-9]{7,15}$').hasMatch(phone);

  void removeFieldError(String fieldName) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors.remove(fieldName);
    emit(state.copyWith(errors: newErrors));
  }

  void resetFinalDialog() {
    emit(state.copyWith(shouldShowFinalDialog: false));
  }
}

// ========================================
// MAIN WIDGET - SocialPartnership
// ========================================

class SocialPartnership extends StatefulWidget {
  const SocialPartnership({super.key});

  @override
  State<SocialPartnership> createState() => _SocialPartnershipState();
}

class _SocialPartnershipState extends State<SocialPartnership> {
  final TextEditingController _entityController = TextEditingController();
  final TextEditingController _representativeController =
  TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _selectedCountryCode = '+20';
  bool _isCountryCodeSelected = true;

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = '+20';
    _isCountryCodeSelected = true;
  }

  @override
  void dispose() {
    _entityController.dispose();
    _representativeController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context) {
    final s = S.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: s.successTitle,
        desc: s.donationSentSuccessfully,
        btnOkOnPress: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        btnOkText: s.continueToLogin,
        btnOkColor: KprimaryColor,
      ).show();
    });
  }

  void _showErrorDialog(BuildContext context, String message) {
    final s = S.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: s.failedTitle,
        desc: s.registrationFailed,
        btnOkOnPress: () {
          final cubit = BlocProvider.of<SocialPartnershipCubit>(context);
          cubit.resetFinalDialog();
        },
        btnOkText: s.tryAgain,
        btnOkColor: const Color(0xffDD0C0C),
      ).show();
    });
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? errorKey,
    TextInputType inputType = TextInputType.text,
    bool readOnly = false,
    required BuildContext cubitContext,
  }) {
    final screenWidth = MediaQuery.of(cubitContext).size.width;
    final screenHeight = MediaQuery.of(cubitContext).size.height;

    return BlocBuilder<SocialPartnershipCubit, SocialPartnershipState>(
      builder: (context, state) {
        final hasError = errorKey != null && state.errors.containsKey(errorKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: KprimaryText,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            SizedBox(
              height: screenWidth * 0.12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color:
                  readOnly ? Colors.grey.shade300 : const Color(0xffFAFAFA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xffE9E9E9)),
                ),
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  onChanged: (value) {
                    // إزالة الخطأ عند الكتابة
                    if (hasError && value.trim().isNotEmpty) {
                      Future.microtask(() {
                        BlocProvider.of<SocialPartnershipCubit>(context)
                            .removeFieldError(errorKey!);
                      });
                    }
                  },
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: KprimaryText,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: inputType,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                    hintText: hint,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.035,
                      horizontal: screenWidth * 0.035,
                    ),
                  ),
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  state.errors[errorKey]!,
                  style: TextStyle(
                    color: const Color(0xffDD0C0C),
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildPhoneField({
    required BuildContext cubitContext,
  }) {
    final screenWidth = MediaQuery.of(cubitContext).size.width;
    final screenHeight = MediaQuery.of(cubitContext).size.height;

    return BlocBuilder<SocialPartnershipCubit, SocialPartnershipState>(
      builder: (context, state) {
        final hasPhoneError = state.errors.containsKey('phone');
        final hasCodePhoneError = state.errors.containsKey('code_phone');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).PhoneNumber,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.01),
            SizedBox(
              height: screenWidth * 0.12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xffFAFAFA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xffE9E9E9)),
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _showCountryPicker(context),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02),
                          child: Row(
                            children: [
                              Text(_selectedCountryCode,
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.bold)),
                              Icon(Icons.keyboard_arrow_down,
                                  size: screenWidth * 0.05,
                                  color: Colors.grey.shade500),
                              SizedBox(width: screenWidth * 0.01),
                              Container(
                                height: screenWidth * 0.1,
                                width: 1.0,
                                color: Colors.grey.shade300,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            hintText: '1001234567',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.035),
                          ),
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            // إزالة خطأ الهاتف عند الكتابة
                            if (hasPhoneError && value.trim().isNotEmpty) {
                              Future.microtask(() {
                                BlocProvider.of<SocialPartnershipCubit>(context)
                                    .removeFieldError('phone');
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // عرض أخطاء حقل الهاتف
            if (hasCodePhoneError)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  state.errors['code_phone']!,
                  style: TextStyle(
                    color: Color(0xffDD0C0C),
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ),
            if (hasPhoneError)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  state.errors['phone']!,
                  style: TextStyle(
                    color: Color(0xffDD0C0C),
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showCountryPicker(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.95,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: CountryContentWidget(
                screenWidth: screenWidth,
                onCountrySelected: (countryCode, countryShort) {
                  setState(() {
                    _selectedCountryCode = countryCode;
                    _isCountryCodeSelected = true;
                  });
                  // إزالة خطأ code_phone عند اختيار كود الدولة
                  if (countryCode.isNotEmpty) {
                    Future.microtask(() {
                      final cubit = BlocProvider.of<SocialPartnershipCubit>(context);
                      if (cubit.state.errors.containsKey('code_phone')) {
                        cubit.removeFieldError('code_phone');
                      }
                    });
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  void _handleCubitState(BuildContext context, SocialPartnershipState state) {
    if (state.isSuccess) {
      _showSuccessDialog(context);
    }

    if (state.shouldShowFinalDialog == true && state.serverError != null) {
      _showErrorDialog(context, state.serverError!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) => SocialPartnershipCubit(dio: Dio()),
      child: BlocListener<SocialPartnershipCubit, SocialPartnershipState>(
        listener: (context, state) {
          _handleCubitState(context, state);
        },
        child: Builder(
          builder: (cubitContext) {
            return Scaffold(
              backgroundColor: SecoundColor,
              body: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.1),
                              Center(
                                child: Image.asset(
                                  KprimaryImage,
                                  width: screenWidth * 0.5,
                                  height: screenHeight * 0.15,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              _buildField(
                                label: s.ParticipatingEntity,
                                hint: s.ParticipatingEntity,
                                controller: _entityController,
                                errorKey: 'name',
                                cubitContext: cubitContext,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              _buildField(
                                label: s.RepresentativeName,
                                hint: s.RepresentativeName,
                                controller: _representativeController,
                                errorKey: 'representative_name',
                                cubitContext: cubitContext,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              _buildPhoneField(cubitContext: cubitContext),
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildField(
                                      label: s.Country,
                                      hint: s.Country,
                                      controller: _countryController,
                                      errorKey: 'country',
                                      cubitContext: cubitContext,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.04),
                                  Expanded(
                                    child: _buildField(
                                      label: s.City,
                                      hint: s.City,
                                      controller: _cityController,
                                      errorKey: 'city',
                                      cubitContext: cubitContext,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              _buildField(
                                label: s.location,
                                hint: s.location,
                                controller: _addressController,
                                errorKey: 'address',
                                cubitContext: cubitContext,
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              BlocBuilder<SocialPartnershipCubit,
                                  SocialPartnershipState>(
                                builder: (context, state) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: screenWidth * 0.12,
                                    child: ElevatedButton(
                                      onPressed: state.isLoading
                                          ? null
                                          : () {
                                        final formData = {
                                          'name':
                                          _entityController.text.trim(),
                                          'representative_name':
                                          _representativeController
                                              .text
                                              .trim(),
                                          'phone':
                                          _phoneController.text.trim(),
                                          'code_phone': _selectedCountryCode,
                                          'country': _countryController.text
                                              .trim(),
                                          'city':
                                          _cityController.text.trim(),
                                          'address': _addressController.text
                                              .trim(),
                                        };

                                        BlocProvider.of<
                                            SocialPartnershipCubit>(
                                            context)
                                            .submitPartnershipRequest(
                                            formData, context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: state.isLoading
                                            ? Colors.grey[400]
                                            : KprimaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: state.isLoading
                                          ? Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: screenWidth * 0.04,
                                            height: screenWidth * 0.04,
                                            child:
                                            const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.02),
                                          Text(
                                            s.loading,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth * 0.03,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                          : Text(
                                        s.submitRequest,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.03,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: screenHeight * 0.03),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.01,
                    child: SafeArea(
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: KprimaryText,
                          size: screenHeight * 0.03,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
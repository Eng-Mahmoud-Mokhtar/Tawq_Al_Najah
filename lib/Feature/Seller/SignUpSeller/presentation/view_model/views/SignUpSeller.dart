import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tawqalnajah/core/utiles/colors.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../Core/Widgets/alreadyHaveAccount.dart';
import '../../../../../../Core/utiles/Images.dart';
import '../../../../../Auth/presentation/login.dart';
import '../../../../../Buyer/SignUpBuyer/presentation/view_model/views/widgets/phone_field.dart';

abstract class SellerCompleteRegisterEvent extends Equatable {
  const SellerCompleteRegisterEvent();
  @override
  List<Object> get props => [];
}

class SellerCompleteRegisterSubmitted extends SellerCompleteRegisterEvent {
  final Map<String, dynamic> formData;
  final BuildContext context;
  final String? commercialRegisterFilePath;
  final Uint8List? commercialRegisterBytes;
  final String? commercialRegisterName;
  const SellerCompleteRegisterSubmitted(
      this.formData,
      this.context, {
        this.commercialRegisterFilePath,
        this.commercialRegisterBytes,
        this.commercialRegisterName,
      });
  @override
  List<Object> get props => [formData, context];
}

class SellerCompleteRegisterState extends Equatable {
  final bool isLoading;
  final Map<String, String> errors;
  final bool isSuccess;
  final String? serverError;
  final bool showGlobalError;
  final Map<String, dynamic>? formData;
  final bool? shouldShowFinalDialog;

  const SellerCompleteRegisterState({
    this.isLoading = false,
    this.errors = const {},
    this.isSuccess = false,
    this.serverError,
    this.showGlobalError = false,
    this.formData,
    this.shouldShowFinalDialog,
  });

  SellerCompleteRegisterState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    bool? isSuccess,
    String? serverError,
    bool? showGlobalError,
    Map<String, dynamic>? formData,
    bool? shouldShowFinalDialog,
  }) {
    return SellerCompleteRegisterState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      isSuccess: isSuccess ?? this.isSuccess,
      serverError: serverError ?? this.serverError,
      showGlobalError: showGlobalError ?? this.showGlobalError,
      formData: formData ?? this.formData,
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
    formData ?? {},
    shouldShowFinalDialog ?? false,
  ];
}

class SellerCompleteRegisterCubit extends Cubit<SellerCompleteRegisterState> {
  final Dio dio;
  SellerCompleteRegisterCubit({required this.dio})
      : super(const SellerCompleteRegisterState()) {
    dio.options = BaseOptions(
      baseUrl: 'https://toknagah.viking-iceland.online/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
      },
      validateStatus: (status) => true,
    );
    dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }

  String _safeFilename(String pathOrName) {
    final p = pathOrName;
    final lastSlash = p.lastIndexOf('/');
    final lastBack = p.lastIndexOf('\\');
    final cut = [lastSlash, lastBack].reduce((a, b) => a > b ? a : b);
    if (cut != -1 && cut + 1 < p.length) return p.substring(cut + 1);
    return p;
  }

  Future<void> completeRegisterMultipart(
      Map<String, dynamic> formData,
      BuildContext context, {
        String? imageFilePath,
        Uint8List? imageBytes,
        String? imageName,
        String? commercialRegisterFilePath,
        Uint8List? commercialRegisterBytes,
        String? commercialRegisterName,
      }) async {
    final s = S.of(context);
    emit(state.copyWith(isLoading: true, errors: {}, serverError: null));

    try {
      final validationErrors = _validateCompleteForm(formData, s);
      if (validationErrors.isNotEmpty) {
        emit(state.copyWith(isLoading: false, errors: validationErrors));
        return;
      }

      final String activityRaw =
      (formData['activity_type'] ?? '').toString().trim();
      final String countBranchesStr =
      (formData['count_branches'] ?? '').toString();
      final String areaStr = (formData['area'] ?? '').toString();
      final String periodStr = (formData['period'] ?? '').toString();

      final form = FormData();
      form.fields.add(MapEntry('type', 'saller'));
      form.fields.add(MapEntry('username',
          (formData['username'] ?? formData['name'] ?? '').toString().trim()));
      form.fields.add(MapEntry('email', (formData['email'] ?? '').toString()));
      form.fields
          .add(MapEntry('code_phone', (formData['code_phone'] ?? '').toString()));
      form.fields.add(MapEntry('phone', (formData['phone'] ?? '').toString()));
      form.fields
          .add(MapEntry('country', (formData['country'] ?? '').toString()));
      form.fields
          .add(MapEntry('password', (formData['password'] ?? '').toString()));
      form.fields.add(MapEntry(
          'password_confirmation', (formData['password'] ?? '').toString()));
      form.fields
          .add(MapEntry('location', (formData['location'] ?? '').toString()));
      form.fields.add(MapEntry('city', (formData['city'] ?? '').toString()));
      form.fields.add(MapEntry('activity_type', activityRaw));
      form.fields.add(MapEntry('count_branches', countBranchesStr));
      form.fields.add(MapEntry('area', areaStr));
      form.fields.add(MapEntry('period', periodStr));

      final String referralBy =
      (formData['referral_by'] ?? formData['referral_code'] ?? '')
          .toString()
          .trim();
      if (referralBy.isNotEmpty) {
        form.fields.add(MapEntry('referral_by', referralBy));
      }

      String linkFacebook = (formData['linkFacebook'] ?? '').toString();
      String linkWhatsapp = (formData['linkWhatsapp'] ?? '').toString();
      String linkInsta = (formData['linkInsta'] ?? '').toString();
      String linkSnab = (formData['linkSnab'] ?? '').toString();

      final socialLinks =
          formData['social_links'] as List<Map<String, dynamic>>? ?? [];
      for (final link in socialLinks) {
        final type = (link['type'] ?? '').toString().toLowerCase();
        final url = (link['url'] ?? '').toString();
        if (type == 'facebook' && url.isNotEmpty) linkFacebook = url;
        if (type == 'whatsapp' && url.isNotEmpty) linkWhatsapp = url;
        if (type == 'instagram' && url.isNotEmpty) linkInsta = url;
        if (type == 'snapchat' && url.isNotEmpty) linkSnab = url;
      }
      form.fields.add(MapEntry('linkFacebook', linkFacebook));
      form.fields.add(MapEntry('linkWhatsapp', linkWhatsapp));
      form.fields.add(MapEntry('linkInsta', linkInsta));
      form.fields.add(MapEntry('linkSnab', linkSnab));

      if (imageBytes != null && (imageName?.isNotEmpty ?? false)) {
        form.files.add(MapEntry(
          'image',
          MultipartFile.fromBytes(imageBytes, filename: imageName),
        ));
      } else if (imageFilePath != null &&
          imageFilePath.isNotEmpty &&
          !kIsWeb) {
        form.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imageFilePath,
              filename: _safeFilename(imageFilePath)),
        ));
      }
      if (commercialRegisterBytes != null &&
          (commercialRegisterName?.isNotEmpty ?? false)) {
        form.files.add(MapEntry(
          'commercial_register',
          MultipartFile.fromBytes(commercialRegisterBytes,
              filename: commercialRegisterName),
        ));
      } else if (commercialRegisterFilePath != null &&
          commercialRegisterFilePath.isNotEmpty &&
          !kIsWeb) {
        form.files.add(MapEntry(
          'commercial_register',
          await MultipartFile.fromFile(commercialRegisterFilePath,
              filename: _safeFilename(commercialRegisterFilePath)),
        ));
      }

      if (formData['branches'] != null && formData['branches'] is List) {
        final branches = (formData['branches'] as List);
        final addresses = <String>[];
        for (final b in branches) {
          if (b is Map) {
            final loc = (b['location'] ?? '').toString().trim();
            if (loc.isNotEmpty) addresses.add(loc);
          } else if (b is String) {
            final loc = b.trim();
            if (loc.isNotEmpty) addresses.add(loc);
          }
        }
        for (int i = 0; i < addresses.length; i++) {
          form.fields.add(MapEntry('branches[$i]', addresses[i]));
        }
      }

      final response = await dio.post(
        '/user/auth/register',
        data: form,
        options: Options(
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

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
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data is Map && data['errors'] != null) {
        _handleApiError(data, context);
        return;
      }
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        errors: {},
        showGlobalError: false,
        shouldShowFinalDialog: false,
      ));
    } else {
      _handleApiError(response.data, context);
    }
  }

  String _getUserFriendlyErrorMessage(String error, S s) {
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
    } else if (errorLower.contains('email') &&
        errorLower.contains('required')) {
      return s.emailRequired;
    } else if (errorLower.contains('phone') &&
        errorLower.contains('required')) {
      return s.phoneRequired;
    } else if (errorLower.contains('password') &&
        errorLower.contains('required')) {
      return s.passwordRequired;
    } else if (errorLower.contains('country') &&
        errorLower.contains('required')) {
      return s.countryRequired;
    } else if (errorLower.contains('city') && errorLower.contains('required')) {
      return s.cityRequired;
    } else if (errorLower.contains('location') &&
        errorLower.contains('required')) {
      return s.locationRequired;
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
          ? _getUserFriendlyErrorMessage(
          errorData['message'].toString(), s)
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

  Map<String, String> _validateCompleteForm(
      Map<String, dynamic> formData,
      S s,
      ) {
    final errors = <String, String>{};
    if (formData['name']?.toString().trim().isEmpty ?? true) {
      errors['name'] = s.nameRequired;
    } else if ((formData['name'] as String).length < 3) {
      errors['name'] = s.nameMinLength;
    }

    if (formData['email']?.toString().trim().isEmpty ?? true) {
      errors['email'] = s.emailRequired;
    } else if (!_isValidEmail(formData['email'].toString())) {
      errors['email'] = s.emailInvalid;
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

    if (formData['city']?.toString().trim().isEmpty ?? true) {
      errors['city'] = s.cityRequired;
    }

    if (formData['location']?.toString().trim().isEmpty ?? true) {
      errors['location'] = s.locationRequired;
    }

    if (formData['activity_type']?.toString().trim().isEmpty ?? true) {
      errors['activity_type'] = s.pleaseSelectCategory;
    }

    if (formData['count_branches']?.toString().trim().isEmpty ?? true) {
      errors['count_branches'] = s.fieldRequired;
    } else {
      final count = int.tryParse(formData['count_branches'].toString());
      if (count == null || count <= 0) {
        errors['count_branches'] = s.fieldRequired;
      }
    }

    if (formData['area']?.toString().trim().isEmpty ?? true) {
      errors['area'] = s.fieldRequired;
    } else {
      final area = double.tryParse(formData['area'].toString());
      if (area == null || area <= 0) {
        errors['area'] = s.fieldRequired;
      }
    }

    if (formData['period']?.toString().trim().isEmpty ?? true) {
      errors['period'] = s.fieldRequired;
    } else {
      final period = int.tryParse(formData['period'].toString().trim());
      if (period == null || period <= 0) {
        errors['period'] = s.fieldRequired;
      }
    }

    final branches = formData['branches'] as List<dynamic>? ?? [];
    for (int i = 0; i < branches.length; i++) {
      final branch = branches[i];
      if (branch is Map) {
        final location = branch['location']?.toString() ?? '';
        if (location.trim().isEmpty) {
          errors['branch_location_$i'] = s.fieldRequired;
        }
      } else if (branch is String) {
        if (branch.trim().isEmpty) {
          errors['branch_location_$i'] = s.fieldRequired;
        }
      }
    }

    return errors;
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool _isValidPhoneNumber(String phone) =>
      RegExp(r'^[0-9]{7,15}$').hasMatch(phone);

  void registerSeller(
      Map<String, dynamic> formData,
      BuildContext context, {
        String? imageFilePath,
        Uint8List? imageBytes,
        String? imageName,
        String? commercialRegisterFilePath,
        Uint8List? commercialRegisterBytes,
        String? commercialRegisterName,
      }) {
    completeRegisterMultipart(
      formData,
      context,
      imageFilePath: imageFilePath,
      imageBytes: imageBytes,
      imageName: imageName,
      commercialRegisterFilePath: commercialRegisterFilePath,
      commercialRegisterBytes: commercialRegisterBytes,
      commercialRegisterName: commercialRegisterName,
    );
  }

  void removeFieldError(String fieldName) {
    final newErrors = Map<String, String>.from(state.errors);
    newErrors.remove(fieldName);
    emit(state.copyWith(errors: newErrors));
  }

  void resetFinalDialog() {
    emit(state.copyWith(shouldShowFinalDialog: false));
  }
}

class SignUpSeller extends StatefulWidget {
  final Map<String, dynamic>? savedData;
  final String? errorFieldToFocus;

  const SignUpSeller({super.key, this.savedData, this.errorFieldToFocus});

  @override
  State<SignUpSeller> createState() => _SignUpSellerState();
}

class _SignUpSellerState extends State<SignUpSeller> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedCountryCode = '+20';
  bool _isCountryCodeSelected = true;
  Map<String, String> _fieldErrors = {};

  Map<String, dynamic>? _savedCompleteData;

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = '+20';
    _isCountryCodeSelected = true;
    if (widget.savedData != null) {
      _nameController.text = widget.savedData?['name']?.toString() ?? '';
      _emailController.text = widget.savedData?['email']?.toString() ?? '';
      _passwordController.text =
          widget.savedData?['password']?.toString() ?? '';
      _selectedCountryCode =
          widget.savedData?['code_phone']?.toString() ?? '+20';
      _phoneController.text = widget.savedData?['phone']?.toString() ?? '';
      _countryController.text = widget.savedData?['country']?.toString() ?? '';
      _cityController.text = widget.savedData?['city']?.toString() ?? '';
      _addressController.text =
          widget.savedData?['location']?.toString() ?? '';
      _referralCodeController.text =
          widget.savedData?['referral_code']?.toString() ?? '';
    }

    if (widget.errorFieldToFocus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _fieldErrors[widget.errorFieldToFocus!] = '';
        });
      });
    }
  }

  Future<void> _validateAndNavigate() async {
    final s = S.of(context);
    _fieldErrors.clear();

    if (_nameController.text.trim().isEmpty) {
      _fieldErrors['name'] = s.nameRequired;
    } else if (_nameController.text.trim().length < 3) {
      _fieldErrors['name'] = s.nameMinLength;
    }

    if (_emailController.text.trim().isEmpty) {
      _fieldErrors['email'] = s.emailRequired;
    } else if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text.trim())) {
      _fieldErrors['email'] = s.emailInvalid;
    }

    if (_passwordController.text.isEmpty) {
      _fieldErrors['password'] = s.passwordRequired;
    } else if (_passwordController.text.length < 6) {
      _fieldErrors['password'] = s.passwordLength;
    }

    if (_selectedCountryCode.isEmpty) {
      _fieldErrors['code_phone'] = s.countryCodeRequired;
    }

    if (_phoneController.text.trim().isEmpty) {
      _fieldErrors['phone'] = s.phoneRequired;
    } else if (!RegExp(
      r'^[0-9]{7,15}$',
    ).hasMatch(_phoneController.text.trim())) {
      _fieldErrors['phone'] = s.invalidPhone;
    }

    if (_countryController.text.trim().isEmpty) {
      _fieldErrors['country'] = s.countryRequired;
    }

    if (_cityController.text.trim().isEmpty) {
      _fieldErrors['city'] = s.cityRequired;
    }

    if (_addressController.text.trim().isEmpty) {
      _fieldErrors['location'] = s.locationRequired;
    }

    if (_fieldErrors.isEmpty) {
      final basicInfo = {
        'name': _nameController.text.trim(),
        'username': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'code_phone': _selectedCountryCode,
        'phone': _phoneController.text.trim(),
        'country': _countryController.text.trim(),
        'city': _cityController.text.trim(),
        'location': _addressController.text.trim(),
        'referral_code': _referralCodeController.text.trim(),
      };

      final result = await Navigator.push<Map<String, dynamic>?>(
        context,
        MaterialPageRoute(
          builder: (context) => SellerCompleteSignUp(
            basicInfo: basicInfo,
            previousFieldErrors: _fieldErrors,
            savedData: _savedCompleteData,
          ),
        ),
      );

      if (result != null) {
        setState(() {
          _savedCompleteData = result;
        });
      }
    } else {
      setState(() {});
    }
  }

  Widget _buildField(
      String label,
      String hint, {
        TextInputType? type,
        TextEditingController? controller,
        bool obscureText = false,
        Widget? suffixIcon,
        String? errorKey,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
              color: const Color(0xffFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffE9E9E9)),
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: type,
              onChanged: (value) {
                if (errorKey != null && _fieldErrors.containsKey(errorKey)) {
                  setState(() {
                    _fieldErrors.remove(errorKey);
                  });
                }
              },
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: KprimaryText,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.035,
                  horizontal: screenWidth * 0.035,
                ),
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        ),
        if (errorKey != null && _fieldErrors.containsKey(errorKey))
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _fieldErrors[errorKey]!,
              style: TextStyle(
                color: const Color(0xffDD0C0C),
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: SecoundColor,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Form(
                    key: _formKey,
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
                          s.FullName,
                          s.FullName,
                          controller: _nameController,
                          errorKey: 'name',
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PhoneFieldWidget(
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              phoneController: _phoneController,
                              selectedCountryCode: _selectedCountryCode,
                              isCountryCodeSelected: _isCountryCodeSelected,
                              onCountryCodeChanged: (code) {
                                setState(() {
                                  _selectedCountryCode = code;
                                  _isCountryCodeSelected = true;
                                  _fieldErrors.remove('code_phone');
                                });
                              },
                              errors: _fieldErrors,
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildField(
                          s.email,
                          s.email,
                          controller: _emailController,
                          type: TextInputType.emailAddress,
                          errorKey: 'email',
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildField(
                          s.password,
                          s.password,
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          errorKey: 'password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey.shade600,
                              size: screenWidth * 0.05,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          S.of(context).ReferralCode,
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
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xffE9E9E9),
                              ),
                            ),
                            child: TextField(
                              controller: _referralCodeController,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: KprimaryText,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                                hintText: "#######",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.035,
                                  horizontal: screenWidth * 0.035,
                                ),
                              ),
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                s.Country,
                                s.Country,
                                controller: _countryController,
                                errorKey: 'country',
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            Expanded(
                              child: _buildField(
                                s.City,
                                s.City,
                                controller: _cityController,
                                errorKey: 'city',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildField(
                          s.location,
                          s.location,
                          controller: _addressController,
                          errorKey: 'location',
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        SizedBox(
                          width: double.infinity,
                          height: screenWidth * 0.12,
                          child: ElevatedButton(
                            onPressed: _validateAndNavigate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KprimaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              s.Next,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        const AlreadyHaveAccount(),
                      ],
                    ),
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
  }
}

class SellerCompleteSignUp extends StatefulWidget {
  final Map<String, dynamic> basicInfo;
  final Map<String, String>? previousFieldErrors;
  final Map<String, dynamic>? savedData;

  const SellerCompleteSignUp({
    super.key,
    required this.basicInfo,
    this.previousFieldErrors,
    this.savedData,
  });

  @override
  State<SellerCompleteSignUp> createState() => _SellerCompleteSignUpState();
}

class _SellerCompleteSignUpState extends State<SellerCompleteSignUp> {
  String? _selectedActivityCode;
  Uint8List? _commercialRegisterBytes;
  String? _commercialRegisterFilePath;
  String? _commercialRegisterFileName;

  final TextEditingController _branchesCountController =
  TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  final TextEditingController _socialLinkController = TextEditingController();

  final List<TextEditingController> _branchLocationControllers = [];
  final List<Map<String, dynamic>> _socialLinks = [];

  final ScrollController _scrollController = ScrollController();

  Map<String, String> _fieldErrors = {};
  SellerCompleteRegisterCubit? _cubit;
  StreamSubscription? _cubitSubscription;

  bool _isSubmitting = false;

  Map<String, dynamic>? _detectPlatform(String url) {
    if (url.contains('facebook') || url.contains('fb.com')) {
      return {
        'type': 'Facebook',
        'icon': FontAwesomeIcons.facebook,
        'color': const Color(0xFF1877F2),
      };
    } else if (url.contains('instagram') || url.contains('instagr.am')) {
      return {
        'type': 'Instagram',
        'icon': FontAwesomeIcons.instagram,
        'color': const Color(0xFF833AB4),
      };
    } else if (url.contains('whatsapp') || url.contains('wa.me')) {
      return {
        'type': 'WhatsApp',
        'icon': FontAwesomeIcons.whatsapp,
        'color': const Color(0xFF25D366),
      };
    } else if (url.contains('snapchat')) {
      return {
        'type': 'Snapchat',
        'icon': FontAwesomeIcons.snapchat,
        'color': Colors.amber[700]!,
      };
    }
    return null;
  }

  Map<String, String> _activityMap(S s) => {
    'fashion': s.fashion,
    'electronics': s.electronics,
    'health': s.health,
    'toys': s.toys,
    'furniture': s.furniture,
    'kitchen': s.kitchen,
    'books': s.books,
    'other': s.otherCategory,
  };

  String? _codeFromLabel(String? label, S s) {
    if (label == null || label.isEmpty) return null;
    final map = _activityMap(s);
    try {
      return map.entries
          .firstWhere(
            (e) =>
        e.value.toLowerCase().trim() == label.toLowerCase().trim(),
      )
          .key;
    } catch (_) {
      final lower = label.toLowerCase().trim();
      const candidates = [
        'fashion',
        'electronics',
        'health',
        'toys',
        'furniture',
        'kitchen',
        'books',
        'other',
      ];
      return candidates.contains(lower) ? lower : null;
    }
  }

  @override
  void initState() {
    super.initState();
    _periodController.text = '3';
    _branchesCountController.text = '1';
    _branchesCountController.addListener(_updateBranches);

    if (_branchLocationControllers.isEmpty) {
      _branchLocationControllers.add(TextEditingController());
    }

    if (widget.previousFieldErrors != null &&
        widget.previousFieldErrors!.isNotEmpty) {
      _fieldErrors = Map.from(widget.previousFieldErrors!);
    }

    if (widget.savedData != null) {
      final saved = widget.savedData!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final s = S.of(context);
        final savedAct = saved['activity_type']?.toString();
        _selectedActivityCode = _codeFromLabel(savedAct, s) ?? savedAct;
        setState(() {});
      });

      _branchesCountController.text =
      (saved['count_branches']?.toString().isNotEmpty == true)
          ? saved['count_branches'].toString()
          : _branchesCountController.text;

      _areaController.text = (saved['area']?.toString().isNotEmpty == true)
          ? saved['area'].toString()
          : _areaController.text;

      _periodController.text = (saved['period']?.toString().isNotEmpty == true)
          ? saved['period'].toString()
          : _periodController.text;

      if (saved['branches'] is List) {
        final branches = (saved['branches'] as List);
        final locations = <String>[];
        for (final b in branches) {
          if (b is Map) {
            final loc = (b['location'] ?? '').toString();
            if (loc.isNotEmpty) locations.add(loc);
          } else if (b is String) {
            final loc = b.toString();
            if (loc.isNotEmpty) locations.add(loc);
          }
        }
        if (locations.isNotEmpty) {
          while (_branchLocationControllers.length < locations.length) {
            _branchLocationControllers.add(TextEditingController());
          }
          while (_branchLocationControllers.length > locations.length) {
            _branchLocationControllers.removeLast();
          }
          for (int i = 0; i < locations.length; i++) {
            _branchLocationControllers[i].text = locations[i];
          }
        }
      }

      if (saved['social_links'] is List) {
        final links = (saved['social_links'] as List)
            .whereType<Map<String, dynamic>>()
            .toList();
        _socialLinks.clear();
        for (final link in links) {
          final url = link['url']?.toString() ?? '';
          if (url.isNotEmpty) {
            final platform = _detectPlatform(url);
            _socialLinks.add({
              'url': url,
              'icon': platform?['icon'] ?? Icons.link,
              'color': platform?['color'] ?? Colors.grey,
              'type': platform?['type'] ?? (link['type'] ?? ''),
            });
          }
        }
      }

      if (saved['commercial_register']?.toString().isNotEmpty == true) {
        _commercialRegisterFileName = saved['commercial_register'].toString();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBranches();
    });
  }

  @override
  void dispose() {
    _branchesCountController.removeListener(_updateBranches);
    _branchesCountController.dispose();
    _areaController.dispose();
    _periodController.dispose();
    _socialLinkController.dispose();
    _scrollController.dispose();
    _cubitSubscription?.cancel();
    _cubit?.close();
    for (final c in _branchLocationControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateBranches() {
    if (!mounted) return;

    int count = int.tryParse(_branchesCountController.text) ?? 1;

    if (count < 1) {
      count = 1;
      _branchesCountController.text = '1';
    }

    if (count > _branchLocationControllers.length) {
      for (int i = _branchLocationControllers.length; i < count; i++) {
        _branchLocationControllers.add(TextEditingController());
      }
    } else if (count < _branchLocationControllers.length) {
      for (int i = _branchLocationControllers.length - 1; i >= count; i--) {
        _branchLocationControllers.removeAt(i);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickCommercialRegisterFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;
        setState(() {
          _commercialRegisterFileName = file.name;
          if (kIsWeb) {
            _commercialRegisterBytes = file.bytes;
            _commercialRegisterFilePath = null;
          } else {
            _commercialRegisterBytes = null;
            _commercialRegisterFilePath = file.path;
          }
        });
      }
    } catch (e) {}
  }

  Widget _buildField(
      String label,
      String hint, {
        TextInputType? type,
        String? suffix,
        TextEditingController? controller,
        Function(String)? onChanged,
        bool readOnly = false,
        String? errorKey,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final hasError = errorKey != null && _fieldErrors.containsKey(errorKey);

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
        SizedBox(height: screenHeight * 0.008),
        SizedBox(
          height: screenWidth * 0.12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: readOnly ? Colors.grey.shade300 : const Color(0xffFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffE9E9E9)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: (value) {
                      if (onChanged != null) {
                        onChanged(value);
                      }
                      if (hasError && value.isNotEmpty) {
                        setState(() {
                          _fieldErrors.remove(errorKey!);
                        });
                      }
                    },
                    readOnly: readOnly,
                    keyboardType: type ?? TextInputType.text,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: KprimaryText,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.035,
                        horizontal: screenWidth * 0.035,
                      ),
                    ),
                  ),
                ),
                if (suffix != null)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.035,
                    ),
                    child: Text(
                      suffix,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _fieldErrors[errorKey]!,
              style: TextStyle(
                color: const Color(0xffDD0C0C),
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActivityDropdown({
    String? selectedValue,
    Function(String?)? onChanged,
  }) {
    final s = S.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final activityMap = _activityMap(s);
    final hasError = _fieldErrors.containsKey('activity_type');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.activityType,
          style: TextStyle(
            color: KprimaryText,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: screenWidth * 0.12,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.035,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xffFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffE9E9E9)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedActivityCode,
              hint: Text(
                s.enterActivityType,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Colors.grey.shade600,
                  fontFamily: 'Tajawal',
                ),
              ),
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey,
                size: screenWidth * 0.05,
              ),
              dropdownColor: const Color(0xffFAFAFA),
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: KprimaryText,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
              items: activityMap.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.value));
              }).toList(),
              onChanged: (value) {
                if (onChanged != null) onChanged(value);
                if (hasError && value != null) {
                  setState(() {
                    _fieldErrors.remove('activity_type');
                  });
                }
                setState(() {
                  _selectedActivityCode = value;
                });
              },
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _fieldErrors['activity_type']!,
              style: TextStyle(
                color: const Color(0xffDD0C0C),
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBranchLocationField(int index) {
    final s = S.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final String errorKey = 'branch_location_$index';
    final hasError = _fieldErrors.containsKey(errorKey);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${s.branch} ${index + 1}',
          style: TextStyle(
            color: KprimaryText,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenHeight * 0.008),
        SizedBox(
          height: screenWidth * 0.12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffE9E9E9)),
            ),
            child: TextField(
              controller: _branchLocationControllers[index],
              onChanged: (value) {
                if (hasError && value.isNotEmpty) {
                  setState(() {
                    _fieldErrors.remove(errorKey);
                  });
                }
              },
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: KprimaryText,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: s.enterBranchLocation,
                hintStyle: TextStyle(
                  fontSize: screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
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
              _fieldErrors[errorKey]!,
              style: const TextStyle(
                color: Color(0xffDD0C0C),
              ),
            ),
          ),
      ],
    );
  }

  void _validateAndSubmit() {
    final s = S.of(context);
    _fieldErrors.clear();

    if (_selectedActivityCode == null || _selectedActivityCode!.isEmpty) {
      _fieldErrors['activity_type'] = s.pleaseSelectCategory;
    }

    if (_branchesCountController.text.trim().isEmpty) {
      _fieldErrors['count_branches'] = s.fieldRequired;
    } else {
      final count = int.tryParse(_branchesCountController.text);
      if (count == null || count <= 0) {
        _fieldErrors['count_branches'] = s.fieldRequired;
      }
    }

    if (_areaController.text.trim().isEmpty) {
      _fieldErrors['area'] = s.fieldRequired;
    } else {
      final area = double.tryParse(_areaController.text);
      if (area == null || area <= 0) {
        _fieldErrors['area'] = s.fieldRequired;
      }
    }

    if (_periodController.text.trim().isEmpty) {
      _fieldErrors['period'] = s.fieldRequired;
    } else {
      final v = _periodController.text.trim();
      final n = int.tryParse(v);
      if (n == null || n <= 0) {
        _fieldErrors['period'] = s.fieldRequired;
      }
    }

    for (int i = 0; i < _branchLocationControllers.length; i++) {
      final location = _branchLocationControllers[i].text.trim();
      if (location.isEmpty) {
        _fieldErrors['branch_location_$i'] = s.fieldRequired;
      }
    }

    setState(() {
      if (_fieldErrors.isEmpty) {
        _submitData();
      }
    });
  }

  void _submitData() {
    final addresses = <String>[];
    for (final c in _branchLocationControllers) {
      final loc = c.text.trim();
      if (loc.isNotEmpty) addresses.add(loc);
    }

    final socialLinksForApi = _socialLinks
        .where(
          (link) =>
      link['url'] != null &&
          (link['url'] as String).isNotEmpty &&
          link['type'] != null &&
          (link['type'] as String).isNotEmpty,
    )
        .map((link) => {'url': link['url'], 'type': link['type']})
        .toList();

    final completeData = {
      ...widget.basicInfo,
      'activity_type': _selectedActivityCode ?? '',
      'count_branches': _branchesCountController.text.trim(),
      'area': _areaController.text.trim(),
      'period': _periodController.text.trim(),
      'branches': addresses,
      'social_links': socialLinksForApi,
      'commercial_register': _commercialRegisterFileName ?? '',
    };
    _submitWithContext(completeData);
  }

  void _showSuccessDialog() {
    final s = S.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: s.successTitle,
        desc: s.registrationSuccess,
        btnOkOnPress: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
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
        btnOkOnPress: () {
          _cubit?.resetFinalDialog();
        },
        btnOkText: s.tryAgain,
        btnOkColor: const Color(0xffDD0C0C),
      ).show();
    });
  }

  void _submitWithContext(Map<String, dynamic> completeData) {
    _cubitSubscription?.cancel();

    _cubit = SellerCompleteRegisterCubit(dio: Dio());

    _cubitSubscription = _cubit!.stream.listen((state) {
      setState(() {
        _isSubmitting = state.isLoading;
      });

      if (state.isSuccess) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSuccessDialog();
        });
      }

      if (state.shouldShowFinalDialog == true &&
          (state.errors.isNotEmpty || state.serverError != null)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String errorMessage = state.serverError ?? '';

          if (state.errors.isNotEmpty) {
            errorMessage = state.errors.values.join('\n');

            setState(() {
              _fieldErrors = Map.from(state.errors);
            });
          }

          if (errorMessage.isNotEmpty) {
            _showErrorDialog(errorMessage);
          }
        });
      }
    });

    _cubit!.registerSeller(
      completeData,
      context,
      commercialRegisterFilePath: _commercialRegisterFilePath,
      commercialRegisterBytes: _commercialRegisterBytes,
      commercialRegisterName: _commercialRegisterFileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const redButtonColor = Color(0xffDD0C0C);

    return Scaffold(
      backgroundColor: SecoundColor,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: CustomScrollView(
              controller: _scrollController,
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
                      Row(
                        children: [
                          Expanded(
                            child: _buildActivityDropdown(
                              selectedValue: _selectedActivityCode,
                              onChanged: (value) {
                                setState(() {
                                  _selectedActivityCode = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: _buildField(
                              s.branchesCount,
                              s.enterBranchesCount,
                              type: TextInputType.number,
                              controller: _branchesCountController,
                              errorKey: 'count_branches',
                              onChanged: (value) {
                                _updateBranches();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      if (_branchLocationControllers.isNotEmpty) ...[
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            _branchLocationControllers.length,
                                (index) => Column(
                              children: [
                                _buildBranchLocationField(index),
                                SizedBox(height: screenHeight * 0.02),
                              ],
                            ),
                          ),
                        ),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              s.totalArea,
                              s.enterTotalArea,
                              type: TextInputType.number,
                              controller: _areaController,
                              suffix: s.meters,
                              errorKey: 'area',
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: _buildField(
                              s.contractDuration,
                              s.contractDuration,
                              type: TextInputType.number,
                              controller: _periodController,
                              suffix: s.months,
                              errorKey: 'period',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        s.uploadDocs,
                        style: TextStyle(
                          color: KprimaryText,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      SizedBox(
                        width: double.infinity,
                        height: screenWidth * 0.12,
                        child: ElevatedButton(
                          onPressed: _pickCommercialRegisterFile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redButtonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                color: Colors.white,
                                size: screenWidth * 0.05,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                _commercialRegisterFileName == null
                                    ? s.addFile
                                    : _commercialRegisterFileName!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        s.socialLinks,
                        style: TextStyle(
                          color: KprimaryText,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Column(
                        children: _socialLinks
                            .map(
                              (link) => Container(
                            margin:
                            EdgeInsets.only(bottom: screenHeight * 0.01),
                            padding:
                            EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xffE9E9E9),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  link['icon'] as IconData,
                                  color: link['color'] as Color,
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Expanded(
                                  child: Text(
                                    link['url'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.03,
                                      color: KprimaryText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _socialLinks.remove(link);
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                    color: Color(0xffDD0C0C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .toList(),
                      ),
                      if (_socialLinks.length < 3)
                        SizedBox(
                          height: screenWidth * 0.12,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xffE9E9E9),
                              ),
                            ),
                            child: TextField(
                              controller: _socialLinkController,
                              onSubmitted: (value) {
                                final platform = _detectPlatform(value.trim());
                                if (platform != null && value.trim().isNotEmpty) {
                                  setState(() {
                                    _socialLinks.add({
                                      'url': value.trim(),
                                      'icon': platform['icon'],
                                      'color': platform['color'],
                                      'type': platform['type'],
                                    });
                                    _socialLinkController.clear();
                                  });
                                }
                              },
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: KprimaryText,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: s.enterSocialLink,
                                hintStyle: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.035,
                                  horizontal: screenWidth * 0.035,
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: screenHeight * 0.03),
                      SizedBox(
                        width: double.infinity,
                        height: screenWidth * 0.12,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _validateAndSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KprimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSubmitting
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: screenWidth * 0.04,
                                height: screenWidth * 0.04,
                                child: const CircularProgressIndicator(
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
                            s.submitForReview,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
                  final currentData = {
                    'activity_type': _selectedActivityCode ?? '',
                    'count_branches': _branchesCountController.text.trim(),
                    'area': _areaController.text.trim(),
                    'period': _periodController.text.trim(),
                    'branches': _branchLocationControllers
                        .map((c) => c.text.trim())
                        .where((v) => v.isNotEmpty)
                        .toList(),
                    'social_links': _socialLinks
                        .map((l) => {'url': l['url'], 'type': l['type']})
                        .toList(),
                    'commercial_register': _commercialRegisterFileName ?? '',
                  };
                  Navigator.pop(context, currentData);
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
  }
}
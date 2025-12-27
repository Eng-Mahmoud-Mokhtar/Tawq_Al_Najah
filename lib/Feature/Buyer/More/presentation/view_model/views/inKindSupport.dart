import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/Widgets/Button.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../Core/utiles/Images.dart';
import '../../../../../../generated/l10n.dart';

class InKindSupport extends StatefulWidget {
  const InKindSupport({super.key});
  @override
  State<InKindSupport> createState() => _InKindSupportState();
}

class _InKindSupportState extends State<InKindSupport> {
  String? selectedCharity;
  String? selectedSupportType;
  int? selectedCharityId;
  int? selectedSupportTypeId;
  final TextEditingController descriptionController = TextEditingController();
  List<Map<String, dynamic>> charities = [];
  List<Map<String, dynamic>> supportTypes = [];
  final Map<String, Map<String, dynamic>> charityMap = {};
  final Map<String, Map<String, dynamic>> supportTypeMap = {};
  bool isLoading = false;
  bool isSubmitting = false;
  bool isTokenExpired = false;
  String? token;
  int? userId;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late Dio _dio;

  @override
  void initState() {
    super.initState();
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://toknagah.viking-iceland.online/api',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (token?.isNotEmpty == true) {
          options.headers['Authorization'] ??= 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          if (mounted) {
            setState(() {
              isTokenExpired = true;
            });
          }
        }
        return handler.next(e);
      },
    ));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTokenAndData();
    });
  }

  Future<String?> _getToken() async {
    try {
      final secureToken = await _secureStorage.read(key: 'user_token');

      if (secureToken != null && secureToken.isNotEmpty) {
        if (secureToken.startsWith('Bearer ')) {
          return secureToken.substring(7);
        }
        return secureToken;
      }
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token') ??
          prefs.getString('auth_token') ??
          prefs.getString('access_token') ??
          prefs.getString('Token') ??
          prefs.getString('Authorization');

      return token;
    } catch (e) {
      return null;
    }
  }
  Future<int?> _getUserId() async {
    try {
      final userIdStr = await _secureStorage.read(key: 'user_id');
      if (userIdStr != null && userIdStr.isNotEmpty) {
        return int.tryParse(userIdStr);
      }
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('user_id') ??
          prefs.getInt('id') ??
          (prefs.getString('user_id') != null
              ? int.tryParse(prefs.getString('user_id')!)
              : null);

      return userId;
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadTokenAndData() async {
    if (!mounted) return;

    if (mounted) {
      setState(() {
        isLoading = true;
        isTokenExpired = false;
      });
    }
    try {
      token = await _getToken();
      userId = await _getUserId();
      if (token == null || token!.isEmpty) {
        if (mounted) {
          final mediaQuery = MediaQuery.of(context);
          await _showDialog(
            title: S.of(context).pleaseLoginFirst,
            message: S.of(context).mustLoginForSupport,
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.orange.shade700,
            iconBackgroundColor: Colors.orange.shade50,
            isLoginDialog: true,
            screenWidth: mediaQuery.size.width,
            screenHeight: mediaQuery.size.height,
          );
        }
        return;
      }
      await Future.wait([
        _loadCharities(),
        _loadSupportTypes(),
      ], eagerError: true);
    } catch (e) {
      if (mounted) {
        final mediaQuery = MediaQuery.of(context);
        await _showDialog(
          title: S.of(context).error,
          message: S.of(context).connectionError,
          icon: Icons.error_rounded,
          iconColor: Colors.red.shade700,
          iconBackgroundColor: Colors.red.shade50,
          screenWidth: mediaQuery.size.width,
          screenHeight: mediaQuery.size.height,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCharities() async {
    try {
      final response = await _dio.get('/user/get-charity');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['status'] == 200) {
          if (data['data'] != null && data['data'] is List) {
            final List<dynamic> charitiesData = data['data'];
            final List<Map<String, dynamic>> loadedCharities = [];
            charityMap.clear();
            final seenIds = <int>{};
            for (var item in charitiesData) {
              if (item is Map) {
                final id = int.tryParse(item['id']?.toString() ?? '');
                final name = item['name']?.toString() ??
                    item['charity_name']?.toString() ??
                    S.of(context).unknown;
                if (id != null && !seenIds.contains(id)) {
                  seenIds.add(id);
                  final uniqueValue = '$id-$name';
                  final charityData = {
                    'id': id,
                    'name': name,
                    'charity_name': name,
                    'unique_value': uniqueValue,
                  };
                  loadedCharities.add(charityData);
                  charityMap[uniqueValue] = charityData;
                }
              }
            }
            if (mounted) {
              setState(() {
                charities = loadedCharities;
                selectedCharity = null;
                selectedCharityId = null;
              });
            }
          }
        }
      }
    } catch (e) {
    }
  }

  Future<void> _loadSupportTypes() async {
    try {
      final response = await _dio.get('/user/get-kind-support');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['status'] == 200) {
          if (data['data'] != null && data['data'] is List) {
            final List<dynamic> supportTypesData = data['data'];
            final List<Map<String, dynamic>> loadedSupportTypes = [];
            supportTypeMap.clear();
            final seenIds = <int>{};
            for (var item in supportTypesData) {
              if (item is Map) {
                final id = int.tryParse(item['id']?.toString() ?? '');
                final name = item['name']?.toString() ??
                    item['kind_name']?.toString() ??
                    S.of(context).unknown;

                if (id != null && !seenIds.contains(id)) {
                  seenIds.add(id);

                  final uniqueValue = '$id-$name';
                  final supportTypeData = {
                    'id': id,
                    'name': name,
                    'kind_name': name,
                    'unique_value': uniqueValue,
                  };

                  loadedSupportTypes.add(supportTypeData);
                  supportTypeMap[uniqueValue] = supportTypeData;
                }
              }
            }

            if (mounted) {
              setState(() {
                supportTypes = loadedSupportTypes;
                selectedSupportType = null;
                selectedSupportTypeId = null;
              });
            }
          }
        }
      }
    } catch (e) {
    }
  }

  Future<void> _showDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color iconBackgroundColor,
    bool isLoginDialog = false,
    bool isSuccessDialog = false,
    double? screenWidth,
    double? screenHeight,
  }) async {
    final mediaQuery = MediaQuery.of(context);
    final width = screenWidth ?? mediaQuery.size.width;
    final height = screenHeight ?? mediaQuery.size.height;

    await showDialog(
      context: context,
      barrierDismissible: !isSuccessDialog,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.05),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(width * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(width * 0.05),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: width * 0.2,
                  height: width * 0.2,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: width * 0.1,
                    color: iconColor,
                  ),
                ),
                SizedBox(height: height * 0.025),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: height * 0.01),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.03,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: height * 0.02),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext, rootNavigator: true).pop();

                      if (isSuccessDialog) {
                        if (mounted) {
                          setState(() {
                            selectedCharity = null;
                            selectedSupportType = null;
                            selectedCharityId = null;
                            selectedSupportTypeId = null;
                            descriptionController.clear();
                          });
                        }

                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            Navigator.of(context, rootNavigator: true).pop();
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuccessDialog || isLoginDialog
                          ? KprimaryColor
                          : iconColor,
                      padding: EdgeInsets.symmetric(
                        vertical: height * 0.025,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(width * 0.02),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      S.of(context).ok,
                      style: TextStyle(
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                if (isLoginDialog) SizedBox(height: height * 0.02),
                if (isLoginDialog)
                  TextButton(
                    onPressed: _loadTokenAndData,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: width * 0.05,
                          color: KprimaryColor,
                        ),
                        SizedBox(width: width * 0.02),
                        Text(
                          S.of(context).tryAgain,
                          style: TextStyle(
                            fontSize: width * 0.035,
                            color: KprimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _validateForm() {
    if (token == null || token!.isEmpty) {
      return false;
    }
    if (selectedCharity == null || selectedCharityId == null) {
      return false;
    }
    if (selectedSupportType == null || selectedSupportTypeId == null) {
      return false;
    }
    return true;
  }

  String _getErrorMessage() {
    if (token == null || token!.isEmpty) {
      return S.of(context).mustLoginForSupport;
    }

    if (selectedCharity == null || selectedCharityId == null) {
      return '${S.of(context).charityName} ${S.of(context).fieldRequired.toLowerCase()}';
    }

    if (selectedSupportType == null || selectedSupportTypeId == null) {
      return '${S.of(context).inKindSupportType} ${S.of(context).fieldRequired.toLowerCase()}';
    }

    return S.of(context).incompleteData;
  }

  Future<void> _submitRequest() async {
    if (!_validateForm()) {
      final mediaQuery = MediaQuery.of(context);
      await _showDialog(
        title: S.of(context).incompleteData,
        message: _getErrorMessage(),
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.orange.shade700,
        iconBackgroundColor: Colors.orange.shade50,
        screenWidth: mediaQuery.size.width,
        screenHeight: mediaQuery.size.height,
      );
      return;
    }

    if (mounted) {
      setState(() {
        isSubmitting = true;
      });
    }

    try {
      // بناء البيانات حسب الـ API specification
      final Map<String, dynamic> requestData = {
        'charity_id': selectedCharityId!,
        'support_type': 'kind_support', // نوع الدعم العيني
        'description': descriptionController.text.isNotEmpty
            ? descriptionController.text
            : S.of(context).inKindSupport,
      };

      // إضافة kind_support_id فقط إذا كان موجودًا
      if (selectedSupportTypeId != null) {
        requestData['kind_support_id'] = selectedSupportTypeId!;
      }

      if (kDebugMode) {
        print('Request Data: $requestData');
      }

      final response = await _dio.post(
        '/user/send-support',
        data: requestData,
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map && responseData['status'] == 200) {
          final mediaQuery = MediaQuery.of(context);
          await _showDialog(
            title: S.of(context).successTitle,
            message: S.of(context).requestSentNotification,
            icon: Icons.check_circle_rounded,
            iconColor: Colors.green.shade700,
            iconBackgroundColor: Colors.green.shade50,
            isSuccessDialog: true,
            screenWidth: mediaQuery.size.width,
            screenHeight: mediaQuery.size.height,
          );
        } else {
          final mediaQuery = MediaQuery.of(context);
          await _showDialog(
            title: S.of(context).error,
            message: (responseData is Map ? responseData['message'] : null) ??
                S.of(context).requestFailed,
            icon: Icons.error_rounded,
            iconColor: Colors.red.shade700,
            iconBackgroundColor: Colors.red.shade50,
            screenWidth: mediaQuery.size.width,
            screenHeight: mediaQuery.size.height,
          );
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          setState(() {
            isTokenExpired = true;
          });
        }
        final mediaQuery = MediaQuery.of(context);
        await _showDialog(
          title: S.of(context).sessionExpired,
          message: S.of(context).pleaseLoginFirst,
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange.shade700,
          iconBackgroundColor: Colors.orange.shade50,
          isLoginDialog: true,
          screenWidth: mediaQuery.size.width,
          screenHeight: mediaQuery.size.height,
        );
      } else if (response.statusCode == 422) {
        final responseData = response.data;
        String errorMessage = S.of(context).invalidData;
        if (responseData is Map && responseData['errors'] != null) {
          final errors = responseData['errors'] as Map<String, dynamic>;
          errorMessage = errors.values.first?.first?.toString() ?? errorMessage;
        }
        final mediaQuery = MediaQuery.of(context);
        await _showDialog(
          title: S.of(context).error,
          message: errorMessage,
          icon: Icons.error_rounded,
          iconColor: Colors.red.shade700,
          iconBackgroundColor: Colors.red.shade50,
          screenWidth: mediaQuery.size.width,
          screenHeight: mediaQuery.size.height,
        );
      } else {
        final mediaQuery = MediaQuery.of(context);
        await _showDialog(
          title: S.of(context).error,
          message: '${S.of(context).requestFailed} (${response.statusCode})',
          icon: Icons.error_rounded,
          iconColor: Colors.red.shade700,
          iconBackgroundColor: Colors.red.shade50,
          screenWidth: mediaQuery.size.width,
          screenHeight: mediaQuery.size.height,
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Dio Error: $e');
      }

      String errorMessage = S.of(context).connectionError;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = S.of(context).connectionTimeout;
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = S.of(context).cannotConnectToServer;
      }

      final mediaQuery = MediaQuery.of(context);
      await _showDialog(
        title: S.of(context).error,
        message: errorMessage,
        icon: Icons.error_rounded,
        iconColor: Colors.red.shade700,
        iconBackgroundColor: Colors.red.shade50,
        screenWidth: mediaQuery.size.width,
        screenHeight: mediaQuery.size.height,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      final mediaQuery = MediaQuery.of(context);
      await _showDialog(
        title: S.of(context).error,
        message: S.of(context).somethingWentWrong,
        icon: Icons.error_rounded,
        iconColor: Colors.red.shade700,
        iconBackgroundColor: Colors.red.shade50,
        screenWidth: mediaQuery.size.width,
        screenHeight: mediaQuery.size.height,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }
  Widget _buildShimmerLoader(double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        children: [
          Center(
            child: Container(
              width: screenWidth * 0.5,
              height: screenHeight * 0.15,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          _ShimmerLabel(screenWidth: screenWidth, width: 0.3),
          SizedBox(height: screenHeight * 0.01),
          Container(
            width: double.infinity,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          _ShimmerLabel(screenWidth: screenWidth, width: 0.4),
          SizedBox(height: screenHeight * 0.01),
          Container(
            width: double.infinity,
            height: screenWidth * 0.12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          _ShimmerLabel(screenWidth: screenWidth, width: 0.2),
          SizedBox(height: screenHeight * 0.01),
          Container(
            width: double.infinity,
            height: screenWidth * 0.24,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          Container(
            width: double.infinity,
            height: screenWidth * 0.14,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).inKindSupport),
      body: Directionality(
        textDirection: textDirection,
        child: isLoading
            ? _buildShimmerLoader(screenWidth, screenHeight)
            : Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: _LogoImage(screenWidth: screenWidth, screenHeight: screenHeight),
                ),
                SizedBox(height: screenHeight * 0.02),
                _CharityDropdown(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  charities: charities,
                  selectedCharity: selectedCharity,
                  onChanged: (value) {
                    if (value == null) {
                      setState(() {
                        selectedCharity = null;
                        selectedCharityId = null;
                      });
                      return;
                    }

                    final selected = charityMap[value];
                    if (selected != null) {
                      setState(() {
                        selectedCharity = value;
                        selectedCharityId = selected['id'];
                      });
                    }
                  },
                  noCharitiesText: S.of(context).noCharitiesAvailable,
                  enterCharityText: S.of(context).enterCharityName,
                ),
                SizedBox(height: screenHeight * 0.02),
                _SupportTypeDropdown(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  supportTypes: supportTypes,
                  selectedSupportType: selectedSupportType,
                  onChanged: (value) {
                    if (value == null) {
                      setState(() {
                        selectedSupportType = null;
                        selectedSupportTypeId = null;
                      });
                      return;
                    }

                    final selected = supportTypeMap[value];
                    if (selected != null) {
                      setState(() {
                        selectedSupportType = value;
                        selectedSupportTypeId = selected['id'];
                      });
                    }
                  },
                  noSupportTypesText: S.of(context).noSupportTypesAvailable,
                  exampleText: S.of(context).inKindSupportExample,
                ),

                SizedBox(height: screenHeight * 0.02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).descriptionLabel,
                      style: TextStyle(
                        color: KprimaryText,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    SizedBox(
                      height: screenWidth * 0.24,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xffFAFAFA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xffE9E9E9),
                            width: 1.5,
                          ),
                        ),
                        child: TextFormField(
                          controller: descriptionController,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: KprimaryText,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                            hintText: S.of(context).inKindDescriptionExample,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.04,
                              horizontal: screenWidth * 0.04,
                            ),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: 4,
                          minLines: 3,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.035),
                isSubmitting
                    ? _LoadingButton(screenWidth: screenWidth)
                    : Button(
                  text: S.of(context).submitRequest,
                  onPressed: (charities.isEmpty || supportTypes.isEmpty)
                      ? null
                      : _submitRequest,
                ),

                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    descriptionController.dispose();
    _dio.close();
    super.dispose();
  }
}

class _LogoImage extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const _LogoImage({
    required this.screenWidth,
    required this.screenHeight,
  });
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      KprimaryImage,
      width: screenWidth * 0.5,
      height: screenHeight * 0.15,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: screenWidth * 0.5,
          height: screenHeight * 0.15,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
          ),
          child: const Icon(
            Icons.volunteer_activism,
            size: 40,
            color: KprimaryColor,
          ),
        );
      },
    );
  }
}

class _CharityDropdown extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final List<Map<String, dynamic>> charities;
  final String? selectedCharity;
  final Function(String?)? onChanged;
  final String noCharitiesText;
  final String enterCharityText;

  const _CharityDropdown({
    required this.screenWidth,
    required this.screenHeight,
    required this.charities,
    required this.selectedCharity,
    required this.onChanged,
    required this.noCharitiesText,
    required this.enterCharityText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).charityName,
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
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCharity,
                  isExpanded: true,
                  isDense: true,
                  hint: Text(
                    charities.isEmpty ? noCharitiesText : enterCharityText,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade600,
                    size: screenWidth * 0.05,
                  ),
                  dropdownColor: Colors.white,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: KprimaryText,
                    fontFamily: 'Tajawal',
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  items: charities.map((charity) {
                    return DropdownMenuItem<String>(
                      value: charity['unique_value'],
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                        child: Text(
                          charity['name'] ?? charity['charity_name'] ?? S.of(context).unknown,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SupportTypeDropdown extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final List<Map<String, dynamic>> supportTypes;
  final String? selectedSupportType;
  final Function(String?)? onChanged;
  final String noSupportTypesText;
  final String exampleText;

  const _SupportTypeDropdown({
    required this.screenWidth,
    required this.screenHeight,
    required this.supportTypes,
    required this.selectedSupportType,
    required this.onChanged,
    required this.noSupportTypesText,
    required this.exampleText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).inKindSupportType,
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
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSupportType,
                  isExpanded: true,
                  isDense: true,
                  hint: Text(
                    supportTypes.isEmpty ? noSupportTypesText : exampleText,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade600,
                    size: screenWidth * 0.05,
                  ),
                  dropdownColor: Colors.white,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: KprimaryText,
                    fontFamily: 'Tajawal',
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  items: supportTypes.map((supportType) {
                    return DropdownMenuItem<String>(
                      value: supportType['unique_value'],
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                        child: Text(
                          supportType['name'] ?? supportType['kind_name'] ?? S.of(context).unknown,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingButton extends StatelessWidget {
  final double screenWidth;

  const _LoadingButton({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenWidth * 0.12,
      width: double.infinity,
      decoration: BoxDecoration(
        color: KprimaryColor.withAlpha(200),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: KprimaryColor.withAlpha((0.2 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: screenWidth * 0.05,
          height: screenWidth * 0.05,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: screenWidth * 0.005,
          ),
        ),
      ),
    );
  }
}

class _ShimmerLabel extends StatelessWidget {
  final double screenWidth;
  final double width;

  const _ShimmerLabel({
    required this.screenWidth,
    this.width = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * width,
      height: screenWidth * 0.035,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
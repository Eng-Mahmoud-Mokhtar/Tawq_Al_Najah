import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/Widgets/Button.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../Core/utiles/Images.dart';
import '../../../../../../generated/l10n.dart';

class Packages extends StatefulWidget {
  const Packages({super.key});

  @override
  State<Packages> createState() => _PackagesState();
}

class _PackagesState extends State<Packages> {
  String? selectedCharity;
  String? selectedPackage;
  int? selectedCharityId;
  double? selectedPackageValue;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController customPackageController = TextEditingController();
  List<Map<String, dynamic>> charities = [];

  List<Map<String, dynamic>> packages = [];
  final Map<String, Map<String, dynamic>> charityMap = {};
  final Map<String, Map<String, dynamic>> packageMap = {};
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

    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (object) {},
    ));

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

  void _initializePackages(BuildContext context) {
    final localPackages = [
      {'id': 1, 'value': 50.0, 'name': '50'},
      {'id': 2, 'value': 100.0, 'name': '100'},
      {'id': 3, 'value': 200.0, 'name': '200'},
      {'id': 4, 'value': 500.0, 'name': '500'},
      {'id': 5, 'value': 0.0, 'name': S.of(context).other},
    ];

    packageMap.clear();
    for (var package in localPackages) {
      final uniqueValue = package['name'] as String;
      final packageData = {
        'id': package['id'],
        'value': package['value'],
        'name': package['name'],
        'unique_value': uniqueValue,
      };
      packageMap[uniqueValue] = packageData;
    }

    if (mounted) {
      setState(() {
        packages = List.from(localPackages.map((p) {
          return {
            'id': p['id'],
            'value': p['value'],
            'name': p['name'],
            'unique_value': p['name'] as String,
          };
        }).toList());
      });
    }
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
      await _loadCharities();
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
                  final uniqueValue = id.toString();
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
                            selectedPackage = null;
                            selectedCharityId = null;
                            selectedPackageValue = null;
                            descriptionController.clear();
                            customPackageController.clear();
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
    if (selectedPackage == null) {
      return false;
    }
    if (selectedPackage!.contains(S.of(context).other)) {
      if (customPackageController.text.isEmpty) {
        return false;
      }
      final customValue = double.tryParse(customPackageController.text);
      if (customValue == null || customValue <= 0) {
        return false;
      }
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
    if (selectedPackage == null) {
      return '${S.of(context).packageValue} ${S.of(context).fieldRequired.toLowerCase()}';
    }
    if (selectedPackage!.contains(S.of(context).other)) {
      if (customPackageController.text.isEmpty) {
        return '${S.of(context).enterOtherValue} ${S.of(context).fieldRequired.toLowerCase()}';
      }
      final customValue = double.tryParse(customPackageController.text);
      if (customValue == null || customValue <= 0) {
        return S.of(context).enterValidAmount;
      }
    }
    return S.of(context).incompleteData;
  }

  Future<void> _submitDonation() async {
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
      double packageValue = 0.0;
      if (selectedPackage!.contains(S.of(context).other)) {
        packageValue = double.parse(customPackageController.text);
      } else {
        final selected = packageMap[selectedPackage];
        packageValue = selected?['value'] ?? 0.0;
      }

      final Map<String, dynamic> requestData = {
        'charity_id': selectedCharityId!,
        'support_type': 'financial_support',
        'description': descriptionController.text.isNotEmpty
            ? descriptionController.text
            : S.of(context).financialSupport,
        'plan_value': packageValue,
      };

      final response = await _dio.post(
        '/user/send-support',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map && responseData['status'] == 200) {
          final mediaQuery = MediaQuery.of(context);
          await _showDialog(
            title: S.of(context).successTitle,
            message: S.of(context).donationSentSuccessfully,
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
                S.of(context).donationFailed,
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
        final mediaQuery = MediaQuery.of(context);
        await _showDialog(
          title: S.of(context).successTitle,
          message: S.of(context).donationSentSuccessfully,
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
          message: '${S.of(context).donationFailed} (${response.statusCode})',
          icon: Icons.error_rounded,
          iconColor: Colors.red.shade700,
          iconBackgroundColor: Colors.red.shade50,
          screenWidth: mediaQuery.size.width,
          screenHeight: mediaQuery.size.height,
        );
      }
    } on DioException catch (e) {
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
          _ShimmerLabel(screenWidth: screenWidth, width: 0.2),
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

    if (packages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializePackages(context);
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).packages),
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
                _PackageDropdown(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  packages: packages,
                  selectedPackage: selectedPackage,
                  customPackageController: customPackageController,
                  onChanged: (value) {
                    if (value == null) {
                      setState(() {
                        selectedPackage = null;
                        selectedPackageValue = null;
                        customPackageController.clear();
                      });
                      return;
                    }
                    setState(() {
                      selectedPackage = value;
                      if (!value.contains(S.of(context).other)) {
                        final selected = packageMap[value];
                        selectedPackageValue = selected?['value'] ?? 0.0;
                      } else {
                        selectedPackageValue = null;
                      }
                    });
                  },
                  noPackagesText: S.of(context).noPackagesAvailable,
                  exampleText: S.of(context).selectPackageValue,
                ),
                SizedBox(height: screenHeight * 0.02),
                if (selectedPackage != null && selectedPackage!.contains(S.of(context).other))
                  _CustomPackageInput(
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    controller: customPackageController,
                  ),
                SizedBox(height: screenHeight * 0.035),
                isSubmitting
                    ? _LoadingButton(screenWidth: screenWidth)
                    : Button(
                  text: S.of(context).submitDonation,
                  onPressed: (charities.isEmpty || packages.isEmpty)
                      ? null
                      : _submitDonation,
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
    customPackageController.dispose();
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
            Icons.attach_money_rounded,
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
    String? validSelectedCharity = selectedCharity;
    if (selectedCharity != null && charities.isNotEmpty) {
      final exists = charities.any((charity) => charity['unique_value'] == selectedCharity);
      if (!exists) {
        validSelectedCharity = null;
      }
    }

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
                  value: validSelectedCharity,
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
                    final uniqueValue = charity['unique_value'] as String;
                    final name = charity['name'] ?? charity['charity_name'] ?? S.of(context).unknown;
                    return DropdownMenuItem<String>(
                      value: uniqueValue,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                        child: Text(
                          name,
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

class _PackageDropdown extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final List<Map<String, dynamic>> packages;
  final String? selectedPackage;
  final TextEditingController customPackageController;
  final Function(String?)? onChanged;
  final String noPackagesText;
  final String exampleText;

  const _PackageDropdown({
    required this.screenWidth,
    required this.screenHeight,
    required this.packages,
    required this.selectedPackage,
    required this.customPackageController,
    required this.onChanged,
    required this.noPackagesText,
    required this.exampleText,
  });

  @override
  Widget build(BuildContext context) {
    String? validSelectedPackage = selectedPackage;
    if (selectedPackage != null && packages.isNotEmpty) {
      final exists = packages.any((package) => package['unique_value'] == selectedPackage);
      if (!exists) {
        validSelectedPackage = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).packageValue,
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
                  value: validSelectedPackage,
                  isExpanded: true,
                  isDense: true,
                  hint: Text(
                    packages.isEmpty ? noPackagesText : exampleText,
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
                  items: packages.map((package) {
                    final uniqueValue = package['unique_value'] as String;
                    final name = package['name'] as String;
                    final displayName = name == S.of(context).other
                        ? S.of(context).other
                        : '$name ${S.of(context).currency}';

                    return DropdownMenuItem<String>(
                      value: uniqueValue,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                        child: Text(
                          displayName,
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
class _CustomPackageInput extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final TextEditingController controller;

  const _CustomPackageInput({
    required this.screenWidth,
    required this.screenHeight,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).enterOtherValue,
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
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
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
                hintText: S.of(context).enterAmount,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
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


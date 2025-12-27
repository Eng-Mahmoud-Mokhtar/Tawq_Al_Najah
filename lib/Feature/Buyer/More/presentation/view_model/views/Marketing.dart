import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../Core/utiles/Images.dart';
import '../../../../../../generated/l10n.dart';

// ========== BLoC Layer - Enums ==========
// Marketing/Data/Enums/marketing_status_enum.dart
enum MarketingStatus { notRequested, pending, rejected, active, approved, accepted }

// ========== BLoC Layer - Models ==========
// Marketing/Data/Models/marketing_data_model.dart
class MarketingData {
  final MarketingStatus status;
  final String code;
  final int usersUsed;
  final double earnings;

  MarketingData({
    required this.status,
    required this.code,
    required this.usersUsed,
    required this.earnings,
  });

  factory MarketingData.fromJson(Map<String, dynamic> json, {bool fromList = false}) {
    final data = fromList ? (json['data']?[0] ?? json) : json;

    MarketingStatus parseStatus(String? statusStr) {
      if (statusStr == null) return MarketingStatus.notRequested;
      final status = statusStr.toLowerCase();

      switch (status) {
        case 'pending':
          return MarketingStatus.pending;
        case 'rejected':
          return MarketingStatus.rejected;
        case 'active':
        case 'approved':
        case 'accepted':
          return MarketingStatus.active;
        default:
          return MarketingStatus.notRequested;
      }
    }

    return MarketingData(
      status: parseStatus(data['status']?.toString()),
      code: data['code']?.toString() ?? '',
      usersUsed: data['count'] ?? 0,
      earnings: double.tryParse(data['amount']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

// ========== Presentation Layer - Widgets ==========
// Marketing/Presentation/Widgets/Shimmer/loading_shimmer_widget.dart
class ShimmerLoadingWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const ShimmerLoadingWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenWidth * 0.05),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: screenWidth * 0.5,
                height: screenWidth * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: screenHeight * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: screenHeight * 0.06,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Marketing/Presentation/Widgets/Status/status_card_widget.dart
class StatusCardWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final double screenWidth;

  const StatusCardWidget({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.02),
          Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Marketing/Presentation/Widgets/ReferralCode/referral_code_box_widget.dart
class ReferralCodeBoxWidget extends StatelessWidget {
  final String referralCode;
  final double screenWidth;

  const ReferralCodeBoxWidget({
    super.key,
    required this.referralCode,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).yourReferralCode,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  referralCode.isNotEmpty
                      ? referralCode
                      : S.of(context).codeNotAssigned,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: KprimaryText,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  color: const Color(0xffFF580E),
                  size: screenWidth * 0.05,
                ),
                onPressed: referralCode.isNotEmpty
                    ? () {
                  Clipboard.setData(
                    ClipboardData(text: referralCode),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.orange.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      duration: const Duration(seconds: 2),
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              S.of(context).referralCodeCopied,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                    : null,
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            S.of(context).shareReferralCodeHint,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Marketing/Presentation/Widgets/FormFields/bank_text_field_widget.dart
class BankTextFieldWidget extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final double screenWidth;
  final double screenHeight;
  final TextInputType type;
  final bool isValid;
  final String errorMessage;

  const BankTextFieldWidget({
    super.key,
    required this.hint,
    required this.controller,
    required this.screenWidth,
    required this.screenHeight,
    required this.type,
    required this.isValid,
    required this.errorMessage,
  });

  @override
  State<BankTextFieldWidget> createState() => _BankTextFieldWidgetState();
}

class _BankTextFieldWidgetState extends State<BankTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = widget.screenWidth;
    final screenHeight = widget.screenHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.hint,
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
                color: widget.isValid ? const Color(0xffE9E9E9) : Colors.red,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              keyboardType: widget.type,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: KprimaryText,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
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
              onChanged: (_) {
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          ),
        ),
        if (!widget.isValid) ...[
          SizedBox(height: screenHeight * 0.005),
          Text(
            widget.errorMessage,
            style: TextStyle(
              fontSize: screenWidth * 0.025,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}

// ========== Data Layer - Repository & Data Sources ==========
// Marketing/Data/Repository/marketing_repository.dart (سيتم استخراج لاحقاً)
// Marketing/Data/DataSource/marketing_remote_data_source.dart (سيتم استخراج لاحقاً)

// ========== Domain Layer - Use Cases ==========
// Marketing/Domain/UseCases/get_marketing_data_use_case.dart (سيتم استخراج لاحقاً)
// Marketing/Domain/UseCases/send_marketing_request_use_case.dart (سيتم استخراج لاحقاً)

// ========== Presentation Layer - ViewModel/Bloc ==========
// Marketing/Presentation/Bloc/marketing_bloc.dart (سيتم استخراج لاحقاً)
// Marketing/Presentation/States/marketing_state.dart (سيتم استخراج لاحقاً)
// Marketing/Presentation/Events/marketing_event.dart (سيتم استخراج لاحقاً)

// ========== Presentation Layer - Main Screen (Legacy - سيتم تحويله لـ View مع Bloc) ==========
// Marketing/Presentation/Views/marketing_screen.dart
class Marketing extends StatefulWidget {
  const Marketing({super.key});

  @override
  State<Marketing> createState() => _MarketingState();
}

class _MarketingState extends State<Marketing> {
  // ========== متغيرات الـ State ==========
  bool _isLoading = false;
  bool _isButtonLoading = false;
  bool _hasBankData = false;

  // استخدام Model بدل المتغيرات المنفصلة
  MarketingData _marketingData = MarketingData(
    status: MarketingStatus.notRequested,
    code: '',
    usersUsed: 0,
    earnings: 0.0,
  );

  String _bankName = "";
  String _accountNumber = "";
  String _accountHolder = "";

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();

  // ========== Data Layer - API Service ==========
  // Marketing/Data/DataSource/marketing_remote_data_source.dart
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ========== Memoization للقيم الثابتة ==========
  late final ThemeData _theme = Theme.of(context);
  late final TextTheme _textTheme = _theme.textTheme;
  late final S _translations = S.of(context);

  @override
  void initState() {
    super.initState();
    _loadMarketingData();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  // ========== Domain Layer - Business Logic ==========
  // Marketing/Domain/UseCases/get_marketing_data_use_case.dart
  Future<void> _loadMarketingData() async {
    if (!mounted) return;
    _setLoading(true);

    try {
      final response = await _apiServiceGet('user/get-markting-data');

      if (response is Map && response['status'] == 200) {
        final data = response['data'] ?? {};

        final marketingData = _parseMarketingData(data);

        if (!mounted) return;
        _updateMarketingData(marketingData);
      } else {
        if (!mounted) return;
        _resetMarketingData();
      }
    } catch (error, st) {
      if (!mounted) return;
      _resetMarketingData();
    } finally {
      if (!mounted) return;
      _setLoading(false);
    }
  }

  // ========== Data Layer - Parsing Logic ==========
  // Marketing/Data/Models/marketing_data_model.dart (جزء من Model)
  MarketingData _parseMarketingData(Map<String, dynamic> data) {
    if (data.containsKey('data') && data['data'] is List) {
      if ((data['data'] as List).isNotEmpty) {
        return MarketingData.fromJson(data, fromList: true);
      } else {
        return MarketingData(
          status: MarketingStatus.notRequested,
          code: '',
          usersUsed: 0,
          earnings: 0.0,
        );
      }
    } else if (data.containsKey('code')) {
      return MarketingData.fromJson(data);
    } else {
      return MarketingData(
        status: MarketingStatus.notRequested,
        code: '',
        usersUsed: 0,
        earnings: 0.0,
      );
    }
  }

  // ========== Data Layer - API Calls ==========
  // Marketing/Data/DataSource/marketing_remote_data_source.dart
  Future<dynamic> _apiServiceGet(String path) async {
    try {
      return await _apiServiceCallGet(path);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> _apiServiceCallGet(String path) async {
    try {
      final url = path.startsWith('http')
          ? path
          : 'https://toknagah.viking-iceland.online/api/$path';

      final token = await _secureStorage.read(key: 'user_token');

      final headers = <String, dynamic>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      headers['Referer'] = 'https://toknagah.viking-iceland.online/';

      final response = await _dio.get(
        url,
        options: Options(
          headers: headers,
          validateStatus: (_) => true,
        ),
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // ========== Presentation Layer - State Management ==========
  // Marketing/Presentation/Bloc/marketing_bloc.dart (State management methods)
  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  void _setButtonLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isButtonLoading = loading;
      });
    }
  }

  void _updateMarketingData(MarketingData data) {
    if (mounted) {
      setState(() {
        _marketingData = data;
      });
    }
  }

  void _resetMarketingData() {
    if (mounted) {
      setState(() {
        _marketingData = MarketingData(
          status: MarketingStatus.notRequested,
          code: '',
          usersUsed: 0,
          earnings: 0.0,
        );
      });
    }
  }

  // ========== Domain Layer - Use Cases ==========
  // Marketing/Domain/UseCases/send_marketing_request_use_case.dart
  Future<void> _sendMarketingRequest() async {
    if (!mounted) return;
    _setButtonLoading(true);

    try {
      final response = await _apiServiceGet('user/send-markting-request');

      if (response is Map && response['status'] == 200) {
        await _loadMarketingData();
      } else {
        final message = (response is Map)
            ? (response['message']?.toString() ?? _translations.somethingWentWrong)
            : _translations.somethingWentWrong;
        _showErrorDialog(message);
      }
    } catch (error, st) {
      _showErrorDialog(_translations.connectionError);
    } finally {
      if (!mounted) return;
      _setButtonLoading(false);
    }
  }

  // ========== Presentation Layer - Dialogs ==========
  // Marketing/Presentation/Widgets/Dialogs/error_dialog.dart (سيتم استخراج لاحقاً)
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xfffafafa),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(_translations.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_translations.close),
          ),
        ],
      ),
    );
  }

  // ========== Presentation Layer - UI Builders ==========
  // Marketing/Presentation/Views/Partials/not_requested_ui.dart
  Widget _buildNotRequestedUI(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Text(
          _translations.joinAffiliateProgram,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: KprimaryText,
            height: 1.5,
          ),
        ),
        SizedBox(height: screenWidth * 0.05),
        SizedBox(
          width: double.infinity,
          height: screenHeight * 0.06,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: KprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _isButtonLoading ? null : _sendMarketingRequest,
            child: _isButtonLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Text(
              _translations.requestMarketingButton,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Marketing/Presentation/Views/Partials/pending_ui.dart
  Widget _buildPendingUI(double screenWidth, double screenHeight) {
    return Column(
      children: [
        SizedBox(height: screenWidth * 0.1),
        StatusCardWidget(
          text: _translations.requestUnderReview,
          icon: Icons.hourglass_empty,
          color: Colors.orange,
          screenWidth: screenWidth,
        ),
        SizedBox(height: screenWidth * 0.05),
        Text(
          _translations.requestPendingContent,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Marketing/Presentation/Views/Partials/rejected_ui.dart
  Widget _buildRejectedUI(double screenWidth, double screenHeight) {
    return Column(
      children: [
        SizedBox(height: screenWidth * 0.1),
        StatusCardWidget(
          text: _translations.requestRejected,
          icon: Icons.cancel_outlined,
          color: Colors.red,
          screenWidth: screenWidth,
        ),
        SizedBox(height: screenWidth * 0.05),
        Text(
          _translations.requestRejectedContent,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // Marketing/Presentation/Views/Partials/active_ui.dart
  Widget _buildActiveUI(double screenWidth, double screenHeight) {
    return Column(
      children: [
        ReferralCodeBoxWidget(
          referralCode: _marketingData.code,
          screenWidth: screenWidth,
        ),
        SizedBox(height: screenWidth * 0.06),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildRow(
                _translations.usersUsedLabel,
                _marketingData.usersUsed.toString(),
                screenWidth,
              ),
              SizedBox(height: screenWidth * 0.04),
              _buildRow(
                _translations.currentBalanceLabel,
                '${_marketingData.earnings.toStringAsFixed(2)} ${_translations.SYP}',
                screenWidth,
                valueColor: KprimaryColor,
              ),
              SizedBox(height: screenWidth * 0.04),
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.05,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _marketingData.earnings > 0
                        ? KprimaryColor
                        : KprimaryColor.withAlpha(77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _marketingData.earnings > 0
                      ? () {
                    if (_hasBankData) {
                      // إجراء السحب
                    } else {
                      _showBankDataDialog();
                    }
                  }
                      : null,
                  child: Text(
                    _translations.withdrawEarnings,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Marketing/Presentation/Widgets/Common/info_row_widget.dart
  Widget _buildRow(String label, String value, double screenWidth, {Color valueColor = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ========== Presentation Layer - Bank Dialog ==========
  // Marketing/Presentation/Widgets/Dialogs/bank_data_dialog.dart
  void _showBankDataDialog() {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    bool isBankNameValid = _bankNameController.text.isNotEmpty;
    bool isAccountNumberValid = _accountNumberController.text.isNotEmpty;
    bool isAccountHolderValid = _accountHolderController.text.isNotEmpty;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (context, setState) {
            void validateFields() {
              setState(() {
                isBankNameValid = _bankNameController.text.isNotEmpty;
                isAccountNumberValid = _accountNumberController.text.isNotEmpty;
                isAccountHolderValid = _accountHolderController.text.isNotEmpty;
              });
            }

            return AlertDialog(
              backgroundColor: const Color(0xfffafafa),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(w * 0.03),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              title: Text(
                _translations.enterBankData,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: w * 0.035, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    BankTextFieldWidget(
                      hint: _translations.bankName,
                      controller: _bankNameController,
                      screenWidth: w,
                      screenHeight: h,
                      type: TextInputType.name,
                      isValid: isBankNameValid,
                      errorMessage: _translations.fieldRequired,
                    ),
                    SizedBox(height: h * 0.02),
                    BankTextFieldWidget(
                      hint: _translations.accountNumber,
                      controller: _accountNumberController,
                      screenWidth: w,
                      screenHeight: h,
                      type: TextInputType.number,
                      isValid: isAccountNumberValid,
                      errorMessage: _translations.fieldRequired,
                    ),
                    SizedBox(height: h * 0.02),
                    BankTextFieldWidget(
                      hint: _translations.accountHolder,
                      controller: _accountHolderController,
                      screenWidth: w,
                      screenHeight: h,
                      type: TextInputType.name,
                      isValid: isAccountHolderValid,
                      errorMessage: _translations.fieldRequired,
                    ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KprimaryColor,
                      minimumSize: Size(0, h * 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      validateFields();

                      if (isBankNameValid && isAccountNumberValid && isAccountHolderValid) {
                        Navigator.pop(ctx);
                        if (mounted) {
                          setState(() {
                            _bankName = _bankNameController.text;
                            _accountNumber = _accountNumberController.text;
                            _accountHolder = _accountHolderController.text;
                            _hasBankData = true;
                          });
                        }
                      }
                    },
                    child: Text(
                      _translations.confirm,
                      style: TextStyle(fontSize: w * 0.035, color: Colors.white),
                    ),
                  ),
                )
              ],
            );
          }
      ),
    );
  }

  // ========== Presentation Layer - Main Build Method ==========
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: _translations.Marketing),
      body: _isLoading
          ? ShimmerLoadingWidget(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      )
          : Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenWidth * 0.05),
              Image.asset(
                KprimaryImage,
                width: screenWidth * 0.5,
                height: screenWidth * 0.5,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenWidth * 0.05),
              _buildUIByStatus(screenWidth, screenHeight),
              SizedBox(height: screenWidth * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  // ========== Presentation Layer - UI Router ==========
  // Marketing/Presentation/Views/Partials/ui_router.dart
  Widget _buildUIByStatus(double screenWidth, double screenHeight) {
    switch (_marketingData.status) {
      case MarketingStatus.notRequested:
        return _buildNotRequestedUI(screenWidth, screenHeight);
      case MarketingStatus.pending:
        return _buildPendingUI(screenWidth, screenHeight);
      case MarketingStatus.rejected:
        return _buildRejectedUI(screenWidth, screenHeight);
      case MarketingStatus.active:
      case MarketingStatus.approved:
      case MarketingStatus.accepted:
        return _buildActiveUI(screenWidth, screenHeight);
    }
  }
}
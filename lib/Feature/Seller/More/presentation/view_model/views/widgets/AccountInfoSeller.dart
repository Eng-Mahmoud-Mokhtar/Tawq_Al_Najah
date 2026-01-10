import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';

class AccountInfoSeller extends StatefulWidget {
  const AccountInfoSeller({Key? key}) : super(key: key);

  @override
  State<AccountInfoSeller> createState() => _AccountInfoSellerState();
}

class _AccountInfoSellerState extends State<AccountInfoSeller>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // API client
  final _api = _AccountInfoApi();

  // Plan details state
  bool _loadingPlan = true;
  String? _planError;
  String? _planStartDate;
  String? _planEndDate;

  // Ratings state
  bool _loadingRates = true;
  String? _ratesError;
  double _overallRating = 0.0;
  List<double> _ratesDistribution = [0, 0, 0, 0, 0];

  // Error state
  bool _hasConnectionError = false;
  String? _globalErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        Future.microtask(() {
          if (mounted) setState(() {});
          debugPrint('[AccountInfoSeller] Tab changed to index=${_tabController.index}');
        });
      }
    });

    _loadAll();
  }

  Future<void> _loadAll() async {
    debugPrint('[AccountInfoSeller] Loading plan details and rates ...');
    setState(() {
      _loadingPlan = true;
      _planError = null;
      _loadingRates = true;
      _ratesError = null;
      _hasConnectionError = false;
      _globalErrorMessage = null;
    });

    try {
      final plan = await _api.getSellerPlanDetails();
      debugPrint('[AccountInfoSeller] Parsed plan details raw: start=${plan.startDate}, end=${plan.endDate}');
      setState(() {
        _planStartDate = _formatDisplayDate(plan.startDate);
        _planEndDate = _formatDisplayDate(plan.endDate);
        _loadingPlan = false;
      });
      debugPrint('[AccountInfoSeller] Formatted plan dates: start=$_planStartDate, end=$_planEndDate');
    } catch (e, st) {
      debugPrint('[AccountInfoSeller] Error loading plan details: $e');
      debugPrint('[AccountInfoSeller] Stack: $st');
      setState(() {
        _planError = e.toString();
        _loadingPlan = false;
        _hasConnectionError = _hasConnectionError || _isNetworkError(e);
        _globalErrorMessage = _getUserFriendlyErrorMessage(e.toString());
      });
    }

    try {
      final rates = await _api.getSellerRates();
      debugPrint('[AccountInfoSeller] Parsed rates: overall=${rates.overall}, distribution=${rates.distribution}');
      final normalized = _normalizeDistribution(rates.distribution);
      setState(() {
        _overallRating = rates.overall;
        _ratesDistribution = normalized;
        _loadingRates = false;
      });
      debugPrint('[AccountInfoSeller] Normalized distribution (5..1): $_ratesDistribution');
    } catch (e, st) {
      debugPrint('[AccountInfoSeller] Error loading rates: $e');
      debugPrint('[AccountInfoSeller] Stack: $st');
      setState(() {
        _ratesError = e.toString();
        _loadingRates = false;
        _hasConnectionError = _hasConnectionError || _isNetworkError(e);
        if (_globalErrorMessage == null) {
          _globalErrorMessage = _getUserFriendlyErrorMessage(e.toString());
        }
      });
    }
  }

  bool _isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('timeout') ||
        errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('dio') ||
        (error is DioException && error.type != DioExceptionType.cancel);
  }

  String _getUserFriendlyErrorMessage(String technicalMessage) {
    final lowerMessage = technicalMessage.toLowerCase();

    if (lowerMessage.contains('timeout') || lowerMessage.contains('timed out')) {
      return S.current.connectionTimeout;
    } else if (lowerMessage.contains('no internet') || lowerMessage.contains('network')) {
      return S.current.connectionError;
    } else if (lowerMessage.contains('server') || lowerMessage.contains('500') || lowerMessage.contains('502')) {
      return S.current.serverError;
    } else if (lowerMessage.contains('unauthorized') || lowerMessage.contains('401')) {
      return S.current.sessionExpired;
    } else if (lowerMessage.contains('token') || lowerMessage.contains('login')) {
      return S.current.pleaseLoginFirst;
    }

    return S.current.failedToLoadData;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Utilities
  List<double> _normalizeDistribution(List<double> raw) {
    if (raw.isEmpty) return [0, 0, 0, 0, 0];

    final sum = raw.fold<double>(0, (p, c) => p + c);
    if (sum <= 0) {
      return raw.length == 5
          ? raw.map((e) => e > 1 ? (e / 100).clamp(0.0, 1.0) : e.clamp(0.0, 1.0)).toList()
          : [0, 0, 0, 0, 0];
    }
    final percents = raw.map((c) => (c / sum)).toList();
    if (percents.length == 5) return percents;
    if (percents.length > 5) return percents.take(5).toList();
    return [...percents, ...List<double>.filled(5 - percents.length, 0)];
  }

  String _formatDisplayDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '--/--/----';
    final s = raw.trim();

    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
    if (iso != null) {
      final y = int.tryParse(iso.group(1)!);
      final m = int.tryParse(iso.group(2)!);
      final d = int.tryParse(iso.group(3)!);
      if (y != null && m != null && d != null) return '$d/$m/$y';
    }

    final dmy = RegExp(r'^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})$').firstMatch(s);
    if (dmy != null) {
      final d = dmy.group(1)!;
      final m = dmy.group(2)!;
      final y = dmy.group(3)!;
      return '$d/$m/$y';
    }

    final pickIso = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
    if (pickIso != null) {
      final y = int.tryParse(pickIso.group(1)!);
      final m = int.tryParse(pickIso.group(2)!);
      final d = int.tryParse(pickIso.group(3)!);
      if (y != null && m != null && d != null) return '$d/$m/$y';
    }

    return s;
  }

  void _showRenewDialog(BuildContext context) {
    final s = S.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    debugPrint('[AccountInfoSeller] Renew action requested');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        titlePadding: EdgeInsets.only(
          top: screenWidth * 0.04,
          left: screenWidth * 0.04,
          right: screenWidth * 0.04,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.02,
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.015),
              decoration: BoxDecoration(
                color: KprimaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: screenWidth * 0.05),
            ),
            SizedBox(width: screenWidth * 0.02),
            Expanded(
              child: Text(
                s.renew_contract,
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: KprimaryText,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          s.renew_success,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        actionsPadding: EdgeInsets.only(
          left: screenWidth * 0.04,
          right: screenWidth * 0.04,
          bottom: screenWidth * 0.03,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KprimaryColor,
                    minimumSize: Size(0, screenWidth * 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    debugPrint('[AccountInfoSeller] Renew confirmed by user');
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    s.yes,
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    minimumSize: Size(0, screenWidth * 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    debugPrint('[AccountInfoSeller] Renew dismissed by user');
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    s.no,
                    style: TextStyle(color: Colors.black87, fontSize: screenWidth * 0.035),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== تصميم فشل الاتصال الموحد ====================
  Widget _buildErrorState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: screenHeight * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.04),
                  Icon(
                    Icons.network_check,
                    color: Colors.grey,
                    size: screenWidth * 0.15,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    S.of(context).connectionTimeout,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
            SizedBox(height: screenHeight * 0.04),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: ElevatedButton(
                onPressed: _loadAll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF580E),
                  minimumSize: Size(screenWidth * 0.04, screenHeight * 0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  S.of(context).tryAgain,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  // Shimmer helpers
  Widget _shimmerWrapper({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }

  Widget _shimmerLine({double width = double.infinity, double height = 14, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _shimmerCircle({double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // إذا كان هناك خطأ اتصال، نعرض شاشة الخطأ
    if (_hasConnectionError && (_loadingPlan || _loadingRates)) {
      return Scaffold(
        backgroundColor: SecoundColor,
        appBar: CustomAppBar(title: s.AccountInfo),
        body: _buildErrorState(context),
      );
    }

    return Scaffold(
      backgroundColor: SecoundColor,
      appBar: CustomAppBar(title: s.AccountInfo),
      body: Column(
        children: [
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: KprimaryColor,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w400,
              fontFamily: 'Tajawal',
            ),
            indicatorColor: KprimaryColor,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: s.contract_history),
              Tab(text: s.ratings),
            ],
          ),

          // محتوى التابات
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildContractTab(context, screenWidth, screenHeight, s),
                _buildRatingsTab(context, screenWidth, screenHeight, s),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContractTab(
      BuildContext context,
      double screenWidth,
      double screenHeight,
      S s,
      ) {
    // إذا كان هناك خطأ اتصال في هذا التبويب فقط
    if (_planError != null && _isNetworkError(_planError)) {
      return _buildErrorState(context);
    }

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Start Date
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _loadingPlan
                        ? _shimmerWrapper(child: _shimmerLine(width: screenWidth * 0.25, height: 18))
                        : Text(
                      s.start_date,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: KprimaryText,
                      ),
                    ),
                    _loadingPlan
                        ? _shimmerWrapper(child: _shimmerLine(width: screenWidth * 0.3, height: 16))
                        : Text(
                      _planError != null ? s.error : (_planStartDate ?? '--/--/----'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: _planError != null ? Colors.red : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // End Date
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _loadingPlan
                        ? _shimmerWrapper(child: _shimmerLine(width: screenWidth * 0.25, height: 18))
                        : Text(
                      s.end_date,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: KprimaryText,
                      ),
                    ),
                    _loadingPlan
                        ? _shimmerWrapper(child: _shimmerLine(width: screenWidth * 0.3, height: 16))
                        : Text(
                      _planError != null ? s.error : (_planEndDate ?? '--/--/----'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: _planError != null ? Colors.red : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Renew button
              _loadingPlan
                  ? _shimmerWrapper(
                child: Container(
                  width: double.infinity,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
              )
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showRenewDialog(context),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                    child: Text(
                      s.renew_contract,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1D3A77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingsTab(
      BuildContext context,
      double screenWidth,
      double screenHeight,
      S s,
      ) {
    if (_ratesError != null && _isNetworkError(_ratesError)) {
      return _buildErrorState(context);
    }

    final starPercents = _ratesDistribution.length == 5 ? _ratesDistribution : [0, 0, 0, 0, 0];

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Overall rating row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _loadingRates
                        ? _shimmerWrapper(child: _shimmerLine(width: screenWidth * 0.35, height: 18))
                        : Text(
                      s.overall_rating,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (_loadingRates) ...[
                          _shimmerWrapper(child: _shimmerLine(width: screenWidth * 0.15, height: 18)),
                          SizedBox(width: screenWidth * 0.02),
                          _shimmerWrapper(child: _shimmerCircle(size: screenWidth * 0.05)),
                        ] else ...[
                          Text(
                            (_overallRating).toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                              color: KprimaryColor,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Icon(Icons.star, color: Colors.amber, size: screenWidth * 0.05),
                        ],
                      ],
                    ),
                  ],
                ),

                if (_ratesError != null && !_loadingRates) ...[
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    s.error,
                    style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.03),
                  ),
                ],

                SizedBox(height: screenHeight * 0.02),

                // Stars distribution rows (5..1)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    final stars = 5 - index;
                    final percent = _loadingRates ? 0.0 : (starPercents[index].clamp(0.0, 1.0)).toDouble();
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.18,
                            child: _loadingRates
                                ? _shimmerWrapper(
                              child: Row(
                                children: [
                                  _shimmerLine(width: 22, height: 18),
                                  SizedBox(width: 6),
                                  _shimmerCircle(size: screenWidth * 0.045),
                                ],
                              ),
                            )
                                : Row(
                              children: [
                                Text(
                                  "$stars ",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(Icons.star, color: Colors.amber, size: screenWidth * 0.045),
                              ],
                            ),
                          ),
                          Expanded(
                            child: _loadingRates
                                ? _shimmerWrapper(child: _shimmerLine(height: 10, radius: 8))
                                : LinearPercentIndicator(
                              lineHeight: 8.0,
                              percent: percent,
                              backgroundColor: Colors.grey[300],
                              progressColor: KprimaryColor,
                              barRadius: const Radius.circular(8),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          _loadingRates
                              ? _shimmerWrapper(child: _shimmerLine(width: 40, height: 14))
                              : Text(
                            "${(percent * 100).toStringAsFixed(0)}%",
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================== API layer ==============================

class _AccountInfoApi {
  _AccountInfoApi({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage() {
    // Log all requests/responses in terminal
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }

  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const String baseUrl = 'https://toknagah.viking-iceland.online/api';
  static const String ratesEndpoint = '$baseUrl/user/saller-rates';
  static const String planDetailsEndpoint = '$baseUrl/user/auth/saller-plan-details';

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'user_token');
    debugPrint('[AccountInfoAPI] Read token: ${token != null && token.isNotEmpty ? '***' : 'null/empty'}');
    return token;
  }

  Options _buildOptions(String token) {
    final opts = Options(headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
    debugPrint('[AccountInfoAPI] Built headers: ${jsonEncode(opts.headers)}');
    return opts;
  }

  Future<_SellerPlanDetails> getSellerPlanDetails() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      debugPrint('[AccountInfoAPI] ERROR: Missing token for plan details');
      throw Exception('Token is missing. Please login.');
    }

    debugPrint('[AccountInfoAPI] GET $planDetailsEndpoint');
    final res = await _dio.get(
      planDetailsEndpoint,
      options: _buildOptions(token),
    );
    debugPrint('[AccountInfoAPI] Plan details statusCode=${res.statusCode}');
    _prettyLog('[AccountInfoAPI] Plan details response', res.data);

    if ((res.statusCode ?? 500) >= 200 && (res.statusCode ?? 500) < 300) {
      final model = _SellerPlanDetails.fromAny(res.data);
      debugPrint('[AccountInfoAPI] Parsed plan model: start=${model.startDate}, end=${model.endDate}');
      return model;
    }
    throw Exception('Failed to load plan details: ${res.statusCode}');
  }

  Future<_SellerRates> getSellerRates() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      debugPrint('[AccountInfoAPI] ERROR: Missing token for rates');
      throw Exception('Token is missing. Please login.');
    }

    debugPrint('[AccountInfoAPI] GET $ratesEndpoint');
    final res = await _dio.get(
      ratesEndpoint,
      options: _buildOptions(token),
    );
    debugPrint('[AccountInfoAPI] Rates statusCode=${res.statusCode}');
    _prettyLog('[AccountInfoAPI] Rates response', res.data);

    if ((res.statusCode ?? 500) >= 200 && (res.statusCode ?? 500) < 300) {
      final model = _SellerRates.fromAny(res.data);
      debugPrint('[AccountInfoAPI] Parsed rates model: overall=${model.overall}, distribution=${model.distribution}');
      return model;
    }
    throw Exception('Failed to load rates: ${res.statusCode}');
  }

  void _prettyLog(String label, dynamic data) {
    try {
      final encoder = const JsonEncoder.withIndent('  ');
      final pretty = encoder.convert(_toEncodable(data));
      debugPrint('$label:\n$pretty');
    } catch (_) {
      debugPrint('$label (raw): ${data.toString()}');
    }
  }

  dynamic _toEncodable(dynamic data) {
    if (data is Map || data is List) return data;
    try {
      return jsonDecode(data.toString());
    } catch (_) {
      return {'value': data.toString()};
    }
  }
}

class _SellerPlanDetails {
  final String? startDate;
  final String? endDate;

  _SellerPlanDetails({this.startDate, this.endDate});

  // Flexible parser for varied backend shapes
  static _SellerPlanDetails fromAny(dynamic data) {
    Map<String, dynamic>? map;

    if (data is Map<String, dynamic>) {
      map = data;
    } else if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      map = data.first as Map<String, dynamic>;
    }

    // If wrapper like {data: {...}}
    if (map != null && map['data'] is Map<String, dynamic>) {
      map = map['data'] as Map<String, dynamic>;
    }

    String? pickString(Map<String, dynamic>? src, List<String> keys) {
      if (src == null) return null;
      for (final k in keys) {
        final v = src[k];
        if (v != null) {
          final s = v.toString().trim();
          if (s.isNotEmpty) return s;
        }
      }
      return null;
    }

    final start = pickString(map, ['start_date', 'startDate', 'contract_start', 'begin_date', 'start']);
    final end = pickString(map, ['end_date', 'endDate', 'contract_end', 'finish_date', 'end']);

    return _SellerPlanDetails(startDate: start, endDate: end);
  }
}

class _SellerRates {
  final double overall;
  // distribution ordered by stars 5..1 as fractions 0..1
  final List<double> distribution;

  _SellerRates({
    required this.overall,
    required this.distribution,
  });

  // Parse list shape {status, message, data: [ {rate,count,percentage}, ... ]}
  static _SellerRates fromAny(dynamic data) {
    Map<String, dynamic>? map;
    if (data is Map<String, dynamic>) {
      map = data;
    }

    // If top-level contains "data" as a List with items {rate,count,percentage}
    if (map != null && map['data'] is List) {
      final list = (map['data'] as List).whereType<Map>().toList();
      debugPrint('[SellerRates.fromAny] Detected list of rates items, len=${list.length}');

      // Buckets keyed by star value
      final bucketsCount = <int, double>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      final bucketsPercent = <int, double>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      bool anyCount = false;
      bool anyPercent = false;

      for (final item in list) {
        // keys: rate (1..5), count, percentage like "75%"
        final rateRaw = item['rate'] ?? item['stars'] ?? item['star'] ?? item['rating'];
        int? star;
        if (rateRaw is num) star = rateRaw.toInt();
        if (rateRaw is String) star = int.tryParse(rateRaw);
        if (star == null || star < 1 || star > 5) continue;

        final countRaw = item['count'];
        if (countRaw != null) {
          double c = 0;
          if (countRaw is num) c = countRaw.toDouble();
          if (countRaw is String) c = double.tryParse(countRaw) ?? 0;
          bucketsCount[star] = (bucketsCount[star] ?? 0) + c;
          if (c > 0) anyCount = true;
        }

        final percRaw = item['percentage'] ?? item['percent'];
        if (percRaw != null) {
          double p = 0;
          if (percRaw is String) {
            final cleaned = percRaw.replaceAll('%', '').trim();
            final val = double.tryParse(cleaned);
            if (val != null) p = val / 100.0;
          } else if (percRaw is num) {
            p = percRaw > 1 ? (percRaw.toDouble() / 100.0) : percRaw.toDouble();
          }
          bucketsPercent[star] = p;
          if (p > 0) anyPercent = true;
        }
      }

      // Build distribution in order [5,4,3,2,1]
      List<double> distribution;
      double overall;

      if (anyCount) {
        final total = bucketsCount.values.fold<double>(0, (p, c) => p + c);
        if (total > 0) {
          distribution = [
            (bucketsCount[5] ?? 0) / total,
            (bucketsCount[4] ?? 0) / total,
            (bucketsCount[3] ?? 0) / total,
            (bucketsCount[2] ?? 0) / total,
            (bucketsCount[1] ?? 0) / total,
          ];
          overall = ((bucketsCount[5] ?? 0) * 5 +
              (bucketsCount[4] ?? 0) * 4 +
              (bucketsCount[3] ?? 0) * 3 +
              (bucketsCount[2] ?? 0) * 2 +
              (bucketsCount[1] ?? 0) * 1) /
              total;
        } else {
          distribution = [0, 0, 0, 0, 0];
          overall = 0;
        }
      } else if (anyPercent) {
        distribution = [
          (bucketsPercent[5] ?? 0),
          (bucketsPercent[4] ?? 0),
          (bucketsPercent[3] ?? 0),
          (bucketsPercent[2] ?? 0),
          (bucketsPercent[1] ?? 0),
        ];
        // Weighted average based on percents
        final sumPerc = distribution.fold<double>(0, (p, c) => p + c);
        overall = sumPerc > 0
            ? ((bucketsPercent[5] ?? 0) * 5 +
            (bucketsPercent[4] ?? 0) * 4 +
            (bucketsPercent[3] ?? 0) * 3 +
            (bucketsPercent[2] ?? 0) * 2 +
            (bucketsPercent[1] ?? 0) * 1) /
            sumPerc
            : 0;
      } else {
        distribution = [0, 0, 0, 0, 0];
        overall = 0;
      }

      debugPrint('[SellerRates.fromAny] Computed distribution(5..1)=$distribution, overall=$overall');
      return _SellerRates(overall: overall, distribution: distribution);
    }

    // Fallback: unwrap "data" if map
    if (map != null && map['data'] is Map<String, dynamic>) {
      map = map['data'] as Map<String, dynamic>;
    }

    double pickDouble(Map<String, dynamic>? src, List<String> keys, {double defaultValue = 0.0}) {
      if (src == null) return defaultValue;
      for (final k in keys) {
        final v = src[k];
        if (v is num) return v.toDouble();
        if (v is String) {
          final p = double.tryParse(v);
          if (p != null) return p;
        }
      }
      return defaultValue;
    }

    final overall = pickDouble(map, [
      'overall',
      'average',
      'rating',
      'rate',
      'overall_rating',
      'avg_rating',
    ], defaultValue: 0.0).clamp(0.0, 5.0);

    List<double> dist = [];
    dynamic distRaw;
    if (map != null) {
      distRaw = map['distribution'] ??
          map['stars_distribution'] ??
          map['histogram'] ??
          map['stars'] ??
          map['rates'];
    }

    if (distRaw is List) {
      if (distRaw.isNotEmpty && distRaw.first is num) {
        dist = distRaw.map<double>((e) => (e as num).toDouble()).toList();
      } else if (distRaw.isNotEmpty && distRaw.first is Map) {
        final buckets = <int, double>{};
        for (final item in distRaw) {
          if (item is Map) {
            final s = item['stars'] ?? item['star'] ?? item['rating'] ?? item['grade'];
            final c = item['count'] ?? item['value'] ?? item['percent'];
            int? star;
            double? val;
            if (s is num) star = s.toInt();
            if (s is String) star = int.tryParse(s);
            if (c is num) val = c.toDouble();
            if (c is String) {
              final cleaned = c.replaceAll('%', '').trim();
              final parsed = double.tryParse(cleaned);
              if (parsed != null) val = parsed > 1 ? parsed / 100.0 : parsed;
            }
            if (star != null && val != null) {
              buckets[star] = (buckets[star] ?? 0) + val;
            }
          }
        }
        dist = [
          buckets[5] ?? 0,
          buckets[4] ?? 0,
          buckets[3] ?? 0,
          buckets[2] ?? 0,
          buckets[1] ?? 0,
        ];
      }
    } else if (distRaw is Map) {
      final m = distRaw;
      double getVal(dynamic k) {
        final v = m[k];
        if (v is num) return v.toDouble();
        if (v is String) {
          final cleaned = v.replaceAll('%', '').trim();
          final parsed = double.tryParse(cleaned);
          if (parsed != null) return parsed > 1 ? parsed / 100.0 : parsed;
        }
        return 0.0;
      }

      dist = [
        getVal('5') + getVal(5),
        getVal('4') + getVal(4),
        getVal('3') + getVal(3),
        getVal('2') + getVal(2),
        getVal('1') + getVal(1),
      ];
    }

    // Ensure 5 buckets
    if (dist.length < 5) {
      dist = [...dist, ...List<double>.filled(5 - dist.length, 0)];
    } else if (dist.length > 5) {
      dist = dist.take(5).toList();
    }

    debugPrint('[SellerRates.fromAny] Fallback distribution=$dist, overall=$overall');
    return _SellerRates(overall: overall, distribution: dist);
  }
}
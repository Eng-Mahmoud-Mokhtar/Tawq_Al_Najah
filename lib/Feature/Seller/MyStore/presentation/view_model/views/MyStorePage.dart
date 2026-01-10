import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../Buyer/MyPosts/presentation/view_model/MyPosts_Cubit.dart';
import '../../../../../Buyer/MyPosts/presentation/view_model/views/AdsDetails.dart';
import '../../../../Home/presentation/view_model/views/HomeStructure.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class MyStore extends StatefulWidget {
  final bool fromBottomNav;

  const MyStore({super.key, this.fromBottomNav = false});

  @override
  State<MyStore> createState() => _MyStoreState();
}

class _MyStoreState extends State<MyStore> with RouteAware {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  CancelToken _cancelToken = CancelToken();

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Map<String, dynamic>> _displayedAds = [];

  static const String _baseUrl = 'https://toknagah.viking-iceland.online';

  @override
  void initState() {
    super.initState();
    _fetchMyAds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPush() {
    _fetchMyAds();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel("Disposed");
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    _fetchMyAds();
  }

  String _normalizeToken(String? token) {
    if (token == null || token.isEmpty) return '';
    return token.startsWith('Bearer ') ? token.substring(7) : token;
  }

  Future<void> _fetchMyAds() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      final rawToken = await _storage.read(key: 'user_token');
      final token = _normalizeToken(rawToken);

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      if (!_cancelToken.isCancelled) _cancelToken.cancel('cancelling previous');
      _cancelToken = CancelToken();

      final response = await _dio.get(
        '$_baseUrl/api/user/products-my-ads',
        options: Options(headers: headers, validateStatus: (_) => true),
        cancelToken: _cancelToken,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseMap = response.data as Map<String, dynamic>;
        final data = responseMap['data'];

        List<dynamic> adsJson;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is List) {
            adsJson = data['data'] as List<dynamic>;
          } else {
            final values = data.values.toList();
            adsJson = values.isNotEmpty && values[0] is List ? values[0] as List<dynamic> : [];
          }
        } else if (data is List) {
          adsJson = data;
        } else {
          adsJson = [];
        }

        final ads = adsJson.map((e) => e as Map<String, dynamic>).toList();

        setState(() {
          _displayedAds = ads;
          _isLoading = false;
        });
        try {
          context.read<MyPostsCubit>().loadAds(ads);
        } catch (_) {}
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) return;
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchMyAds();
  }

  Future<void> _navigateToProductDetails(
      BuildContext context,
      int productId,
      Map<String, dynamic> productData,
      ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdsDetails(
          productId: productId,
          initialProductData: productData,
        ),
      ),
    );

    if (result == true) {
      await _fetchMyAds();
    }
  }

  // ==================== تصميم فشل الاتصال الموحد ====================
  Widget _buildErrorState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: screenHeight * 0.8,
        child: Center(
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
                  onPressed: _fetchMyAds,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFF580E),
                    minimumSize: Size(screenWidth * 0.4, screenHeight * 0.04),
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
      ),
    );
  }

  Widget _buildShimmerLoading(double screenWidth) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: screenWidth * 0.04,
        crossAxisSpacing: screenWidth * 0.04,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(double screenWidth, double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('Assets/empty-cart 1.png', width: screenWidth * 0.5),
          SizedBox(height: screenHeight * 0.04),
          Text(
            S.of(context).noAdsYet,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            S.of(context).noSuggestionsAvailable,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String? _extractFirstImageUrl(Map<String, dynamic> ad) {
    final images = ad['images'] ?? ad['image'] ?? ad['main_image'];

    if (images is String) {
      if (images.trim().isEmpty) return null;
      return _normalizeImageUrl(images.trim());
    }

    if (images is List && images.isNotEmpty) {
      final first = images.first;
      if (first is String) {
        if (first.trim().isEmpty) return null;
        return _normalizeImageUrl(first.trim());
      }
      if (first is Map) {
        final possible = first['url'] ??
            first['image'] ??
            first['path'] ??
            first['src'] ??
            first['link'];
        if (possible is String && possible.trim().isNotEmpty) {
          return _normalizeImageUrl(possible.trim());
        }
      }
    }

    return null;
  }

  String _normalizeImageUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$_baseUrl$url';
    return '$_baseUrl/$url';
  }

  Widget _buildProductCard(
      Map<String, dynamic> ad,
      int originalIndex,
      double screenWidth,
      double screenHeight,
      ) {
    final cardWidth = (screenWidth - (screenWidth * 0.08 + 16)) / 2;
    final cardHeight = cardWidth * 1.4;

    final price = ad['price']?.toString() ?? '0';
    final currency = _getCurrencyFromAd(ad);

    return GestureDetector(
      onTap: () {
        final productId = ad['id'] as int? ?? 0;
        final productData = _prepareProductDataForDetails(ad, currency);
        _navigateToProductDetails(context, productId, productData);
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(158, 158, 158, 0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(cardWidth * 0.05)),
                child: _buildImageSection(ad, cardWidth, cardHeight),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(cardWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        ad['name'] ?? '',
                        style: TextStyle(
                          fontSize: cardHeight * 0.05,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: cardHeight * 0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        ad['description'] ?? '',
                        style: TextStyle(
                          fontSize: cardHeight * 0.045,
                          color: Colors.grey[700],
                          fontFamily: 'Tajawal',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: cardHeight * 0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "$price $currency",
                        style: TextStyle(
                          fontSize: cardHeight * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xffFF580E),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencyFromAd(Map<String, dynamic> ad) {
    final currency = ad['currency']?.toString() ??
        ad['currency_type']?.toString() ??
        ad['currencyType']?.toString();
    if (currency == null || currency.isEmpty) {
      return 'ريال';
    }
    return currency;
  }

  Map<String, dynamic> _prepareProductDataForDetails(Map<String, dynamic> ad, String currency) {
    final productData = Map<String, dynamic>.from(ad);
    productData['currency'] = currency;
    productData['currency_type'] = currency;
    productData['currencyType'] = currency;
    productData['priceAfterDiscount'] = ad['price_after_discount'] ?? ad['price'];
    productData['images'] = ad['images'] ?? [];

    return productData;
  }

  Widget _buildImageSection(Map<String, dynamic> ad, double cardWidth, double cardHeight) {
    final imageUrl = _extractFirstImageUrl(ad);

    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildImageErrorPlaceholder(cardWidth, cardHeight);
    }

    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: Colors.grey[100],
          child: Center(
            child: CircularProgressIndicator(
              color: const Color(0xffFF580E),
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildImageErrorPlaceholder(cardWidth, cardHeight),
      );
    }

    if (!kIsWeb) {
      return Image.file(
        File(imageUrl),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageErrorPlaceholder(cardWidth, cardHeight),
      );
    }

    return _buildImageErrorPlaceholder(cardWidth, cardHeight);
  }

  Widget _buildImageErrorPlaceholder(double cardWidth, double cardHeight) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade400, size: cardWidth * 0.15),
          SizedBox(height: cardHeight * 0.04),
          Text(
            S.of(context).errorLoadingCategories,
            style: TextStyle(
              fontSize: cardWidth * 0.05,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Ensures RefreshIndicator can be triggered even for empty/error states
  Widget _scrollableWrapper(Widget child, double minHeight) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: minHeight, child: child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: screenWidth * 0.05,
          ),
          onPressed: () {
            if (widget.fromBottomNav) {
              context.read<BottomNavSCubit>().setIndex(0);
            } else {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                context.read<BottomNavSCubit>().setIndex(0);
              }
            }
          },
        ),
        title: Text(
          S.of(context).myAds,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
            color: KprimaryText,
          ),
        ),
      ),
      backgroundColor: const Color(0xfffafafa),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xffFF580E),
                onRefresh: _onRefresh,
                child: _isLoading
                    ? _buildShimmerLoading(screenWidth)
                    : _hasError
                    ? _scrollableWrapper(_buildErrorState(context), screenHeight * 0.8)
                    : _displayedAds.isEmpty
                    ? _scrollableWrapper(_buildEmptyState(screenWidth, screenHeight), screenHeight * 0.8)
                    : Directionality(
                  textDirection: TextDirection.rtl,
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: screenWidth * 0.04,
                      crossAxisSpacing: screenWidth * 0.04,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _displayedAds.length,
                    itemBuilder: (context, index) {
                      final ad = _displayedAds[index];
                      return _buildProductCard(ad, index, screenWidth, screenHeight);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
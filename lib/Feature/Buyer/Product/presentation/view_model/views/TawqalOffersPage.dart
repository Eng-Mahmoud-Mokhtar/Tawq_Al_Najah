import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';
import 'package:tawqalnajah/Feature/Buyer/Product/presentation/view_model/views/ProductDetailsPage.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../Categories/presentation/view_model/filter_products_cubit.dart';
import '../../../../Categories/presentation/view_model/views/Widgets/FilterBottomSheet.dart';
import '../../../../Home/presentation/view_model/views/widgets/ImageHome.dart';
import '../../../Data/Models/ProductModel.dart';
import '../cart_cubit.dart';
import '../favorite_cubit.dart';

class TawqalOffersPage extends StatefulWidget {
  const TawqalOffersPage({super.key});

  @override
  State<TawqalOffersPage> createState() => _TawqalOffersPageState();
}

class _TawqalOffersPageState extends State<TawqalOffersPage> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late List<ProductModel> _displayedProducts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isSearchLoading = false;
  bool _isFilterActive = false;
  final ScrollController _gridViewController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  CancelToken _cancelToken = CancelToken();
  Timer? _searchDebounce;
  double _currentMinPrice = 0;
  double _currentMaxPrice = kFilterMaxPrice;

  final FilterProductsCubit _filterCubit = FilterProductsCubit();

  @override
  void initState() {
    super.initState();
    _initData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initData() async {
    context.read<FavoriteCubit>().loadFavorites();
    context.read<CartCubit>().loadCart();
    await _loadOffers();
    await _getCurrentCartSeller();
    _fetchProducts(); // استدعاء أولي للحصول على المنتجات
  }

  Future<void> _getCurrentCartSeller() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'user_token');
      if (token == null) return;

      final dio = Dio();
      dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await dio.get(
        'https://toknagah.viking-iceland.online/api/user/add-to-cart',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final cartItems = response.data['data'] as List;
        if (cartItems.isNotEmpty) {
          final firstItemSellerId = cartItems[0]['saller_id'] ?? cartItems[0]['seller_id'];
          final sellerId = firstItemSellerId != null ? int.tryParse(firstItemSellerId.toString()) : null;
          context.read<CartCubit>().updateSellerId(sellerId);
        } else {
          context.read<CartCubit>().updateSellerId(null);
        }
      }
    } catch (e) {
      debugPrint('Error getting cart seller: $e');
    }
  }

  Future<void> _loadOffers() async {
    try {
      setState(() => _isLoading = true);
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'user_token');

      final dio = Dio();
      dio.options.headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await dio.get(
        'https://toknagah.viking-iceland.online/api/user/products?type=normal',
      );

      dynamic json = response.data;
      if (json is String) json = jsonDecode(json);

      final list = json['data'] is List ? json['data'] : [];
      final loaded = <ProductModel>[];

      for (var item in list) {
        if (item is Map<String, dynamic>) {
          try {
            loaded.add(ProductModel.fromJson(item));
          } catch (e) {
            debugPrint('Parse error: $e');
          }
        }
      }

      if (mounted) setState(() {
        _displayedProducts = loaded;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Load offers error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _gridViewController.dispose();
    _searchDebounce?.cancel();
    _filterCubit.close();
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel("Disposed");
    }
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (query.isNotEmpty) {
        _fetchProducts(
          searchQuery: query,
          minPrice: _currentMinPrice > 0 ? _currentMinPrice : null,
          maxPrice: _currentMaxPrice != kFilterMaxPrice
              ? _currentMaxPrice
              : null,
        );
      }
    });
  }

  void _resetSearch() {
    _searchDebounce?.cancel();
    if (!mounted) return;
    setState(() {
      _isSearchLoading = false;
    });
    _fetchProducts(
      minPrice: _currentMinPrice > 0 ? _currentMinPrice : null,
      maxPrice: _currentMaxPrice != kFilterMaxPrice ? _currentMaxPrice : null,
    );
  }

  Future<void> _fetchProducts({
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      if (!mounted) return;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        setState(() {
          _isSearchLoading = true;
        });
      } else {
        setState(() {
          _isLoading = true;
          _isSearchLoading = false;
          _hasError = false;
        });
      }

      final token = await _storage.read(key: 'user_token');
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null) headers['Authorization'] = 'Bearer $token';

      try {
        if (!_cancelToken.isCancelled) _cancelToken.cancel('cancelling previous');
      } catch (_) {}
      _cancelToken = CancelToken();

      final Map<String, dynamic> queryParams = {
        'type': 'normal',
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final int minParam = (minPrice ?? _currentMinPrice).toInt();
      final int maxParam = (maxPrice ?? _currentMaxPrice).toInt();
      queryParams['min_price'] = minParam;
      queryParams['max_price'] = maxParam;

      final response = await _dio.get(
        'https://toknagah.viking-iceland.online/api/user/products',
        queryParameters: queryParams,
        options: Options(
          headers: headers,
          validateStatus: (_) => true,
        ),
        cancelToken: _cancelToken,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final responseMap = response.data as Map<String, dynamic>;

          final data = responseMap['data'];

          List<dynamic> productsJson;

          if (data is Map<String, dynamic>) {
            if (data.containsKey('data') && data['data'] is List) {
              productsJson = data['data'] as List<dynamic>;
            } else {
              final values = data.values.toList();
              if (values.isNotEmpty && values[0] is List) {
                productsJson = values[0] as List<dynamic>;
              } else {
                productsJson = [];
              }
            }
          } else if (data is List) {
            productsJson = data;
          } else {
            productsJson = [];
          }

          final products = productsJson.map((e) {
            try {
              return ProductModel.fromJson(e as Map<String, dynamic>);
            } catch (e) {
              return null;
            }
          }).where((product) => product != null).cast<ProductModel>().toList();

          if (!mounted) return;

          setState(() {
            _displayedProducts = products;
            _isLoading = false;
            _isSearchLoading = false;
            _hasError = false;
            _isFilterActive = (searchQuery != null && searchQuery.isNotEmpty) ||
                (minPrice != null) ||
                (maxPrice != null);

            if (minPrice != null) _currentMinPrice = minPrice;
            if (maxPrice != null) _currentMaxPrice = maxPrice;

            _filterCubit.updateFilters(
              minPrice: minPrice ?? _currentMinPrice,
              maxPrice: maxPrice ?? _currentMaxPrice,
            );
          });
        } catch (parseError) {
          if (!mounted) return;
          setState(() {
            _displayedProducts = [];
            _isLoading = false;
            _isSearchLoading = false;
            _hasError = true;
            _errorMessage = 'Parsing error';
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _isSearchLoading = false;
          _hasError = true;
          _errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) return;
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSearchLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchProducts(
      searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
      minPrice: _currentMinPrice > 0 ? _currentMinPrice : null,
      maxPrice: _currentMaxPrice != kFilterMaxPrice ? _currentMaxPrice : null,
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      builder: (_) => FilterProudctsBottomSheet(
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        initialFilterState: FilterProductsState(
          minPrice: _currentMinPrice,
          maxPrice: _currentMaxPrice,
        ),
        onApplyFilters: (filters) {
          _handleFilterApply(filters);
        },
      ),
    );
  }

  void _handleFilterApply(Map<String, dynamic> filters) {
    if (!mounted) return;

    setState(() {
      _currentMinPrice = filters['minPrice'] ?? 0;
      _currentMaxPrice = filters['max_price'] ?? filters['maxPrice'] ?? kFilterMaxPrice;
    });

    final searchQuery = _searchController.text.isNotEmpty ? _searchController.text : null;

    _fetchProducts(
      searchQuery: searchQuery,
      minPrice: _currentMinPrice > 0 ? _currentMinPrice : null,
      maxPrice: (_currentMaxPrice != kFilterMaxPrice && _currentMaxPrice > 0)
          ? _currentMaxPrice
          : null,
    );
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _currentMinPrice = 0;
      _currentMaxPrice = kFilterMaxPrice;
    });

    _fetchProducts();
  }

  void _navigateToProductDetails(BuildContext context, int productId, Map<String, dynamic> productData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetails(
          productId: productId,
          initialProductData: productData,
        ),
      ),
    );
  }

  Widget _buildSearchFilterBar(double screenWidth) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: screenWidth * 0.04,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xffE9E9E9)),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(128, 128, 128, 0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: screenWidth * 0.035,
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: screenWidth * 0.06,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        TextField(
                          controller: _searchController,
                          textDirection: Directionality.of(context) == TextDirection.rtl
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: S.of(context).search,
                            hintTextDirection: Directionality.of(context) == TextDirection.rtl
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            hintStyle: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsetsDirectional.symmetric(
                              vertical: screenWidth * 0.035,
                              horizontal: screenWidth * 0.03,
                            ),
                          ),
                        ),
                        if (_isSearchLoading)
                          Positioned.fill(
                            child: Container(
                              color: Colors.white.withOpacity(0.8),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: KprimaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_searchController.text.isNotEmpty && !_isSearchLoading)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: screenWidth * 0.05,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        _resetSearch();
                      },
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context),
            child: Container(
              height: screenWidth * 0.12,
              width: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: KprimaryColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(128, 128, 128, 0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.tune,
                color: Colors.white,
                size: screenWidth * 0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
      ProductModel product,
      Map<String, dynamic> productMap,
      int productId,
      bool isFav,
      bool isAdded,
      double screenWidth,
      ) {
    final cardWidth = (screenWidth - 48) / 2;
    final cardHeight = cardWidth * 1.4;

    final price = product.priceAfterDiscount > 0 ? product.priceAfterDiscount : product.price;
    final currency = product.currencyType?.isNotEmpty == true
        ? product.currencyType!
        : S.of(context).SYP;

    return GestureDetector(
      onTap: () => _navigateToProductDetails(context, productId, productMap),
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.2 * 255).round()),
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
                child: _buildImageSection(productMap, productId, isFav, cardWidth, cardHeight),
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
                        product.name,
                        style: TextStyle(fontSize: cardHeight * 0.05, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: cardHeight * 0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        product.description,
                        style: TextStyle(fontSize: cardHeight * 0.045, color: Colors.grey[700]),
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
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => context.read<CartCubit>().toggleCartWithApi(productId, productMap),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdded ? Colors.grey.withAlpha((0.3 * 255).round()) : const Color(0xffFF580E),
                        minimumSize: Size(double.infinity, cardHeight * 0.14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardWidth * 0.15)),
                      ),
                      child: Text(
                        isAdded ? S.of(context).addedToCart : S.of(context).AddtoCart,
                        style: TextStyle(fontSize: cardHeight * 0.045, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(
      Map<String, dynamic> productMap,
      int productId,
      bool isFav,
      double cardWidth,
      double cardHeight,
      ) {
    final imageUrl = (productMap['images'] is List && productMap['images'].isNotEmpty)
        ? productMap['images'][0]
        : null;

    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return _buildImageErrorPlaceholder(cardWidth, cardHeight);
    }

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: ImageHome.getValidImageUrl(imageUrl),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Container(
            color: Colors.grey[100],
            child: Center(child: CircularProgressIndicator(color: const Color(0xffFF580E), strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => _buildImageErrorPlaceholder(cardWidth, cardHeight),
        ),
        Positioned(
          top: cardWidth * 0.05,
          left: cardWidth * 0.05,
          child: GestureDetector(
            onTap: () => context.read<FavoriteCubit>().toggleFavoriteWithApi(productId),
            child: Container(
              padding: EdgeInsets.all(cardWidth * 0.03),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withAlpha((0.5 * 255).round())),
              child: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? const Color(0xffFF580E) : Colors.white,
                size: cardWidth * 0.1,
              ),
            ),
          ),
        ),
      ],
    );
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
            style: TextStyle(fontSize: cardWidth * 0.05, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(double screenWidth, double screenHeight) {
    final cardWidth = (screenWidth - 48) / 2;
    return GridView.builder(
      controller: _gridViewController,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cardWidth * 0.05),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((0.2 * 255).round()),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(cardWidth * 0.05),
              ),
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
          Icon(
            Icons.psychology_outlined,
            color: Colors.grey.shade400,
            size: screenWidth * 0.2,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            S.of(context).NoResultstoShow,
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
          SizedBox(height: screenHeight * 0.1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(title: S.of(context).tawqalOffers),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          _buildSearchFilterBar(screenWidth),
          SizedBox(height: screenHeight * 0.02),
          if (_isFilterActive || _searchController.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${S.of(context).filteredResults}: ${_displayedProducts.length}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: KprimaryColor,
                    ),
                  ),
                  if ((_isFilterActive || _searchController.text.isNotEmpty) && _displayedProducts.isNotEmpty)
                    TextButton(
                      onPressed: _resetFilters,
                      child: Text(
                        S.of(context).clearAll,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          SizedBox(height: screenHeight * 0.01),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: RefreshIndicator(
                color: const Color(0xffFF580E),
                onRefresh: _onRefresh,
                child: _isLoading
                    ? _buildShimmerLoading(screenWidth, screenHeight)
                    : _hasError
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.network_check,
                        color: Colors.grey,
                        size: screenWidth * 0.15,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                        child: Text(
                          _errorMessage.isNotEmpty ? _errorMessage : S.of(context).connectionTimeout,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ElevatedButton(
                        onPressed: () => _fetchProducts(
                          searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
                          minPrice: _currentMinPrice > 0 ? _currentMinPrice : null,
                          maxPrice: _currentMaxPrice != kFilterMaxPrice ? _currentMaxPrice : null,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffFF580E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          S.of(context).tryAgain,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.1),
                    ],
                  ),
                )
                    : _displayedProducts.isEmpty
                    ? _buildEmptyState(screenWidth, screenHeight)
                    : BlocBuilder<FavoriteCubit, Set<int>>(
                  builder: (context, favoriteIds) {
                    return BlocBuilder<CartCubit, CartState>(
                      builder: (context, cartState) {
                        return GridView.builder(
                          controller: _gridViewController,
                          padding: EdgeInsets.zero,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: _displayedProducts.length,
                          itemBuilder: (context, index) {
                            final product = _displayedProducts[index];
                            final productMap = product.toMap()
                              ..['images'] = ImageHome.processImageList(product.images);

                            return _buildProductCard(
                              product,
                              productMap,
                              product.id,
                              favoriteIds.contains(product.id),
                              cartState.cartIds.contains(product.id),
                              screenWidth,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
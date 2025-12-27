import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../Product/Data/Models/ProductModel.dart';
import '../../../../Home/presentation/view_model/views/widgets/ImageHome.dart';
import '../../../../Product/presentation/view_model/cart_cubit.dart';
import '../../../../Product/presentation/view_model/favorite_cubit.dart';
import '../../../../Product/presentation/view_model/views/ProductDetailsPage.dart';
import '../filter_products_cubit.dart';
import 'Widgets/FilterBottomSheet.dart';

class CategoryPage extends StatefulWidget {
  final String apiName;
  final String displayName;
  final int categoryId;
  const CategoryPage({
    super.key,
    required this.apiName,
    required this.displayName,
    required this.categoryId,
  });
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _filteredProducts = [];
  CancelToken _cancelToken = CancelToken();
  double _currentMinPrice = 0;
  double _currentMaxPrice = kFilterMaxPrice;
  bool _isFilterActive = false;
  bool _isSearchLoading = false;
  Timer? _searchDebounce;
  final FilterProductsCubit _filterCubit = FilterProductsCubit();
  @override
  void initState() {
    super.initState();
    fetchCategoryProducts();
    context.read<FavoriteCubit>().loadFavorites();
    context.read<CartCubit>().loadCart();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
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
        fetchCategoryProducts(
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
    fetchCategoryProducts(
      minPrice: _currentMinPrice > 0 ? _currentMinPrice : null,
      maxPrice: _currentMaxPrice != kFilterMaxPrice ? _currentMaxPrice : null,
    );
  }

  Future<void> fetchCategoryProducts({
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      if (!mounted) return;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        setState(() {
          _isSearchLoading = true;
          _isLoading = false;
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
        if (!_cancelToken.isCancelled) {
          _cancelToken.cancel('cancelling previous');
        }
      } catch (_) {}
      _cancelToken = CancelToken();
      final Map<String, dynamic> queryParams = {'name': widget.apiName};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      final int minParam = (minPrice ?? _currentMinPrice).toInt();
      final int maxParam = (maxPrice ?? _currentMaxPrice).toInt();
      queryParams['min_price'] = minParam;
      queryParams['max_price'] = maxParam;
      final response = await _dio.get(
        'https://toknagah.viking-iceland.online/api/user/products-byCategory',
        queryParameters: queryParams,
        options: Options(headers: headers, validateStatus: (_) => true),
        cancelToken: _cancelToken,
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        try {
          final responseMap = response.data as Map<String, dynamic>;
          final dataMap = responseMap['data'] as Map<String, dynamic>;
          final List<dynamic> productsJson = (dataMap['data'] is List)
              ? dataMap['data'] as List<dynamic>
              : <dynamic>[];
          final products = productsJson
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList();
          if (!mounted) return;
          setState(() {
            _filteredProducts = products;
            _isLoading = false;
            _isSearchLoading = false;
            _hasError = false;
            _isFilterActive =
                (searchQuery != null && searchQuery.isNotEmpty) ||
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
            _filteredProducts = [];
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
    await fetchCategoryProducts(
      searchQuery: _searchController.text.isNotEmpty
          ? _searchController.text
          : null,
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
      _currentMaxPrice =
          filters['max_price'] ?? filters['maxPrice'] ?? kFilterMaxPrice;
    });
    final searchQuery = _searchController.text.isNotEmpty
        ? _searchController.text
        : null;
    fetchCategoryProducts(
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
    fetchCategoryProducts();
  }

  void _goToDetails(int id, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetails(productId: id, initialProductData: data),
      ),
    );
  }

  Widget _buildShimmer(double screenWidth) {
    final cardWidth = (screenWidth - 48) / 2;
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cardWidth * 0.05),
          ),
        ),
      ),
    );
  }

  Widget buildSearchFilterBar(double screenWidth) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: screenWidth * 0.04),
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
                          textDirection:
                              Directionality.of(context) == TextDirection.rtl
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
                            hintTextDirection:
                                Directionality.of(context) == TextDirection.rtl
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

  Widget buildCard(
    ProductModel product,
    bool isFav,
    bool isAdded,
    double screenWidth,
  ) {
    final cardWidth = (screenWidth - 48) / 2;
    final cardHeight = cardWidth * 1.4;
    final productMap = product.toMap()
      ..['images'] = ImageHome.processImageList(product.images);
    final price = product.priceAfterDiscount > 0
        ? product.priceAfterDiscount
        : product.price;
    final currency = product.currencyType?.isNotEmpty == true
        ? product.currencyType!
        : S.of(context).SYP;
    return GestureDetector(
      onTap: () => _goToDetails(product.id, productMap),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(51),
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
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(cardWidth * 0.05),
                ),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.images.isNotEmpty
                          ? ImageHome.getValidImageUrl(product.images.first)
                          : '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xffFF580E),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade400,
                            size: cardWidth * 0.15,
                          ),
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
                    ),
                    Positioned(
                      top: cardWidth * 0.05,
                      left: cardWidth * 0.05,
                      child: GestureDetector(
                        onTap: () => context
                            .read<FavoriteCubit>()
                            .toggleFavoriteWithApi(product.id),
                        child: Container(
                          padding: EdgeInsets.all(cardWidth * 0.03),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav
                                ? const Color(0xffFF580E)
                                : Colors.white,
                            size: cardWidth * 0.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(cardWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        product.name,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: cardHeight * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: cardHeight * 0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        product.description,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: cardHeight * 0.045,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: cardHeight * 0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${price.toString()} $currency",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: cardHeight * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xffFF580E),
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => context
                          .read<CartCubit>()
                          .toggleCartWithApi(product.id, productMap),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdded
                            ? const Color.fromRGBO(128, 128, 128, 0.3)
                            : const Color(0xffFF580E),
                        minimumSize: Size(double.infinity, cardHeight * 0.14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cardWidth * 0.15),
                        ),
                      ),
                      child: Text(
                        isAdded
                            ? S.of(context).addedToCart
                            : S.of(context).AddtoCart,
                        style: TextStyle(
                          fontSize: cardHeight * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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

  Widget buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "Assets/magnifying-glass.png",
            width: screenWidth * 0.5,
            height: screenWidth * 0.5,
            fit: BoxFit.contain,
          ),
          SizedBox(height: screenHeight * 0.04),
          Text(
            _searchController.text.isNotEmpty || _isFilterActive
                ? S.of(context).noResultsToShow
                : S.of(context).noAdsYet,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
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
    final textDirection = Directionality.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: CustomAppBar(title: widget.displayName),
        backgroundColor: Colors.grey[100],
        body: Directionality(
          textDirection: textDirection,
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.02),
              buildSearchFilterBar(screenWidth),
              SizedBox(height: screenHeight * 0.02),
              if (_isFilterActive || _searchController.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${S.of(context).filteredResults}: ${_filteredProducts.length}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: KprimaryColor,
                        ),
                      ),
                      if ((_isFilterActive ||
                              _searchController.text.isNotEmpty) &&
                          _filteredProducts.isNotEmpty)
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
                    color: KprimaryColor,
                    onRefresh: _onRefresh,
                    child: _isLoading
                        ? _buildShimmer(screenWidth)
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.03,
                                  ),
                                  child: Text(
                                    _errorMessage.isNotEmpty
                                        ? _errorMessage
                                        : S.of(context).connectionTimeout,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                ElevatedButton(
                                  onPressed: () => fetchCategoryProducts(
                                    searchQuery:
                                        _searchController.text.isNotEmpty
                                        ? _searchController.text
                                        : null,
                                    minPrice: _currentMinPrice > 0
                                        ? _currentMinPrice
                                        : null,
                                    maxPrice:
                                        _currentMaxPrice != kFilterMaxPrice
                                        ? _currentMaxPrice
                                        : null,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: KprimaryColor,
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
                        : _filteredProducts.isEmpty
                        ? buildEmptyState()
                        : BlocBuilder<FavoriteCubit, Set<int>>(
                            builder: (context, favoriteIds) {
                              return BlocBuilder<CartCubit, CartState>(
                                builder: (context, cartState) {
                                  return GridView.builder(
                                    controller: _scrollController,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 16,
                                          childAspectRatio: 0.65,
                                        ),
                                    itemCount: _filteredProducts.length,
                                    itemBuilder: (context, index) {
                                      final product = _filteredProducts[index];
                                      final isFav = favoriteIds.contains(
                                        product.id,
                                      );
                                      final isAdded = cartState.cartIds
                                          .contains(product.id);
                                      return buildCard(
                                        product,
                                        isFav,
                                        isAdded,
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
        ),
      ),
    );
  }
}

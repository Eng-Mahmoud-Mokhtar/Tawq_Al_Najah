import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';
import 'package:tawqalnajah/Feature/Buyer/Product/presentation/view_model/views/ProductDetailsPage.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../Core/Widgets/buildImageError.dart';
import '../../../../Categories/presentation/view_model/filter_products_cubit.dart';
import '../../../../Home/presentation/view_model/views/HomeStructure.dart';
import '../../../../Home/presentation/view_model/views/widgets/ImageHome.dart';
import '../../../../Product/Data/Models/ProductModel.dart';
import '../../../../Product/presentation/view_model/cart_cubit.dart';
import '../../../../Product/presentation/view_model/favorite_cubit.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<ProductModel> _displayedProducts = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isSearchLoading = false;
  bool _isFilterActive = false;
  final ScrollController _gridViewController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  CancelToken _cancelToken = CancelToken();
  Timer? _searchDebounce;
  double _currentMinPrice = 0;
  double _currentMaxPrice = kFilterMaxPrice;
  String? _selectedCategory;
  List<Map<String, dynamic>> _searchHistory = [];
  final FilterProductsCubit _filterCubit = FilterProductsCubit();
  late List<Map<String, String>> _categories;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await context.read<FavoriteCubit>().loadFavorites();
    await context.read<CartCubit>().loadCart();
    _searchController.addListener(_onSearchChanged);
    await _fetchProducts();
    _loadLocalSearchHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCategories();
  }

  void _initializeCategories() {
    _categories = [
      {
        'apiName': 'other',
        'displayName': S.of(context).marketplace,
      },
      {
        'apiName': 'electronics',
        'displayName': S.of(context).electronics,
      },
      {
        'apiName': 'fashion',
        'displayName': S.of(context).fashion,
      },
      {
        'apiName': 'furniture',
        'displayName': S.of(context).furniture,
      },
      {'apiName': 'toys', 'displayName': S.of(context).toys},
      {
        'apiName': 'kitchen',
        'displayName': S.of(context).kitchen,
      },
      {
        'apiName': 'health',
        'displayName': S.of(context).health,
      },
      {
        'apiName': 'books',
        'displayName': S.of(context).books,
      },
    ];
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
          category: _selectedCategory,
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
      category: _selectedCategory,
      minPrice: _currentMinPrice > 0 ? _currentMinPrice : null,
      maxPrice: _currentMaxPrice != kFilterMaxPrice ? _currentMaxPrice : null,
    );
  }

  void _loadLocalSearchHistory() {
    setState(() {
      _searchHistory = [];
    });
  }

  void _addToLocalSearchHistory(String query) {
    if (query.isEmpty || query.length < 2) return;

    final now = DateTime.now();
    final recentThreshold = now.subtract(const Duration(minutes: 1));

    bool isRecentlyAdded = _searchHistory.any((item) {
      if (item['query'] == query) {
        try {
          final dateStr = item['date'];
          if (dateStr != null) {
            final itemDate = DateTime.parse(dateStr);
            return itemDate.isAfter(recentThreshold);
          }
        } catch (e) {
          return false;
        }
      }
      return false;
    });

    if (isRecentlyAdded) {
      return;
    }

    setState(() {
      _searchHistory.insert(0, {
        'id': DateTime.now().millisecondsSinceEpoch,
        'query': query,
        'date': DateTime.now().toIso8601String(),
      });

      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });
  }

  void _deleteLocalSearchHistoryItem(int id) {
    setState(() {
      _searchHistory.removeWhere((item) => item['id'] == id);
    });
  }

  Future<void> _fetchProducts({
    String? searchQuery,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      if (!mounted) return;

      final effectiveMin = minPrice ?? _currentMinPrice;
      final effectiveMax = maxPrice ?? _currentMaxPrice;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        setState(() => _isSearchLoading = true);
        _addToLocalSearchHistory(searchQuery);
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
        if (token != null) 'Authorization': 'Bearer $token',
      };

      try {
        if (!_cancelToken.isCancelled) _cancelToken.cancel('cancelling previous');
      } catch (_) {}
      _cancelToken = CancelToken();

      String apiUrl;
      final Map<String, dynamic> queryParams = {};

      final bool hasCategory = category != null && category.isNotEmpty;

      if (hasCategory) {
        apiUrl =
        'https://toknagah.viking-iceland.online/api/user/products-byCategory';
        queryParams['name'] = category;

        // لو السيرفر بيدعم search هنا تمام
        if (searchQuery != null && searchQuery.isNotEmpty) {
          queryParams['search'] = searchQuery;
        }

        // مهم: لا تبعت min/max هنا (لتجنب خطأ السيرفر)
      } else {
        apiUrl = 'https://toknagah.viking-iceland.online/api/user/products';
        queryParams['type'] = 'ads';

        if (searchQuery != null && searchQuery.isNotEmpty) {
          queryParams['search'] = searchQuery;
        }

        // هنا السيرفر غالبًا يدعم السعر
        queryParams['min_price'] = effectiveMin.toInt();
        queryParams['max_price'] = effectiveMax.toInt();
      }

      final response = await _dio.get(
        apiUrl,
        queryParameters: queryParams,
        options: Options(headers: headers, validateStatus: (_) => true),
        cancelToken: _cancelToken,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseMap = response.data as Map<String, dynamic>;
        final data = responseMap['data'];

        List<dynamic> productsJson;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is List) {
            productsJson = data['data'] as List<dynamic>;
          } else if (data.values.isNotEmpty && data.values.first is List) {
            productsJson = data.values.first as List<dynamic>;
          } else {
            productsJson = [];
          }
        } else if (data is List) {
          productsJson = data;
        } else {
          productsJson = [];
        }

        var products = productsJson
            .map((e) {
          try {
            return ProductModel.fromJson(e as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
            .where((p) => p != null)
            .cast<ProductModel>()
            .toList();

        // فلترة السعر محليًا عندما يكون Category مفعّل
        if (hasCategory) {
          final double minF = effectiveMin;
          final double maxF = effectiveMax;

          products = products.where((p) {
            final price =
            (p.priceAfterDiscount > 0) ? p.priceAfterDiscount : p.price;

            final okMin = (minF <= 0) ? true : price >= minF;
            final okMax = (maxF == kFilterMaxPrice) ? true : price <= maxF;

            return okMin && okMax;
          }).toList();
        }

        if (!mounted) return;

        setState(() {
          _displayedProducts = products;
          _isLoading = false;
          _isSearchLoading = false;
          _hasError = false;

          _isFilterActive = (searchQuery != null && searchQuery.isNotEmpty) ||
              hasCategory ||
              (effectiveMin > 0) ||
              (effectiveMax != kFilterMaxPrice);

          if (category != null) _selectedCategory = category;
          _currentMinPrice = effectiveMin;
          _currentMaxPrice = effectiveMax;

          _filterCubit.updateFilters(
            minPrice: _currentMinPrice,
            maxPrice: _currentMaxPrice,
          );
        });
      } else {
        setState(() {
          _isLoading = false;
          _isSearchLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) return;
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSearchLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _fetchProducts(
      searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
      category: _selectedCategory,
      minPrice: _currentMinPrice > 0 ? _currentMinPrice : null,
      maxPrice: _currentMaxPrice != kFilterMaxPrice ? _currentMaxPrice : null,
    );
    _loadLocalSearchHistory();
  }

  void _showFilterBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String? tempSelectedCategory = _selectedCategory;
    double tempCurrentMinPrice = _currentMinPrice;
    double tempCurrentMaxPrice = _currentMaxPrice;

    showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(screenWidth * 0.03),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune, color: KprimaryColor, size: screenWidth * 0.05),
                            SizedBox(width: screenWidth * 0.015),
                            Text(
                              S.of(context).filterProducts,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: KprimaryText,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close_rounded, size: screenWidth * 0.06, color: Colors.black),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    if (_categories.isNotEmpty) ...[
                      Text(
                        S.of(context).categories,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffE9E9E9)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String?>(
                                  dropdownColor: Colors.white,
                                  elevation: 4,
                                  value: tempSelectedCategory,
                                  isExpanded: true,
                                  hint: Text(
                                    S.of(context).selectCategory,
                                    style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                  icon: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                    child: Icon(Icons.keyboard_arrow_down, size: screenWidth * 0.05, color: Colors.grey),
                                  ),
                                  items: [
                                    DropdownMenuItem<String?>(
                                      value: null,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                        child: Text(S.of(context).all,style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black, fontWeight: FontWeight.bold),),
                                      ),
                                    ),
                                    ..._categories.map((cat) => DropdownMenuItem<String?>(
                                      value: cat['apiName'],
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                                        child: Text(cat['displayName'] ?? '',style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black, fontWeight: FontWeight.bold),),
                                      ),
                                    )),
                                  ],
                                  onChanged: (String? value) {
                                    setState(() {
                                      tempSelectedCategory = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            if (tempSelectedCategory != null) SizedBox(width: screenWidth * 0.02),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      S.of(context).priceRange,
                      style: TextStyle(
                        color: KprimaryText,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RangeSlider(
                      min: 0,
                      max: kFilterMaxPrice,
                      divisions: (kFilterMaxPrice / 100).toInt().clamp(1, 10000),
                      labels: RangeLabels(
                        tempCurrentMinPrice.round().toString(),
                        tempCurrentMaxPrice.round().toString(),
                      ),
                      values: RangeValues(tempCurrentMinPrice, tempCurrentMaxPrice),
                      onChanged: (RangeValues values) {
                        setState(() {
                          tempCurrentMinPrice = values.start;
                          tempCurrentMaxPrice = values.end;
                        });
                      },
                      activeColor: KprimaryColor,
                      inactiveColor: Colors.grey[300],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${tempCurrentMinPrice.round()}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${tempCurrentMaxPrice.round()}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    SizedBox(
                      height: screenWidth * 0.12,
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: KprimaryColor,
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context, {
                              'category': tempSelectedCategory,
                              'minPrice': tempCurrentMinPrice,
                              'maxPrice': tempCurrentMaxPrice,
                            });
                          },
                          child: Text(
                            S.of(context).applyFilters,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((filters) {
      if (filters != null) {
        _handleFilterApply(filters);
      }
    });
  }

  void _handleFilterApply(Map<String, dynamic> filters) {
    if (!mounted) return;

    setState(() {
      _currentMinPrice = filters['minPrice'] ?? 0;
      _currentMaxPrice = filters['maxPrice'] ?? kFilterMaxPrice;
      _selectedCategory = filters['category'];
    });

    final searchQuery = _searchController.text.isNotEmpty ? _searchController.text : null;

    _fetchProducts(
      searchQuery: searchQuery,
      category: _selectedCategory,
      minPrice: _currentMinPrice > 0 ? _currentMinPrice : null,
      maxPrice: (_currentMaxPrice != kFilterMaxPrice && _currentMaxPrice > 0)
          ? _currentMaxPrice
          : null,
    );
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _selectedCategory = null;
      _currentMinPrice = 0;
      _currentMaxPrice = kFilterMaxPrice;
      _isFilterActive = false;
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

  Widget _buildSearchHistorySection(double screenWidth) {
    if (_searchHistory.isEmpty) {
      return Container();
    }
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).recentSearches,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          SizedBox(
            height: screenWidth * 0.12,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _searchHistory.length,
              separatorBuilder: (context, index) => SizedBox(width: screenWidth * 0.02),
              itemBuilder: (context, index) {
                final item = _searchHistory[index];
                return Container(
                  decoration: BoxDecoration(
                    color: KprimaryColor.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _searchController.text = item['query'];
                            _onSearchChanged();
                          },
                          child: Text(
                            item['query'],
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        GestureDetector(
                          onTap: () {
                            _deleteLocalSearchHistoryItem(item['id']);
                          },
                          child: Icon(
                            Icons.close,
                            size: screenWidth * 0.03,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
          IconButton(
            onPressed: () {
              context.read<BottomNavBCubit>().setIndex(0);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: screenWidth * 0.05,
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
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
                          Center(
                            child: Container(
                              width: screenWidth * 0.05,
                              height: screenWidth * 0.05,
                              padding: EdgeInsets.all(screenWidth * 0.01),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  KprimaryColor,
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
                        style: TextStyle(
                          fontSize: cardHeight * 0.045,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
      return buildImageErrorPlaceholder( context,cardWidth, cardHeight);
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
            child: Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: cardWidth * 0.3,
                  height: cardWidth * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(cardWidth * 0.15),
                  ),
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => buildImageErrorPlaceholder( context,cardWidth, cardHeight),
        ),
        Positioned(
          top: cardWidth * 0.05,
          left: cardWidth * 0.05,
          child: GestureDetector(
            onTap: () => context.read<FavoriteCubit>().toggleFavoriteWithApi(productId),
            child: Container(
              padding: EdgeInsets.all(cardWidth * 0.03),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withAlpha((0.5 * 255).round()),
              ),
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


  Widget _buildShimmerLoading(double screenWidth, double screenHeight) {
    final cardWidth = (screenWidth - 48) / 2;
    final cardHeight = cardWidth * 1.4;

    return GridView.builder(
      controller: _gridViewController,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(cardWidth * 0.05),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.all(cardWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: cardWidth * 0.7,
                          height: cardHeight * 0.04,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: cardHeight * 0.01),
                        Container(
                          width: cardWidth * 0.5,
                          height: cardHeight * 0.03,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: cardHeight * 0.01),
                        Container(
                          width: cardWidth * 0.4,
                          height: cardHeight * 0.04,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          height: cardHeight * 0.14,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(cardWidth * 0.15),
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
      },
    );
  }

  Widget _buildEmptyState(double screenWidth, double screenHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "Assets/magnifying-glass.png",
          width: screenWidth * 0.4,
          height: screenWidth * 0.4,
          fit: BoxFit.contain,
        ),
        SizedBox(height: screenHeight * 0.02),
        Text(
          S.of(context).NoResultstoShow,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(double screenWidth, double screenHeight) {
    return Center(
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
              S.of(context).connectionTimeout,
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
              category: _selectedCategory,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.05),
          _buildSearchFilterBar(screenWidth),
          _buildSearchHistorySection(screenWidth),
          SizedBox(height: screenHeight * 0.02),
          if (_isFilterActive || _searchController.text.isNotEmpty || _selectedCategory != null)
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
                  if ((_isFilterActive || _searchController.text.isNotEmpty || _selectedCategory != null) && _displayedProducts.isNotEmpty)
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
                    ? _buildErrorState(screenWidth, screenHeight)
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

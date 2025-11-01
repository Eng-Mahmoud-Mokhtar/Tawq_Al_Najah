import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tawqalnajah/Feature/Buyer/Search/presentation/view_model/views/widgets/FilterBottomSheet.dart';
import 'package:tawqalnajah/Feature/Buyer/Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../Home/presentation/view_model/views/HomeStructure.dart';
import '../filter_cubit.dart';
import '../../../../Product/presentation/view_model/views/widgets/getAdsData.dart';
import '../../../../Product/presentation/view_model/views/widgets/AdCard.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2)); // محاكاة التحميل
    setState(() {
      _filteredProducts = DataProvider.getAdsData();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _applyFilters(FilterState filterState) {
    var products = DataProvider.getAdsData();

    if (_searchQuery.isNotEmpty) {
      products = products.where((product) {
        return product['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
            product['category']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (filterState.category != null) {
      products = products
          .where((product) => product['category'] == filterState.category)
          .toList();
    }

    if (filterState.country != null) {
      products = products
          .where((product) => product['country'] == filterState.country)
          .toList();
    }

    products = products.where((product) {
      final price = (product['price'] as num).toDouble();
      return price >= filterState.minPrice && price <= filterState.maxPrice;
    }).toList();

    final sortOrder = filterState.sortOrder.toLowerCase();
    if (sortOrder.contains('lowest') || sortOrder.contains('أقل')) {
      products.sort((a, b) => a['price'].compareTo(b['price']));
    } else if (sortOrder.contains('highest') || sortOrder.contains('أعلى')) {
      products.sort((a, b) => b['price'].compareTo(a['price']));
    }

    return products;
  }

  void _showFilterBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      builder: (context) {
        return FilterBottomSheet(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        );
      },
    );
  }

  Widget _buildShimmer(double screenWidth) {
    return GridView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: screenWidth * 0.04,
        crossAxisSpacing: screenWidth * 0.04,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة المنتج الوهمية
                Container(
                  height: screenWidth * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(screenWidth * 0.03),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // اسم المنتج
                      Container(
                        height: screenWidth * 0.03,
                        width: screenWidth * 0.25,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      // السعر
                      Container(
                        height: screenWidth * 0.025,
                        width: screenWidth * 0.15,
                        color: Colors.grey.shade300,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<FilterCubit, FilterState>(
      builder: (context, filterState) {
        _filteredProducts = _applyFilters(filterState);

        return Scaffold(
          backgroundColor: const Color(0xfffafafa),
          body: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              children: [
                SizedBox(height: screenWidth * 0.06),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: KprimaryText,
                        size: screenWidth * 0.05,
                      ),
                      onPressed: () {
                        context.read<BottomNavBCubit>().setIndex(0);
                      },
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
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: screenWidth * 0.035),
                            Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: screenWidth * 0.06,
                            ),
                            SizedBox(width: screenWidth * 0.035),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: S.of(context).search,
                                  hintStyle: TextStyle(
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.035,
                                  ),
                                ),
                              ),
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
                              color: Colors.grey.withOpacity(0.2),
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
                Expanded(
                  child: _isLoading
                      ? _buildShimmer(screenWidth)
                      : _filteredProducts.isEmpty
                      ? Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'Assets/magnifying-glass.png',
                            width: screenWidth * 0.5,
                            height: screenWidth * 0.5,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            S.of(context).NoResultstoShow,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.15),
                        ],
                      ),
                    ),
                  )
                      : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: screenWidth * 0.04,
                      crossAxisSpacing: screenWidth * 0.04,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return AdCard(
                        ad: _filteredProducts[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(
                                ad: _filteredProducts[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

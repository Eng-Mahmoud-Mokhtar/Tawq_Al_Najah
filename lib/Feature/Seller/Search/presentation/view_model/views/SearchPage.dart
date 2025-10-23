import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tawqalnajah/Feature/Seller/Search/presentation/view_model/views/widgets/FilterBottomSheet.dart';
import 'package:tawqalnajah/Feature/Seller/Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../filter_cubit.dart';
import '../../../../Home/presentation/view_model/views/HomeStructure.dart';
import '../../../../Product/presentation/view_model/views/widgets/getAdsData.dart';
import '../../../../cart/presentation/view_model/views/widgets/AdCard.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = DataProvider.getAdsData();
    print(
      'SearchPage initialized with ${_filteredProducts.length} products',
    ); // Debug
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        print('Search query updated: $_searchQuery');
      });
    });
  }

  List<Map<String, dynamic>> _applyFilters(FilterState filterState) {
    var products = DataProvider.getAdsData();
    print('Initial products count: ${products.length}');
    if (_searchQuery.isNotEmpty) {
      products = products.where((product) {
        return product['name'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            product['category'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
      print('After search filter: ${products.length} products');
    }

    // Apply category filter
    if (filterState.category != null) {
      print('Filtering by category: "${filterState.category}"');
      products = products
          .where((product) => product['category'] == filterState.category)
          .toList();
      print('After category filter: ${products.length} products');
    } else {
      print('No category filter applied (category is null)');
    }

    // Apply country filter
    if (filterState.country != null) {
      print('Filtering by country: "${filterState.country}"');
      products = products
          .where((product) => product['country'] == filterState.country)
          .toList();
      print('After country filter: ${products.length} products');
    } else {
      print('No country filter applied (country is null)');
    }

    // Apply price range filter
    products = products.where((product) {
      final price = (product['price'] as num).toDouble();
      bool withinRange =
          price >= filterState.minPrice && price <= filterState.maxPrice;
      print(
        'Product: ${product['name']}, Price: $price, Within range: $withinRange',
      ); // Debug
      return withinRange;
    }).toList();
    print('After price filter: ${products.length} products');

    // Apply sorting
    final sortOrder = filterState.sortOrder.toLowerCase();
    if (sortOrder.contains('lowest') || sortOrder.contains('أقل')) {
      products.sort((a, b) => a['price'].compareTo(b['price']));
      print('Sorted by lowest price');
    } else if (sortOrder.contains('highest') || sortOrder.contains('أعلى')) {
      products.sort((a, b) => b['price'].compareTo(a['price']));
      print('Sorted by highest price');
    }

    print('Final filtered products count: ${products.length}');
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
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: KprimaryText),
              onPressed: () {
                context.read<BottomNavCubit>().setIndex(0);
              },
            ),
            title: Container(
              height: screenHeight * 0.06,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: S.of(context).search,
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: screenWidth * 0.05,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.015,
                  ),
                ),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => _showFilterBottomSheet(context),
                child: Container(
                  height: screenHeight * 0.06,
                  width: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: KprimaryColor,
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
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
              SizedBox(width: screenWidth * 0.04),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: _filteredProducts.isEmpty
                ? Center(
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
                  )
                : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: screenWidth * 0.04,
                      crossAxisSpacing: screenWidth * 0.04,
                      childAspectRatio: 0.53,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      return AdCard(
                        ad: _filteredProducts[index],
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
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
        );
      },
    );
  }
}

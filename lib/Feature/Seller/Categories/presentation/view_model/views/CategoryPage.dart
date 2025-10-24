import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tawqalnajah/Feature/Seller/Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import 'package:tawqalnajah/Feature/Seller/Product/presentation/view_model/views/widgets/getAdsData.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../cart/presentation/view_model/views/widgets/AdCard.dart';

class CategoryPage extends StatefulWidget {
  final String category;

  const CategoryPage({super.key, required this.category});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  String _searchQuery = '';
  String _selectedLocation = '';
  double _minPrice = 0;
  double _maxPrice = 100000;
  List<String> locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // محاكاة تحميل البيانات

    String categoryArabic = widget.category;
    final Map<String, String> categoryMap = {
      'all': 'الجميع',
      'electronics': 'الكترونيات',
      'fashion': 'أزياء',
      'cars': 'ألعاب',
      'real estate': 'عقارات',
      'services': 'خدمات',
      'kitchen': 'مطبخ',
      'food': 'مطبخ',
      'toys': 'ألعاب',
    };

    categoryArabic =
        categoryMap[widget.category.toLowerCase()] ?? widget.category;

    _products = DataProvider.getAdsByCategory(categoryArabic);
    _filteredProducts = _products;
    setState(() => _isLoading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    locations = [
      S.of(context).all,
      'مصر',
      'ليبيا',
      'الاردن',
      'الرياض',
    ];
    if (_selectedLocation.isEmpty) {
      _selectedLocation = S.of(context).all;
    }
    _filterProducts();
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((ad) {
        bool matchesSearch = _searchQuery.isEmpty ||
            ad['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (ad['description']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        bool matchesLocation = _selectedLocation == S.of(context).all ||
            (ad['location']?.toString().toLowerCase().contains(_selectedLocation.toLowerCase()) ?? false);

        String priceStr = ad['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '');
        double price = double.tryParse(priceStr) ?? 0.0;
        bool matchesPrice = price >= _minPrice && price <= _maxPrice;

        return matchesSearch && matchesLocation && matchesPrice;
      }).toList();
    });
  }

  void _showFilterBottomSheet() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String tempLocation = _selectedLocation;
    double tempMinPrice = _minPrice;
    double tempMaxPrice = _maxPrice;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.02)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, vertical: screenHeight * 0.03),
              height: screenHeight * 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune, color: KprimaryColor, size: screenWidth * 0.05),
                          SizedBox(width: screenWidth * 0.015),
                          Text(
                            S.of(context).filter,
                            style: TextStyle(
                                fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close_rounded,
                            size: screenWidth * 0.05, color: Colors.black),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildLabel(S.of(context).location, screenWidth),
                  _buildStyledDropdown(
                    items: locations,
                    value: tempLocation,
                    onChanged: (val) => setModalState(() => tempLocation = val!),
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildLabel(S.of(context).priceRange, screenWidth),
                  RangeSlider(
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    labels: RangeLabels(
                        tempMinPrice.round().toString(), tempMaxPrice.round().toString()),
                    values: RangeValues(tempMinPrice, tempMaxPrice),
                    onChanged: (RangeValues values) {
                      setModalState(() {
                        tempMinPrice = values.start;
                        tempMaxPrice = values.end;
                      });
                    },
                    activeColor: KprimaryColor,
                    inactiveColor: Colors.grey[300],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: screenWidth * 0.12,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedLocation = tempLocation;
                          _minPrice = tempMinPrice;
                          _maxPrice = tempMaxPrice;
                        });
                        _filterProducts();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KprimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                      ),
                      child: Text(
                        S.of(context).applyFilters,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLabel(String text, double screenWidth) {
    return Text(
      text,
      style: TextStyle(
          color: Colors.black, fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStyledDropdown({
    required List<String> items,
    required Function(String?) onChanged,
    required String value,
    required double screenWidth,
  }) {
    return SizedBox(
      height: screenWidth * 0.12,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xffFAFAFA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xffE9E9E9)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Colors.white,
            value: value,
            isExpanded: true,
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black87),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  // 🔹 الـ Shimmer Effect
  Widget _buildShimmerGrid(double screenWidth) {
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
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: widget.category),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
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
                            autofocus: true,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: "${S.of(context).search} ${widget.category}",
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
                            onChanged: (value) {
                              _searchQuery = value;
                              _filterProducts();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                GestureDetector(
                  onTap: _showFilterBottomSheet,
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
                    child: Icon(Icons.tune, color: Colors.white, size: screenWidth * 0.05),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildShimmerGrid(screenWidth)
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
              padding: EdgeInsets.all(screenWidth * 0.04),
              itemCount: _filteredProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: screenWidth * 0.04,
                crossAxisSpacing: screenWidth * 0.04,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (_, index) {
                return AdCard(
                  ad: _filteredProducts[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsPage(ad: _filteredProducts[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

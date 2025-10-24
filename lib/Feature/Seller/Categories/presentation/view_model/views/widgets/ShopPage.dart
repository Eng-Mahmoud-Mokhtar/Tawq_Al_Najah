import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tawqalnajah/Feature/Seller/Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import '../../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../cart/presentation/view_model/views/widgets/AdCard.dart';

class ShopPage extends StatefulWidget {
  final Map<String, dynamic> store;
  const ShopPage({super.key, required this.store});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // محاكاة تحميل البيانات
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _products = widget.store['ads'] as List<Map<String, dynamic>>;
        _filteredProducts = _products;
        _isLoading = false;
      });
    });
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((ad) {
        return ad['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
            ad['description']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  Widget _buildShimmer(double screenWidth, double screenHeight) {
    return GridView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: 6, // عدد العناصر الوهمية
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
      appBar: CustomAppBar(title: "${S.of(context).store} ${widget.store['name']}"),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
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
          Expanded(
            child: _isLoading
                ? _buildShimmer(screenWidth, screenHeight)
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
                        builder: (_) => ProductDetailsPage(
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
    );
  }
}

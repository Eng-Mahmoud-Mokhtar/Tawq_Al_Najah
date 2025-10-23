import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _products = widget.store['ads'] as List<Map<String, dynamic>>;
    _filteredProducts = _products;
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((ad) {
        return ad['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ad['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    });
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
              height: screenHeight * 0.06,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
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
                  SizedBox(width: screenWidth * 0.03),
                  Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: screenWidth * 0.06,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: S.of(context).search,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: screenWidth * 0.035,
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
            child: _filteredProducts.isEmpty
                ? Column(
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
                  ),
                ),
              ],
            )
                : GridView.builder(
              padding: EdgeInsets.all(screenWidth * 0.04),
              itemCount: _filteredProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: screenWidth * 0.04,
                crossAxisSpacing: screenWidth * 0.04,
                childAspectRatio: 0.53,
              ),
              itemBuilder: (_, index) {
                return AdCard(
                  ad: _filteredProducts[index],
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
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
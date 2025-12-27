import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tawqalnajah/Feature/Seller/RelatedProuducts/presentation/view_model/views/widgets/FilterRelated.dart';
import 'package:tawqalnajah/Feature/Seller/RelatedProuducts/presentation/view_model/FilterRelated_cubit.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'ProductDetailsPage.dart';

class RelatedPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  const RelatedPage({super.key, required this.items});

  @override
  State<RelatedPage> createState() => _RelatedPageState();
}

class _RelatedPageState extends State<RelatedPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Simulate loading for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _filteredItems = widget.items;
      });
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _applyFilters(context.read<FilterRelatedCubit>().state);
      });
    });
  }

  void _applyFilters(FilterState filterRelatedState) {
    var items = widget.items;

    // Search by name
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by country
    if (filterRelatedState.country != null &&
        filterRelatedState.country != S.of(context).all) {
      items = items
          .where((item) => item['country'] == filterRelatedState.country)
          .toList();
    }

    // ✅ Filter by price range
    items = items.where((item) {
      final price = (item['price'] is num)
          ? item['price'].toDouble()
          : double.tryParse(item['price'].toString()) ?? 0.0;
      return price >= filterRelatedState.minPrice &&
          price <= filterRelatedState.maxPrice;
    }).toList();

    setState(() {
      _filteredItems = items;
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(screenWidth * 0.05)),
      ),
      builder: (_) =>
          FilterRelated(screenWidth: screenWidth, screenHeight: screenHeight),
    ).then((_) {
      _applyFilters(context.read<FilterRelatedCubit>().state);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildShimmerGrid(double screenWidth) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: screenWidth * 0.04,
        crossAxisSpacing: screenWidth * 0.04,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
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
      appBar: CustomAppBar(title:S.of(context).relatedItems),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            // Search + Filter Row
            Row(
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
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(horizontal:screenWidth * 0.02),
                          child: Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: screenWidth * 0.06,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.035,
                          horizontal: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                InkWell(
                  onTap: () => _showFilterBottomSheet(context),
                  child: Container(
                    height: screenWidth * 0.12,
                    width: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      color: KprimaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: screenWidth * 0.06,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),

            Expanded(
              child: _isLoading
                  ? _buildShimmerGrid(screenWidth)
                  : _filteredItems.isEmpty
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
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetails(ad: item),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(screenWidth * 0.03),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft:
                              Radius.circular(screenWidth * 0.03),
                              topRight:
                              Radius.circular(screenWidth * 0.03),
                            ),
                            child: Image.asset(
                              item['images'][0],
                              width: double.infinity,
                              height: screenWidth * 0.4,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.025),
                            child: Directionality(
                              textDirection: TextDirection.rtl, // ← اتجاه ثابت RTL دائمًا
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // مهم: start مع Directionality.rtl يجعل كل النصوص على اليمين
                                children: [
                                  Align(
                                    alignment: Alignment.centerRight, // يثبت النص على يمين الكونتينر
                                    child: Text(
                                      item['name'],
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      item['description'],
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${item['price']} ${item['currency']}",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: screenWidth * 0.035,
                                        color: const Color(0xffFF580E),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
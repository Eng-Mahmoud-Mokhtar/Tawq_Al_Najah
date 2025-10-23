import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import 'package:tawqalnajah/Feature/Seller/Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../Search/presentation/view_model/filter_cubit.dart';
import '../../../../Search/presentation/view_model/views/widgets/FilterBottomSheet.dart';
import '../../../../cart/presentation/view_model/views/widgets/AdCard.dart';

class SuggestionsPage extends StatefulWidget {
  final List<Map<String, dynamic>> ads;
  const SuggestionsPage({super.key, required this.ads});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredAds = [];

  @override
  void initState() {
    super.initState();
    _filteredAds = widget.ads;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _applyFilters(context.read<FilterCubit>().state);
      });
    });
  }

  void _applyFilters(FilterState filterState) {
    var ads = widget.ads;

    // ✅ Search by name or category
    if (_searchQuery.isNotEmpty) {
      ads = ads.where((ad) {
        return ad['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ad['category'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // ✅ Filter by category
    if (filterState.category != null &&
        filterState.category != S.of(context).all) {
      ads = ads.where((ad) => ad['category'] == filterState.category).toList();
    }

    // ✅ Filter by country
    if (filterState.country != null &&
        filterState.country != S.of(context).all) {
      ads = ads.where((ad) => ad['country'] == filterState.country).toList();
    }

    setState(() {
      _filteredAds = ads;
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
          FilterBottomSheet(screenWidth: screenWidth, screenHeight: screenHeight),
    ).then((_) {
      _applyFilters(context.read<FilterCubit>().state);
    });
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

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).suggestions), // "الاقتراحات"
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            // ✅ Search + Filter Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xffE9E9E9)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: S.of(context).search,
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.035,
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey, size: screenWidth * 0.05),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: screenHeight * 0.015),
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
                    child: Icon(Icons.tune,
                        color: Colors.white, size: screenWidth * 0.06),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),

            Expanded(
              child: _filteredAds.isEmpty
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
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: screenWidth * 0.04,
                  crossAxisSpacing: screenWidth * 0.04,
                  childAspectRatio: 0.53,
                ),
                itemCount: _filteredAds.length,
                itemBuilder: (context, index) {
                  return AdCard(
                    ad: _filteredAds[index],
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsPage(
                              ad: _filteredAds[index]),
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
  }
}

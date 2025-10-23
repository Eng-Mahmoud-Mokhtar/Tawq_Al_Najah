import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tawqalnajah/Feature/Seller/Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../Search/presentation/view_model/filter_cubit.dart';
import '../../../../Search/presentation/view_model/views/widgets/FilterBottomSheet.dart';
import '../../../../cart/presentation/view_model/views/widgets/AdCard.dart';
import '../../../../../../generated/l10n.dart';

class TawqalOffersPage extends StatefulWidget {
  final List<Map<String, dynamic>> ads;

  const TawqalOffersPage({super.key, required this.ads});

  @override
  State<TawqalOffersPage> createState() => _TawqalOffersPageState();
}

class _TawqalOffersPageState extends State<TawqalOffersPage> {
  late TextEditingController searchController;
  late List<Map<String, dynamic>> filteredAds;

  String selectedCategory = 'All';
  String selectedCountry = 'All';
  double minPrice = 0;
  double maxPrice = 100000;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    filteredAds = widget.ads;
  }

  void _applyFilters() {
    setState(() {
      filteredAds = widget.ads.where((ad) {
        final title = (ad['title'] ??
            ad['name'] ??
            ad['adName'] ??
            ad['description'] ??
            '')
            .toString()
            .toLowerCase();

        final country = ad['country']?.toString() ?? 'All';
        final category = ad['category']?.toString() ?? 'All';
        final price = double.tryParse(ad['price'].toString()) ?? 0;

        final searchMatch =
        title.contains(searchController.text.trim().toLowerCase());
        final categoryMatch =
            selectedCategory == 'All' || category == selectedCategory;
        final countryMatch =
            selectedCountry == 'All' || country == selectedCountry;
        final priceMatch = price >= minPrice && price <= maxPrice;

        return searchMatch && categoryMatch && countryMatch && priceMatch;
      }).toList();
    });
  }

  void _openFilterSheet(double screenWidth, double screenHeight) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<FilterCubit>(),
          child: FilterBottomSheet(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
        );
      },
    );

    if (result != null && result is Map) {
      setState(() {
        selectedCategory = result['category'] ?? 'All';
        selectedCountry = result['country'] ?? 'All';
        minPrice = result['minPrice'] ?? 0;
        maxPrice = result['maxPrice'] ?? 100000;
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).tawqalOffers),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.015,
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
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: S.of(context).search,
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.035,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: screenWidth * 0.05,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.03,
                        ),
                      ),
                      onChanged: (value) => _applyFilters(),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                InkWell(
                  onTap: () => _openFilterSheet(screenWidth, screenHeight),
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
          ),
          Expanded(
            child: filteredAds.isEmpty
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
              padding: EdgeInsets.all(screenWidth * 0.04),
              itemCount: filteredAds.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: screenWidth * 0.04,
                crossAxisSpacing: screenWidth * 0.04,
                childAspectRatio: 0.53,
              ),
              itemBuilder: (_, index) {
                return AdCard(
                  ad: filteredAds[index],
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(
                          ad: filteredAds[index],
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

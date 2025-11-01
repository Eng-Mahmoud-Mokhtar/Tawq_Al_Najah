import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tawqalnajah/Feature/Buyer/Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../Search/presentation/view_model/filter_cubit.dart';
import '../../../../Search/presentation/view_model/views/widgets/FilterBottomSheet.dart';
import 'widgets/AdCard.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    filteredAds = [];
    _loadData();
  }

  Future<void> _loadData() async {
    // محاكاة تحميل البيانات
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      filteredAds = widget.ads;
      isLoading = false;
    });
  }

  void _applyFilters() {
    final filterState = context.read<FilterCubit>().state;

    setState(() {
      filteredAds = widget.ads.where((ad) {
        final title = (ad['title'] ?? ad['name'] ?? ad['description'] ?? '')
            .toString()
            .toLowerCase()
            .trim();
        final searchText = searchController.text.toLowerCase().trim();
        final searchMatch = title.contains(searchText);

        final category = ad['category']?.toString().toLowerCase().trim() ?? '';
        final filterCategory =
            filterState.category?.toLowerCase().trim() ?? '';
        final categoryMatch = filterCategory.isEmpty ||
            filterCategory == S.of(context).all.toLowerCase()
            ? true
            : category == filterCategory;

        final country = ad['country']?.toString().toLowerCase().trim() ?? '';
        final filterCountry =
            filterState.country?.toLowerCase().trim() ?? '';
        final countryMatch = filterCountry.isEmpty ||
            filterCountry == S.of(context).all.toLowerCase()
            ? true
            : country == filterCountry;

        return searchMatch && categoryMatch && countryMatch;
      }).toList();
    });
  }

  void _openFilterSheet(double screenWidth, double screenHeight) async {
    await showModalBottomSheet(
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

    _applyFilters();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
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
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: screenWidth * 0.06,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.035,
                          horizontal: screenWidth * 0.035,
                        ),
                      ),
                      onChanged: (_) => _applyFilters(),
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
            child: isLoading
                ? Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: GridView.builder(
                padding: EdgeInsets.all(screenWidth * 0.04),
                itemCount: 6, // عناصر وهمية أثناء التحميل
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: screenWidth * 0.04,
                  crossAxisSpacing: screenWidth * 0.04,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (_, __) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
              ),
            )
                : filteredAds.isEmpty
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
              itemCount: filteredAds.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: screenWidth * 0.04,
                crossAxisSpacing: screenWidth * 0.04,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (_, index) {
                return AdCard(
                  ad: filteredAds[index],
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

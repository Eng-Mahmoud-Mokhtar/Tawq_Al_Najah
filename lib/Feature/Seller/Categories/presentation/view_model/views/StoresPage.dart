import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tawqalnajah/Feature/Seller/Product/presentation/view_model/views/widgets/getAdsData.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import 'widgets/ShopPage.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({super.key});

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  late String selectedCategory;
  late String selectedLocation;
  List<Map<String, dynamic>> filteredStores = [];
  bool _isLoading = true; // ✅ للتحكم في الشيمر

  @override
  void initState() {
    super.initState();
    filteredStores = DataProvider.getStoresData();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
        _applyFilters();
      });
    });

    // ⏳ محاكاة وقت التحميل
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedCategory = S.of(context).all;
    selectedLocation = S.of(context).all;
  }

  void _applyFilters() {
    var stores = DataProvider.getStoresData();

    if (searchQuery.isNotEmpty) {
      stores = stores
          .where((store) => store['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (selectedCategory != S.of(context).all) {
      stores = stores.where((store) {
        final category = store['category']?.toString().trim().toLowerCase() ?? '';
        final selected = selectedCategory.trim().toLowerCase();

        final translations = {
          'clothes': ['clothes', 'ملابس'],
          'electronics': ['electronics', 'الكترونيات', 'إلكترونيات'],
          'furniture': ['furniture', 'اثاث', 'أثاث'],
          'food': ['food', 'طعام', 'مأكولات', 'مطاعم'],
        };

        for (var values in translations.values) {
          if (values.contains(selected)) {
            return values.any((val) => category.contains(val));
          }
        }
        return category.contains(selected);
      }).toList();
    }

    if (selectedLocation != S.of(context).all) {
      stores = stores
          .where((store) => store['address']
          .toString()
          .toLowerCase()
          .contains(selectedLocation.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredStores = stores;
    });
  }

  void _showFilterBottomSheet() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String tempCategory = selectedCategory;
    String tempLocation = selectedLocation;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(screenWidth * 0.02)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.03,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune, color: KprimaryColor, size: screenWidth * 0.04),
                          SizedBox(width: screenWidth * 0.015),
                          Text(
                            S.of(context).filterMerchants,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
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
                  _buildLabel(S.of(context).category, screenWidth),
                  _buildStyledDropdown(
                    items: [
                      S.of(context).all,
                      S.of(context).clothes,
                      S.of(context).electronics,
                      S.of(context).furniture,
                      S.of(context).food,
                    ],
                    value: tempCategory,
                    onChanged: (val) => setModalState(() => tempCategory = val!),
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildLabel(S.of(context).location, screenWidth),
                  _buildStyledDropdown(
                    items: [
                      S.of(context).all,
                      'القاهرة',
                      'الإسكندرية',
                      'الجيزة',
                      'المنصورة',
                    ],
                    value: tempLocation,
                    onChanged: (val) => setModalState(() => tempLocation = val!),
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  SizedBox(
                    width: double.infinity,
                    height: screenWidth * 0.12,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = tempCategory;
                          selectedLocation = tempLocation;
                        });
                        _applyFilters();
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
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
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
        color: Colors.black,
        fontSize: screenWidth * 0.035,
        fontWeight: FontWeight.bold,
      ),
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
            value: value,
            isExpanded: true,
            onChanged: onChanged,
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.black87),
            ),
            dropdownColor: Colors.white,
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
          ),
        ),
      ),
    );
  }

  // ✅ ودجت الشيمر أثناء التحميل
  Widget _buildShimmerLoading(double screenWidth, double screenHeight) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.06,
                backgroundColor: Colors.white,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: screenWidth * 0.4,
                        height: screenWidth * 0.03,
                        color: Colors.white),
                    SizedBox(height: screenHeight * 0.01),
                    Container(
                        width: screenWidth * 0.6,
                        height: screenWidth * 0.025,
                        color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).merchants),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
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
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                InkWell(
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
                    child: Icon(Icons.tune,
                        color: Colors.white, size: screenWidth * 0.06),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: _isLoading
                  ? _buildShimmerLoading(screenWidth, screenHeight)
                  : filteredStores.isEmpty
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
                  : ListView.builder(
                itemCount: filteredStores.length,
                itemBuilder: (_, index) {
                  final store = filteredStores[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShopPage(store: store),
                        ),
                      );
                    },
                    child: Container(
                      margin:
                      EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
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
                          CircleAvatar(
                            radius: screenWidth * 0.06,
                            backgroundColor: const Color(0xffb8b7b7),
                            backgroundImage: AssetImage(store['image']),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store['name'],
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        color: const Color(0xffFF580E),
                                        size: screenWidth * 0.04),
                                    SizedBox(width: screenWidth * 0.01),
                                    Expanded(
                                      child: Text(
                                        store['address'],
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: Colors.grey[700],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

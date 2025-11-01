import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../FilterRelated_cubit.dart';

class FilterRelated extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  const FilterRelated({
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  @override
  State<FilterRelated> createState() => _FilterRelatedState();
}

class _FilterRelatedState extends State<FilterRelated> {
  List<Map<String, String>> countries = [];
  String? tempCountry;
  late double tempMinPrice;
  late double tempMaxPrice;

  bool _initialized = false;

  static const String countryAll = 'all';
  static const Map<String, String> countryIds = {
    countryAll: 'الكل',
    'saudi': 'السعودية',
    'uae': 'الإمارات',
    'egypt': 'مصر',
    'jordan': 'الأردن',
    'lebanon': 'لبنان',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeFilters();
      _initialized = true;
    }
  }

  void _initializeFilters() {
    final filterState = context.read<FilterRelatedCubit>().state;
    tempCountry = filterState.countryId ?? countryAll;
    tempMinPrice = filterState.minPrice;
    tempMaxPrice = filterState.maxPrice;
  }

  void _updateListsBasedOnLocale() {
    countries = [
      {'id': countryAll, 'name': S.of(context).all},
      {'id': 'saudi', 'name': 'السعودية'},
      {'id': 'uae', 'name': 'الإمارات'},
      {'id': 'egypt', 'name': 'مصر'},
      {'id': 'jordan', 'name': 'الأردن'},
      {'id': 'lebanon', 'name': 'لبنان'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    _updateListsBasedOnLocale();

    final selectedCountry = countries.firstWhere(
          (country) => country['id'] == tempCountry,
      orElse: () => countries[0],
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.screenWidth * 0.04,
        vertical: widget.screenHeight * 0.02,
      ),
      constraints: BoxConstraints(
        maxHeight: widget.screenHeight * 0.7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.screenWidth * 0.03),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune,
                        color: KprimaryColor, size: widget.screenWidth * 0.05),
                    SizedBox(width: widget.screenWidth * 0.015),
                    Text(
                      S.of(context).filterProducts,
                      style: TextStyle(
                        fontSize: widget.screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: KprimaryText,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_rounded,
                      size: widget.screenWidth * 0.06, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: widget.screenHeight * 0.02),

            // Country
            _buildLabel(S.of(context).country),
            SizedBox(height: widget.screenHeight * 0.01),
            _buildStyledDropdown(
              value: selectedCountry['id'],
              hint: S.of(context).selectCountry,
              items: countries,
              onChanged: (value) {
                setState(() => tempCountry = value);
              },
            ),
            SizedBox(height: widget.screenHeight * 0.015),

            // Price Range
            _buildLabel(S.of(context).priceRange),
            RangeSlider(
              min: 0,
              max: 100000,
              divisions: 100,
              labels: RangeLabels(
                tempMinPrice.round().toString(),
                tempMaxPrice.round().toString(),
              ),
              values: RangeValues(tempMinPrice, tempMaxPrice),
              onChanged: (values) {
                setState(() {
                  tempMinPrice = values.start;
                  tempMaxPrice = values.end;
                });
              },
              activeColor: KprimaryColor,
              inactiveColor: Colors.grey[300],
            ),
            SizedBox(height: widget.screenHeight * 0.02),

            // Apply Button
            SizedBox(
              height: widget.screenWidth * 0.12,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: KprimaryColor,
                  borderRadius: BorderRadius.circular(widget.screenWidth * 0.03),
                ),
                child: TextButton(
                  onPressed: () {
                    final countryIdToSet =
                    tempCountry == countryAll ? null : tempCountry;
                    final countryValue =
                    tempCountry == countryAll ? null : countryIds[tempCountry];

                    context.read<FilterRelatedCubit>().updateFilters(
                      context: context,
                      countryId: countryIdToSet,
                      country: countryValue,
                      minPrice: tempMinPrice,
                      maxPrice: tempMaxPrice,
                    );

                    // ✅ إغلاق الـ BottomSheet بعد تطبيق الفلاتر
                    Navigator.pop(context);
                  },
                  child: Text(
                    S.of(context).applyFilters,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.screenWidth * 0.038,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: widget.screenHeight * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: KprimaryText,
        fontSize: widget.screenWidth * 0.035,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStyledDropdown({
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
    String? value,
    String? hint,
  }) {
    return SizedBox(
      height: widget.screenWidth * 0.12,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xffFAFAFA),
          borderRadius: BorderRadius.circular(widget.screenWidth * 0.03),
          border: Border.all(color: const Color(0xffE9E9E9)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            dropdownColor: Colors.white,
            value: value,
            isExpanded: true,
            hint: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.02),
              child: Text(
                hint ?? '',
                style: TextStyle(
                  fontSize: widget.screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            icon: Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.02),
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.black87),
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['id'],
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.03),
                  child: Text(
                    item['name']!,
                    style: TextStyle(
                      fontSize: widget.screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
}

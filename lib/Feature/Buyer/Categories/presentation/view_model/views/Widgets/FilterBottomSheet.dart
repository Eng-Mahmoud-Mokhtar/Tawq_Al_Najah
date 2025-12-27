import 'package:flutter/material.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../filter_products_cubit.dart';

class FilterProudctsBottomSheet extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final void Function(Map<String, dynamic>) onApplyFilters;
  final FilterProductsState initialFilterState;
  // allow optional embedding and category data when used as an embedded widget
  final String? selectedCategory;
  final List<Map<String, String>> categories;
  final bool isEmbedded;
  // new callbacks for category selection
  final void Function(String? apiName, String displayName)? onSelectCategory;
  final VoidCallback? onClearCategory;

  const FilterProudctsBottomSheet({
    required this.screenWidth,
    required this.screenHeight,
    required this.onApplyFilters,
    required this.initialFilterState,
    this.selectedCategory,
    this.categories = const [],
    this.isEmbedded = false,
    this.onSelectCategory,
    this.onClearCategory,
    super.key,
  });
  @override
  State<FilterProudctsBottomSheet> createState() => _FilterProductsBottomSheetState();
}

class _FilterProductsBottomSheetState extends State<FilterProudctsBottomSheet> {
  late double tempMinPrice;
  late double tempMaxPrice;
  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    tempMinPrice = widget.initialFilterState.minPrice;
    tempMaxPrice = (widget.initialFilterState.maxPrice <= 0)
        ? kFilterMaxPrice
        : (widget.initialFilterState.maxPrice > kFilterMaxPrice
        ? kFilterMaxPrice
        : widget.initialFilterState.maxPrice);
  }

  void _applyFilters() {
    final minPriceInt = tempMinPrice.round();
    final maxPriceInt = tempMaxPrice.round();
    final filters = {
      'minPrice': tempMinPrice,
      'maxPrice': tempMaxPrice,
      'min_price': minPriceInt,
      'max_price': maxPriceInt,
    };
    widget.onApplyFilters(filters);
    // only pop the route when this bottom sheet is not embedded inside another widget
    if (!widget.isEmbedded) Navigator.pop(context);
  }

  Future<void> _showCategoryDialog() async {
    // kept for compatibility but use anchored menu via _showCategoryMenu
    // fallback: open centered dialog (shouldn't be used)
    final selected = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Center(child: Text(S.current.categories)),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, null),
              child: Center(child: Text(S.current.all)),
            ),
            ...widget.categories.map((cat) {
              return SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, cat['apiName']),
                child: Center(child: Text(cat['displayName'] ?? '')),
              );
            }).toList(),
          ],
        );
      },
    );

    if (selected != null) {
      final display = widget.categories.firstWhere(
        (c) => c['apiName'] == selected,
        orElse: () => {'displayName': selected},
      )['displayName'] ?? selected;
      widget.onSelectCategory?.call(selected, display);
    } else {
      widget.onSelectCategory?.call(null, S.current.all);
    }
  }

  Future<void> _showCategoryMenu(Offset globalPosition) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String?>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(globalPosition, globalPosition),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<String?>(
          value: null,
          child: Text(S.current.all),
        ),
        ...widget.categories.map((cat) => PopupMenuItem<String?>(
          value: cat['apiName'],
          child: Text(cat['displayName'] ?? ''),
        )),
      ],
    );

    if (selected != null) {
      final display = widget.categories.firstWhere(
        (c) => c['apiName'] == selected,
        orElse: () => {'displayName': selected},
      )['displayName'] ?? selected;
      widget.onSelectCategory?.call(selected, display);
    } else if (selected == null) {
      // user picked All
      widget.onSelectCategory?.call(null, S.current.all);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.screenWidth * 0.04,
        vertical: widget.screenHeight * 0.02,
      ),
      constraints: BoxConstraints(maxHeight: widget.screenHeight * 0.85),
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
            // Header: title and close button (first)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tune,
                      color: KprimaryColor,
                      size: widget.screenWidth * 0.05,
                    ),
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
                  child: Icon(
                    Icons.close_rounded,
                    size: widget.screenWidth * 0.06,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            SizedBox(height: widget.screenHeight * 0.02),

            // Price filter first (as requested)
            Text(
              S.of(context).priceRange,
              style: TextStyle(
                color: KprimaryText,
                fontSize: widget.screenWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
            RangeSlider(
              min: 0,
              max: kFilterMaxPrice,
              divisions: (kFilterMaxPrice / 100).toInt(),
              labels: RangeLabels(
                '${tempMinPrice.round()}',
                '${tempMaxPrice.round()}',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${tempMinPrice.round()}',
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.035,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${tempMaxPrice.round()}',
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.035,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.screenHeight * 0.02),
            SizedBox(
              height: widget.screenWidth * 0.12,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: KprimaryColor,
                  borderRadius: BorderRadius.circular(
                    widget.screenWidth * 0.03,
                  ),
                ),
                child: TextButton(
                  onPressed: _applyFilters,
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

            // Categories selector as compact row: left arrow opens dialog, right shows current selection
            if (widget.categories.isNotEmpty) ...[
              Text(
                S.current.categories,
                style: TextStyle(
                  fontSize: widget.screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: widget.screenWidth * 0.02),
              Container(
                padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.03, vertical: widget.screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xffE9E9E9)),
                ),
                child: Row(
                  children: [
                    // left arrow to open anchored pop menu
                    GestureDetector(
                      onTapDown: (details) {
                        _showCategoryMenu(details.globalPosition);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: widget.screenWidth * 0.02),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: widget.screenWidth * 0.07,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // show current selection on the right
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.selectedCategory != null
                              ? (widget.categories.firstWhere((c) => c['apiName'] == widget.selectedCategory, orElse: () => {'displayName': widget.selectedCategory!})['displayName'] ?? widget.selectedCategory!)
                              : S.current.all,
                          style: TextStyle(
                            fontSize: widget.screenWidth * 0.035,
                            color: widget.selectedCategory != null ? KprimaryColor : Colors.black87,
                            fontWeight: widget.selectedCategory != null ? FontWeight.bold : FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.selectedCategory != null)
                          SizedBox(width: widget.screenWidth * 0.02),
                        if (widget.selectedCategory != null)
                          GestureDetector(
                            onTap: () => widget.onClearCategory?.call(),
                            child: Icon(
                              Icons.clear,
                              size: widget.screenWidth * 0.06,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: widget.screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../Product/presentation/view_model/views/SuggestionsPage.dart';
import '../../../../../Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import '../../../../../Product/presentation/view_model/views/widgets/getAdsData.dart';
import '../../../../../Product/presentation/view_model/views/widgets/AdCard.dart';

class SuggestionsSection extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  const SuggestionsSection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<SuggestionsSection> createState() => _SuggestionsSectionState();
}

class _SuggestionsSectionState extends State<SuggestionsSection> {
  bool isLoading = true;
  late List<Map<String, dynamic>> suggestionAds;

  @override
  void initState() {
    super.initState();
    suggestionAds = DataProvider.getAdsData();

    // تشغيل shimmer لمدة ثانيتين فقط
    Timer(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).suggestions,
                style: TextStyle(
                  fontSize: widget.screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SuggestionsPage(ads: suggestionAds),
                    ),
                  );
                },
                child: Text(
                  S.of(context).seeMore,
                  style: TextStyle(
                    fontSize: widget.screenWidth * 0.03,
                    fontWeight: FontWeight.bold,
                    color: KprimaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.screenHeight * 0.01),

          // ===== Content Area =====
          SizedBox(
            height: widget.screenHeight * 0.37,
            child: isLoading
                ? ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: textDirection == TextDirection.rtl,
              itemCount: 4,
              separatorBuilder: (_, __) =>
                  SizedBox(width: widget.screenWidth * 0.04),
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: widget.screenWidth * 0.45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(widget.screenWidth * 0.03),
                  ),
                ),
              ),
            )
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: textDirection == TextDirection.rtl,
              itemCount: suggestionAds.length,
              separatorBuilder: (_, __) =>
                  SizedBox(width: widget.screenWidth * 0.04),
              itemBuilder: (_, index) {
                return AdCard(
                  ad: suggestionAds[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(
                          ad: suggestionAds[index],
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

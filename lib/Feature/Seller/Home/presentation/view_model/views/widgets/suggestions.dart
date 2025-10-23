import 'package:flutter/material.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../Product/presentation/view_model/views/SuggestionsPage.dart';
import '../../../../../Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import '../../../../../Product/presentation/view_model/views/widgets/getAdsData.dart';
import '../../../../../cart/presentation/view_model/views/widgets/AdCard.dart';

Widget suggestions(double screenWidth, double screenHeight, BuildContext context) {
  final List<Map<String, dynamic>> suggestionAds = DataProvider.getAdsData();
  final textDirection = Localizations.localeOf(context).languageCode == 'ar'
      ? TextDirection.rtl
      : TextDirection.ltr;

  return Directionality(
    textDirection: textDirection,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).suggestions,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
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
                style: TextStyle(fontSize: screenWidth * 0.035, color: KprimaryColor),
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        SizedBox(
          height: screenHeight * 0.37,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: textDirection == TextDirection.rtl, // Scroll right-to-left for RTL
            itemCount: suggestionAds.length,
            separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.04),
            itemBuilder: (_, index) {
              return AdCard(
                ad: suggestionAds[index],
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(ad: suggestionAds[index]),
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
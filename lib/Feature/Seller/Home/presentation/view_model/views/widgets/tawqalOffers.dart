import 'package:flutter/material.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../Product/presentation/view_model/views/TawqalOffersPage.dart';
import '../../../../../Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import '../../../../../Product/presentation/view_model/views/widgets/getAdsData.dart';
import '../../../../../cart/presentation/view_model/views/widgets/AdCard.dart';
import '../../../../../../../generated/l10n.dart';

Widget tawqalOffers(double screenWidth, double screenHeight, BuildContext context) {
  final List<Map<String, dynamic>> tawqalAds = DataProvider.getAdsData();
  final isRtl = Localizations.localeOf(context).languageCode == 'ar';

  return Directionality(
    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              S.of(context).tawqalOffers,
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
                    builder: (_) => TawqalOffersPage(ads: tawqalAds),
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
            reverse: isRtl,
            itemCount: tawqalAds.length,
            separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.04),
            itemBuilder: (_, index) {
              return AdCard(
                ad: tawqalAds[index],
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(ad: tawqalAds[index]),
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
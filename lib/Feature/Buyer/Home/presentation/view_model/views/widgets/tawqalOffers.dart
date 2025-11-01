import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../Product/presentation/view_model/views/TawqalOffersPage.dart';
import '../../../../../Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import '../../../../../Product/presentation/view_model/views/widgets/getAdsData.dart';
import '../../../../../Product/presentation/view_model/views/widgets/AdCard.dart';
import '../../../../../../../generated/l10n.dart';

class TawqalOffersSection extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  const TawqalOffersSection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<TawqalOffersSection> createState() => _TawqalOffersSectionState();
}

class _TawqalOffersSectionState extends State<TawqalOffersSection> {
  bool isLoading = true;
  late List<Map<String, dynamic>> tawqalAds;

  @override
  void initState() {
    super.initState();
    tawqalAds = DataProvider.getAdsData();

    // تفعيل الشيمر لمدة ثانيتين قبل عرض الإعلانات الحقيقية
    Timer(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== العنوان =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).tawqalOffers,
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
                      builder: (_) => TawqalOffersPage(ads: tawqalAds),
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

          SizedBox(
            height: widget.screenHeight * 0.37,
            child: isLoading
                ? ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: isRtl,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== صورة الإعلان الوهمية =====
                      Container(
                        height: widget.screenHeight * 0.22,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(
                                widget.screenWidth * 0.03),
                          ),
                        ),
                      ),
                      SizedBox(height: widget.screenHeight * 0.01),

                      // ===== العنوان =====
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: widget.screenWidth * 0.02),
                        child: Container(
                          height: widget.screenHeight * 0.015,
                          width: widget.screenWidth * 0.3,
                          color: Colors.grey[300],
                        ),
                      ),
                      SizedBox(height: widget.screenHeight * 0.008),

                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: widget.screenWidth * 0.02),
                        child: Container(
                          height: widget.screenHeight * 0.015,
                          width: widget.screenWidth * 0.2,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                : tawqalAds.isEmpty
                ? Center(
              child: Text(
                S.of(context).NoResultstoShow,
                style: TextStyle(
                  fontSize: widget.screenWidth * 0.035,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              reverse: isRtl,
              itemCount: tawqalAds.length,
              separatorBuilder: (_, __) =>
                  SizedBox(width: widget.screenWidth * 0.04),
              itemBuilder: (_, index) {
                return AdCard(
                  ad: tawqalAds[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsPage(
                          ad: tawqalAds[index],
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../../Core/Widgets/buildImageError.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../../Buyer/Home/presentation/view_model/views/widgets/ImageHome.dart';

class RelatedCard extends StatelessWidget {
  final Map<String, dynamic> ad;
  final VoidCallback onTap;

  const RelatedCard({
    super.key,
    required this.ad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.3;
    final cardWidth = cardHeight * 0.65;
    final String currency;
    if (ad['currency_type'] != null &&
        ad['currency_type'].toString().isNotEmpty) {
      currency = ad['currency_type'].toString();
    } else if (ad['currency'] != null &&
        ad['currency'].toString().isNotEmpty) {
      currency = ad['currency'].toString();
    } else {
      currency = S.of(context).SYP;
    }
    final priceAfterDiscount =
    ad['priceAfterDiscount']?.toDouble();
    final price =
    ad['price'] != null ? ad['price'].toDouble() : 0.0;

    final finalPrice =
    priceAfterDiscount != null && priceAfterDiscount > 0
        ? priceAfterDiscount
        : price;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cardWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(cardWidth * 0.05),
                ),
                child: _buildImageSection(
                  cardWidth,
                  cardHeight,
                  context,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(cardWidth * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: Text(
                        ad['name']?.toString() ??
                            S.of(context).unknown,
                        style: TextStyle(
                          fontSize: cardHeight * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: cardHeight * 0.01),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: Text(
                        ad['description']?.toString() ??
                            S.of(context).noDescription,
                        style: TextStyle(
                          fontSize: cardHeight * 0.045,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: cardHeight * 0.015),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${finalPrice.toStringAsFixed(2)} $currency",
                        style: TextStyle(
                          fontSize: cardHeight * 0.05,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xffFF580E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(
      double cardWidth,
      double cardHeight,
      BuildContext context,
      ) {
    final imageUrl =
    (ad['images'] is List && ad['images'].isNotEmpty)
        ? ad['images'][0]
        : null;

    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return buildImageErrorPlaceholder(
          context, cardWidth, cardHeight);
    }

    return CachedNetworkImage(
      imageUrl: ImageHome.getValidImageUrl(imageUrl),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[300],
        ),
      ),
      errorWidget: (context, url, error) =>
          buildImageErrorPlaceholder(
              context, cardWidth, cardHeight),
    );
  }
}
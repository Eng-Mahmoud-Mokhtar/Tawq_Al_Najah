import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../../Buyer/Home/presentation/view_model/views/widgets/ImageHome.dart';
import '../../../../../../Buyer/Product/Data/Models/ProductModel.dart';
import '../../../RelatedDetails.dart';
import '../../RelatedPage.dart';
import 'RelatedCard.dart';

class RelatedSection extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final double cardWidth;
  final double cardHeight;
  final bool isLoading;
  final List<ProductModel> suggestedProducts;
  final VoidCallback? onSeeMorePressed;

  const RelatedSection({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.cardWidth,
    required this.cardHeight,
    required this.isLoading,
    required this.suggestedProducts,
    this.onSeeMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).relatedItems,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!isLoading && suggestedProducts.isNotEmpty)
                TextButton(
                  onPressed: onSeeMorePressed ?? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RelatedPage(products: suggestedProducts),
                      ),
                    );
                  },
                  child: Text(
                    S.of(context).seeMore,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.bold,
                      color: KprimaryColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          SizedBox(
            height: cardHeight,
            child: isLoading
                ? _buildSuggestionsShimmer()
                : suggestedProducts.isEmpty
                ? _buildEmptyState(S.of(context).NoResultstoShow)
                : _buildSuggestionsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsShimmer() {
    int itemCount = (screenWidth / (cardWidth + screenWidth * 0.04)).ceil() + 1;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      itemBuilder: (_, index) {
        return Padding(
          padding: EdgeInsetsDirectional.only(
            end: screenWidth * 0.04,
          ),
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: _buildCardShimmer(),
          ),
        );
      },
    );
  }

  Widget _buildCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: cardHeight * 0.6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(cardWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: double.infinity,
                          height: cardHeight * 0.03,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: cardHeight * 0.01),
                        Container(
                          width: cardWidth * 0.7,
                          height: cardHeight * 0.025,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(height: cardHeight * 0.015),
                        Container(
                          width: cardWidth * 0.5,
                          height: cardHeight * 0.02,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: cardWidth * 0.3,
                          height: cardHeight * 0.035,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          width: cardWidth * 0.12,
                          height: cardHeight * 0.12,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
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

  Widget _buildSuggestionsList(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: suggestedProducts.length,
      itemBuilder: (_, index) {
        final product = suggestedProducts[index];
        final productMap = product.toMap();
        productMap['images'] = ImageHome.processImageList(product.images);

        return Padding(
          padding: EdgeInsetsDirectional.only(
            end: screenWidth * 0.04,
          ),
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: RelatedCard(
              ad: productMap,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RelatedDetails(
                      productId: product.id,
                      initialProductData: productMap,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: screenHeight * 0.25,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey.shade400,
            size: screenWidth * 0.08,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            message,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
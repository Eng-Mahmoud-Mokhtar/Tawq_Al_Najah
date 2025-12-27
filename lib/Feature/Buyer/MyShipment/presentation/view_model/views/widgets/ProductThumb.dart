import 'package:flutter/material.dart';
import '../../../../../../../generated/l10n.dart';
import 'ShimmerBox.dart';

class ProductThumb extends StatelessWidget {
  final double size;
  final double radius;
  final String? imageUrl;

  const ProductThumb({super.key,
    required this.size,
    required this.radius,
    required this.imageUrl,
  });

  Widget buildImageErrorPlaceholder(
      BuildContext context,
      double cardWidth,
      double cardHeight,
      ) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade400,
            size: cardWidth * 0.15,
          ),
          SizedBox(height: cardHeight * 0.1),
          Text(
            S.of(context).errorLoadingCategories,
            style: TextStyle(
              fontSize: cardWidth * 0.05,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    final placeholder = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: buildImageErrorPlaceholder(context, size, size),
      ),
    );

    if (url == null || url.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return ShimmerBox(width: size, height: size, radius: radius);
          },
        ),
      ),
    );
  }
}

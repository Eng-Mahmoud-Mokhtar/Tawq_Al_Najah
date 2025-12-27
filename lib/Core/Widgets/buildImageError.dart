import 'package:flutter/material.dart';
import '../../generated/l10n.dart';

Widget buildImageErrorPlaceholder(BuildContext context, double cardWidth, double cardHeight) {
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

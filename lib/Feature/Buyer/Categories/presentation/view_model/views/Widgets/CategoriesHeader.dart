import 'package:flutter/material.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';

class CategoriesHeader extends StatelessWidget {
  final double screenWidth;
  final bool showRefresh;
  final VoidCallback? onRefresh;
  final String title;

  const CategoriesHeader({
    super.key,
    required this.screenWidth,
    required this.title,
    this.showRefresh = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showRefresh && onRefresh != null)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: KprimaryColor,
                size: screenWidth * 0.05,
              ),
              onPressed: onRefresh,
            ),
        ],
      ),
    );
  }
}


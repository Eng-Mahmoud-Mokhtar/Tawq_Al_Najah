import 'package:flutter/material.dart';

Widget emptyState(BuildContext context, String message) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  return Center(
    child: Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "Assets/empty-cart 1.png",
            width: screenWidth * 0.5,
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
        ],
      ),
    ),
  );
}

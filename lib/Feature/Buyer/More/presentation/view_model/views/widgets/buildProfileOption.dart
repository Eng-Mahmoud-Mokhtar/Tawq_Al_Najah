import 'package:flutter/material.dart';
import '../../../../../../../Core/utiles/Colors.dart';

Widget buildProfileOption(
    BuildContext context, {
      required String label,
      required String imagePath,
      required double screenWidth,
      required double screenHeight,
      required Widget page,
    }) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    },
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
      ),
      decoration: BoxDecoration(
        color: SecoundColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: screenWidth * 0.05,
            height: screenWidth * 0.05,
            fit: BoxFit.contain,
            color: KprimaryColor,
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
                color: KprimaryText,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: screenWidth * 0.045),
        ],
      ),
    ),
  );
}

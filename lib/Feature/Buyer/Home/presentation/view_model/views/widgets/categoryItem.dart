import 'package:flutter/material.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../Categories/presentation/view_model/views/CategoryPage.dart';

Widget categoryItem(IconData icon, String label, double screenWidth,BuildContext context) {
  return GestureDetector(
    onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CategoryPage(category: label)),
        );
    },
    child: Container(
      width: screenWidth * 0.2,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: KprimaryColor, size: screenWidth * 0.05),
          SizedBox(height: screenWidth * 0.01),
          Text(label, style: TextStyle(fontSize: screenWidth * 0.025), maxLines: 1,
            overflow: TextOverflow.ellipsis,),
        ],
      ),
    ),
  );
}

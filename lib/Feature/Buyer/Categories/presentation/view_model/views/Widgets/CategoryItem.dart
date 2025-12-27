import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/Data/Model/CategoryModel.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';

class CategoryItem extends StatelessWidget {
  final CategoryModel category;
  final IconData icon;
  final String displayLabel;
  final double width;
  final VoidCallback onTap;

  const CategoryItem({
    Key? key,
    required this.category,
    required this.icon,
    required this.displayLabel,
    required this.width,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.18,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(128, 128, 128, 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            category.icon != null && category.icon!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      category.icon!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          icon,
                          color: KprimaryColor,
                          size: screenWidth * 0.06,
                        );
                      },
                    ),
                  )
                : Icon(
                    icon,
                    color: KprimaryColor,
                    size: screenWidth * 0.06,
                  ),
            SizedBox(height: screenWidth * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
              child: Text(
                displayLabel,
                style: TextStyle(
                  fontSize: screenWidth * 0.025,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

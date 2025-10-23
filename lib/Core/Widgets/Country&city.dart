import 'package:flutter/material.dart';
import '../../generated/l10n.dart';


class CountryCity extends StatelessWidget {
  const CountryCity({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return  Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context).Country,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                ),

              ),
              SizedBox(height: screenHeight * 0.01),
              SizedBox(
                height: screenWidth * 0.12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xffFAFAFA),
                    borderRadius: BorderRadius.circular(8),
                    border:
                    Border.all(color: const Color(0xffE9E9E9)),
                  ),
                  child: TextField(
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                      hintText: S.of(context).Country,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.035,
                        horizontal: screenWidth * 0.035,
                      ),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: screenWidth * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
    S.of(context).City,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              SizedBox(
                height: screenWidth * 0.12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xffFAFAFA),
                    borderRadius: BorderRadius.circular(8),
                    border:
                    Border.all(color: const Color(0xffE9E9E9)),
                  ),
                  child: TextField(
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintStyle: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                      hintText: S.of(context).City,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenWidth * 0.035,
                        horizontal: screenWidth * 0.035,
                      ),
                    ),
                    keyboardType: TextInputType.name,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

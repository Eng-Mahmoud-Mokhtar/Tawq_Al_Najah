import 'package:flutter/material.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';

class ShipmentTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final int tabCount;

  const ShipmentTabBar({super.key, required this.selectedIndex, required this.onTap, this.tabCount = 2});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabs = [
      S.of(context).currentTab,
      S.of(context).completedTab,
      S.of(context).cancelledTab,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: MediaQuery.of(context).size.height * 0.015),
      child: Row(
        children: List.generate(tabCount, (i) {
          final isSelected = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: isSelected ? KprimaryColor : Colors.grey.shade200,
                  border: Border.all(color: isSelected ? KprimaryColor : Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}





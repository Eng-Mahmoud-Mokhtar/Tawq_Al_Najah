import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/HomeStructure.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import 'ShipmentCard.dart';
import '../../ShipmentCardData.dart';

class ShipmentTab extends StatelessWidget {
  final List<ShipmentCardData> shipments;
  final Function(ShipmentCardData)? onCancel;
  final bool isCancelled;

  const ShipmentTab({super.key, required this.shipments, this.onCancel, this.isCancelled = false});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (shipments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "Assets/empty-cart 1.png",
                width: screenWidth * 0.5,
                height: screenWidth * 0.5,
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                S.of(context).browseAndShopNow,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: shipments.length,
      itemBuilder: (context, index) {
        return ShipmentCard(
          data: shipments[index],
          onCancel: onCancel,
          isCancelled: isCancelled,
        );
      },
    );
  }
}




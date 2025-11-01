import 'package:flutter/material.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../SellerOrderModel.dart';
import '../SellerOrderDetailsPage.dart';

class ShipmentCardSeller extends StatelessWidget {
  final SellerOrderModel data;
  final Function(SellerOrderModel, String)? onStatusChange;
  final bool isCancelled;

  const ShipmentCardSeller({
    super.key,
    required this.data,
    this.onStatusChange,
    this.isCancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerOrderDetailsPage(
              order: data,
              onStatusChange: onStatusChange,
              showCancelledByCustomer: isCancelled,
            ),
          ),
        );
      },
      child: Directionality(
        textDirection: textDirection,
        child: Container(
          margin: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.04,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        data.productImage,
                        width: screenWidth * 0.18,
                        height: screenWidth * 0.18,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.image, size: screenWidth * 0.18),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.productName,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          Text(
                            data.description,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenWidth * 0.015),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03,
                                  vertical: screenWidth * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: KprimaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.015,
                                  ),
                                ),
                                child: Text(
                                  'x${data.quantity}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenWidth * 0.025,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                data.category,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                data.totalPrice,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xffFF580E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (data.isDelivered)
                Positioned(
                  top: 0,
                  left: textDirection == TextDirection.rtl ? 0 : null,
                  right: textDirection == TextDirection.ltr ? 0 : null,
                  child: _statusBadge(
                    context,
                    textDirection,
                    screenWidth,
                    S.of(context).receivedStatus,
                    KprimaryColor,
                  ),
                ),
              if (isCancelled)
                Positioned(
                  top: 0,
                  left: textDirection == TextDirection.rtl ? 0 : null,
                  right: textDirection == TextDirection.ltr ? 0 : null,
                  child: _statusBadge(
                    context,
                    textDirection,
                    screenWidth,
                    S.of(context).cancelledTab,
                    const Color(0xffDD0C0C),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(
      BuildContext context,
      TextDirection direction,
      double screenWidth,
      String text,
      Color color,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: direction == TextDirection.rtl
              ? Radius.circular(screenWidth * 0.03)
              : Radius.zero,
          topRight: direction == TextDirection.ltr
              ? Radius.circular(screenWidth * 0.03)
              : Radius.zero,
          bottomRight: direction == TextDirection.rtl
              ? Radius.circular(screenWidth * 0.03)
              : Radius.zero,
          bottomLeft: direction == TextDirection.ltr
              ? Radius.circular(screenWidth * 0.03)
              : Radius.zero,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../DetailesOrder.dart';
import '../../ShipmentCardData.dart';

class ShipmentCard extends StatelessWidget {
  final ShipmentCardData? data;
  final bool isLoading;

  const ShipmentCard({
    super.key,
    this.data,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    if (isLoading) {
      return Directionality(
        textDirection: textDirection,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.02,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth * 0.18,
                    height: screenWidth * 0.18,
                    color: Colors.grey[300],
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: screenWidth * 0.03,
                          width: screenWidth * 0.4,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Container(
                          height: screenWidth * 0.025,
                          width: screenWidth * 0.5,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: screenWidth * 0.025),
                        Row(
                          children: [
                            Container(
                              height: screenWidth * 0.03,
                              width: screenWidth * 0.1,
                              color: Colors.grey[300],
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Container(
                              height: screenWidth * 0.03,
                              width: screenWidth * 0.2,
                              color: Colors.grey[300],
                            ),
                            const Spacer(),
                            Container(
                              height: screenWidth * 0.03,
                              width: screenWidth * 0.1,
                              color: Colors.grey[300],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 🔸 الحالة الفعلية (عرض بيانات الشحنة)
    final shipment = data!;
    return GestureDetector(
      onTap: shipment.isCancelled
          ? null
          : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsAndTracker(data: shipment),
          ),
        );
      },
      child: Directionality(
        textDirection: textDirection,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.02,
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
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          shipment.productImage,
                          width: screenWidth * 0.18,
                          height: screenWidth * 0.18,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shipment.productName,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.01),
                              Text(
                                shipment.description,
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
                                          screenWidth * 0.015),
                                    ),
                                    child: Text(
                                      'x${shipment.quantity}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: screenWidth * 0.025,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    shipment.category,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    shipment.price,
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
                    if (shipment.isCancelled)
                      Padding(
                        padding: EdgeInsets.only(top: screenWidth * 0.02),
                        child: Text(
                          shipment.cancellationReason ??
                              S.of(context).cancellationReasonNotSpecified,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: const Color(0xffDD0C0C),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ✅ حالة تم التسليم
              if (shipment.isDelivered)
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

              // ❌ حالة الإلغاء
              if (shipment.isCancelled)
                Positioned(
                  top: 0,
                  left: textDirection == TextDirection.rtl ? 0 : null,
                  right: textDirection == TextDirection.ltr ? 0 : null,
                  child: _statusBadge(
                    context,
                    textDirection,
                    screenWidth,
                    S.of(context).cancelledStatus,
                    const Color(0xffDD0C0C),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 ويدجت حالة الشارة (Delivered / Cancelled)
  Widget _statusBadge(BuildContext context, TextDirection direction,
      double screenWidth, String text, Color color) {
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
              : Radius.circular(0),
          topRight: direction == TextDirection.ltr
              ? Radius.circular(screenWidth * 0.03)
              : Radius.circular(0),
          bottomRight: direction == TextDirection.rtl
              ? Radius.circular(screenWidth * 0.03)
              : Radius.circular(0),
          bottomLeft: direction == TextDirection.ltr
              ? Radius.circular(screenWidth * 0.03)
              : Radius.circular(0),
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

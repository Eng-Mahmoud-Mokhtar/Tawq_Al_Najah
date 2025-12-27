import 'package:flutter/material.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../Data/OrderData.dart';
import '../MyShipmentsPage.dart';
import 'OrderThumb.dart';

class ShipmentCard extends StatelessWidget {
  final OrderData data;
  final VoidCallback? onTap;

  const ShipmentCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return GestureDetector(
      onTap: onTap,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OrderThumb(
                      size: screenWidth * 0.18,
                      radius: screenWidth * 0.02,
                      imageUrl: data.orderImage,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${S.of(context).orderNumberLabel} ${data.orderNumber}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                                  vertical: screenWidth * 0.012,
                                ),
                                decoration: BoxDecoration(
                                  color: KprimaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.015,
                                  ),
                                ),
                                child: Text(
                                  '${data.countItems} ${S.of(context).productsCountLabel}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: screenWidth * 0.025,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                data.finalTotal.toCurrencyText(),
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

              // ✅ Ribbon (زي الكود القديم)
              Positioned(
                top: 0,
                left: textDirection == TextDirection.rtl ? 0 : null,
                right: textDirection == TextDirection.ltr ? 0 : null,
                child: _buildTopStatusRibbon(
                  context: context,
                  direction: textDirection,
                  screenWidth: screenWidth,
                  data: data,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopStatusRibbon({
    required BuildContext context,
    required TextDirection direction,
    required double screenWidth,
    required OrderData data,
  }) {
    String text;
    Color color;

    if (data.isCancelled) {
      text = S.of(context).cancelledTab; // "ملغي"
      color = const Color(0xffDD0C0C);
    } else if (data.isDelivered) {
      text = S.of(context).receivedStatus; // "تم التسليم"
      color = KprimaryColor;
    } else if (data.isShipped) {
      text = S.of(context).shippedStatus; // "تم الشحن"
      color = Colors.blue;
    } else if (data.isAccepted) {
      text = S.of(context).orderConfirmed; // "تم التأكيد"
      color = Colors.green;
    } else {
      text = S.of(context).pending; // "معلق"
      color = const Color(0xffFF580E);
    }

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

import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Seller/MyShipment/presentation/view_model/ShipmentCardData.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../Core/Widgets/AppBar.dart';

class OrderDetailsAndTracker extends StatefulWidget {
  final ShipmentCardData data;

  const OrderDetailsAndTracker({super.key, required this.data});

  @override
  State<OrderDetailsAndTracker> createState() => _OrderDetailsAndTrackerState();
}

class _OrderDetailsAndTrackerState extends State<OrderDetailsAndTracker> {
  int currentStep = 0;
  List<Map<String, String>> steps = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    steps = [
      {
        'title': S.of(context).orderConfirmed,
        'dayMonth': '${widget.data.orderDate.split('-')[2]} ${S.of(context).getMonth(widget.data.orderDate.split('-')[1])} ${widget.data.orderDate.split('-')[0]}',
        'time': '15:45',
      },
      {
        'title': S.of(context).shippedStatus,
        'dayMonth': '${int.parse(widget.data.orderDate.split('-')[2]) + 1} ${S.of(context).getMonth(widget.data.orderDate.split('-')[1])} ${widget.data.orderDate.split('-')[0]}',
        'time': '09:30',
      },
      {
        'title': S.of(context).receivedStatus,
        'dayMonth': '${int.parse(widget.data.orderDate.split('-')[2]) + 2} ${S.of(context).getMonth(widget.data.orderDate.split('-')[1])} ${widget.data.orderDate.split('-')[0]}',
        'time': '20:50',
      },
    ];
    if (widget.data.isDelivered) {
      currentStep = 2; // Stop at final step for completed
    } else {
      // For current shipments, set different steps based on shipment number
      if (widget.data.shipmentNumber == "256") {
        currentStep = 0; // Stop at first step
      } else if (widget.data.shipmentNumber == "261") {
        currentStep = 1; // Stop at second step
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
    final grandTotal = (double.parse(widget.data.totalPrice.split(' ')[0]) + double.parse(widget.data.shippingCost.split(' ')[0])).toString() + ' ر.س';

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).orderDetails),
      body: Directionality(
        textDirection: textDirection,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).productDetails,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(
                              S.of(context).descriptionLabel,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.data.description,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(
                              S.of(context).quantityLabel,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Text(
                            '${widget.data.quantity}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(
                              S.of(context).priceLabel,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.data.totalPrice,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(
                              S.of(context).shippingCostLabel,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.data.shippingCost,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(
                              S.of(context).totalLabel,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              grandTotal,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffFF580E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).orderStatus,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Column(
                        children: List.generate(steps.length, (index) {
                          final step = steps[index];
                          return _buildStep(
                            title: step['title']!,
                            dayMonth: step['dayMonth']!,
                            time: step['time']!,
                            isActive: index <= currentStep,
                            isLast: index == steps.length - 1,
                          );
                        }),
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

  Widget _buildStep({
    required String title,
    required String dayMonth,
    required String time,
    required bool isActive,
    required bool isLast,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: screenWidth * 0.03,
              horizontal: screenWidth * 0.04,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffF6F6F5),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.black : Colors.grey,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: screenWidth * 0.04,
                height: screenWidth * 0.03,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xffFF580E) : const Color(0xffDEBEBF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (!isLast)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 3,
                height: 50,
                color: isActive ? const Color(0xffFF580E) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenWidth * 0.005),
              child: Text(
                dayMonth,
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.03,
                ),
              ),
            ),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

extension LocalizationExtension on S {
  String getMonth(String month) {
    const months = {
      '01': 'january',
      '02': 'february',
      '03': 'march',
      '04': 'april',
      '05': 'may',
      '06': 'june',
      '07': 'july',
      '08': 'august',
      '09': 'september',
      '10': 'october',
      '11': 'november',
      '12': 'december',
    };
    final monthKey = months[month] ?? 'january';
    switch (monthKey) {
      case 'january':
        return january;
      case 'february':
        return february;
      case 'march':
        return march;
      case 'april':
        return april;
      case 'may':
        return may;
      case 'june':
        return june;
      case 'july':
        return july;
      case 'august':
        return august;
      case 'september':
        return september;
      case 'october':
        return october;
      case 'november':
        return november;
      case 'december':
        return december;
      default:
        return '';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Buyer/MyShipment/presentation/view_model/ShipmentCardData.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';

class OrderDetailsAndTracker extends StatefulWidget {
  final ShipmentCardData data;
  final VoidCallback? onCancelled;
  final bool isCancelled;

  const OrderDetailsAndTracker({
    super.key,
    required this.data,
    this.onCancelled,
    this.isCancelled = false,
  });

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
        'dayMonth': _formatDate(widget.data.orderConfirmedDate),
        'time': widget.data.orderConfirmedTime,
      },
      {
        'title': S.of(context).shippedStatus,
        'dayMonth': _formatDate(widget.data.shippedDate),
        'time': widget.data.shippedTime,
      },
      {
        'title': S.of(context).receivedStatus,
        'dayMonth': _formatDate(widget.data.deliveredDate),
        'time': widget.data.deliveredTime,
      },
    ];

    if (widget.data.isDelivered) {
      currentStep = 2;
    } else {
      if (widget.data.shipmentNumber == "256") {
        currentStep = 0;
      } else if (widget.data.shipmentNumber == "261") {
        currentStep = 1;
      }
    }
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    final day = parts[2];
    final monthKey = parts[1];
    final year = parts[0];
    final monthName = S.of(context).getMonth(monthKey);
    return '$day $monthName $year';
  }

  void _showCancelDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xfffafafa),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        title: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.01),
          child: Text(
            S.of(context).cancelOrder,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        content: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Text(
            S.of(context).cancelOrderConfirmation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: SecoundText,
              height: 1.4,
            ),
          ),
        ),
        actionsPadding: EdgeInsets.fromLTRB(
          screenWidth * 0.04,
          0,
          screenWidth * 0.04,
          screenHeight * 0.02,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.grey.shade300,
                    minimumSize: Size(0, screenWidth * 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    S.of(context).no,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xffDD0C0C),
                    minimumSize: Size(0, screenWidth * 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    widget.onCancelled?.call();
                    Navigator.pop(context);
                  },
                  child: Text(
                    S.of(context).yes,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;
    final grandTotal = '${double.parse(widget.data.totalPrice.split(' ')[0]) + double.parse(widget.data.shippingCost.split(' ')[0])}';

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).orderDetails),
      body: Directionality(
        textDirection: textDirection,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === Product Details ===
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).productDetails,
                          style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.black)),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(S.of(context).descriptionLabel,
                                style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black54)),
                          ),
                          Expanded(
                            child: Text(widget.data.description,
                                style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black)),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(S.of(context).quantityLabel,
                                style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black54)),
                          ),
                          Text('${widget.data.quantity}',
                              style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black)),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(S.of(context).priceLabel,
                                style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black54)),
                          ),
                          Expanded(
                            child: Text(widget.data.totalPrice,
                                style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black)),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(S.of(context).shippingCostLabel,
                                style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black54)),
                          ),
                          Expanded(
                            child: Text(widget.data.shippingCost,
                                style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.black)),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(S.of(context).totalLabel,
                                style: TextStyle(fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold, color: Colors.black)),
                          ),
                          Expanded(
                            child: Text(grandTotal,
                                style: TextStyle(fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold, color: const Color(0xffFF580E))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),

                // === Order Status ===
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(S.of(context).orderStatus,
                          style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold, color: Colors.black)),
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

                SizedBox(height: screenWidth * 0.04),

                // === Action Button ===
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getButtonColor(),
                      minimumSize: Size(screenWidth * 0.9, screenWidth * 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _getButtonOnPressed(),
                    child: SizedBox(
                      height: screenWidth * 0.12,
                      child: Center(
                        child: Text(
                          _getButtonText(),
                          style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getButtonColor() {
    if (widget.isCancelled) return Colors.grey;
    if (widget.data.isDelivered) return Colors.grey;
    return KprimaryColor;
  }

  VoidCallback? _getButtonOnPressed() {
    if (widget.isCancelled || widget.data.isDelivered) return null;
    return _showCancelDialog;
  }

  String _getButtonText() {
    if (widget.isCancelled) return S.of(context).cancelled;
    return S.of(context).cancelOrder;
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
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03, horizontal: screenWidth * 0.04),
            decoration: BoxDecoration(color: const Color(0xffF6F6F5), borderRadius: BorderRadius.circular(screenWidth * 0.03)),
            child: Text(title,
                style: TextStyle(fontWeight: FontWeight.w500, color: isActive ? Colors.black : Colors.grey, fontSize: screenWidth * 0.03)),
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
                decoration: BoxDecoration(color: isActive ? const Color(0xffFF580E) : const Color(0xffDEBEBF), shape: BoxShape.circle),
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
              child: Text(dayMonth,
                  style: TextStyle(color: isActive ? Colors.black : Colors.black54, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.03)),
            ),
            Text(time, style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.03)),
          ],
        ),
      ],
    );
  }
}
extension LocalizationExtension on S {
  String getMonth(String month) {
    final months = {
      '01': january,
      '02': february,
      '03': march,
      '04': april,
      '05': may,
      '06': june,
      '07': july,
      '08': august,
      '09': september,
      '10': october,
      '11': november,
      '12': december,
    };
    return months[month] ?? january;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tawqalnajah/Core/Widgets/AppBar.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../OrdersCubit.dart';
import '../SellerOrderModel.dart';

class SellerOrderDetailsPage extends StatefulWidget {
  final SellerOrderModel order;
  final Function(SellerOrderModel, String)? onStatusChange;
  final bool showCancelledByCustomer;

  const SellerOrderDetailsPage({
    super.key,
    required this.order,
    this.onStatusChange,
    this.showCancelledByCustomer = false,
  });

  @override
  State<SellerOrderDetailsPage> createState() => _SellerOrderDetailsPageState();
}

class _SellerOrderDetailsPageState extends State<SellerOrderDetailsPage> {
  late List<Map<String, String>> steps;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _buildSteps();
  }

  void _buildSteps() {
    final now = DateTime.now();
    final today = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    steps = [];

    if (widget.order.status != "pending") {
      steps.add({
        'title': S.of(context).confirmed,
        'dayMonth': _formatDate(widget.order.confirmedDate ?? today),
        'time': widget.order.confirmedTime ?? "--",
      });
    }

    if (widget.order.status == "shipped" || widget.order.status == "delivered") {
      steps.add({
        'title': S.of(context).shipped,
        'dayMonth': _formatDate(widget.order.shippedDate ?? today),
        'time': widget.order.shippedTime ?? "--",
      });
    }

    if (widget.order.status == "delivered") {
      steps.add({
        'title': S.of(context).delivered,
        'dayMonth': _formatDate(widget.order.deliveredDate ?? today),
        'time': widget.order.deliveredTime ?? "--",
      });
    }
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    final day = parts[2];
    final monthKey = parts[1];
    final year = parts[0];
    final months = {
      '01': S.of(context).january,
      '02': S.of(context).february,
      '03': S.of(context).march,
      '04': S.of(context).april,
      '05': S.of(context).may,
      '06': S.of(context).june,
      '07': S.of(context).july,
      '08': S.of(context).august,
      '09': S.of(context).september,
      '10': S.of(context).october,
      '11': S.of(context).november,
      '12': S.of(context).december,
    };
    return '$day ${months[monthKey] ?? S.of(context).january} $year';
  }

  void _showActionDialog(String action, String newStatus) {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xfffafafa),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        title: Text(S.of(context).confirmAction(action),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold)),
        content: Text(S.of(context).confirmActionMessage,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey[700])),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KprimaryColor,
                    minimumSize: Size(0, screenWidth * 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<OrdersCubit>().updateOrderStatus(widget.order.orderId, newStatus);
                    Navigator.pop(context);
                  },
                  child: Text(S.of(context).yes, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035)),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    minimumSize: Size(0, screenWidth * 0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(S.of(context).no, style: TextStyle(color: Colors.black87, fontSize: screenWidth * 0.035)),
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
    final grandTotal = '${double.parse(widget.order.totalPrice.split(' ')[0]) + double.parse(widget.order.shippingCost.split(' ')[0])} ${S.of(context).sar}';

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).orderDetails),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(screenWidth * 0.03)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: screenWidth * 0.08, backgroundColor: Colors.grey[200], child: Icon(Icons.person, size: screenWidth * 0.08, color: Colors.grey[600])),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.order.customerName, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(widget.order.customerPhone, style: TextStyle(fontSize: screenWidth * 0.032, color: Colors.grey[700])),
                        SizedBox(height: 4),
                        Text(widget.order.customerAddress, style: TextStyle(fontSize: screenWidth * 0.032, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(screenWidth * 0.03)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).productDetails, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold)),
                  SizedBox(height: screenWidth * 0.02),
                  _buildRow(S.of(context).description, widget.order.description, screenWidth),
                  _buildRow(S.of(context).quantity, '${widget.order.quantity}', screenWidth),
                  _buildRow(S.of(context).price, widget.order.totalPrice, screenWidth),
                  _buildRow(S.of(context).shippingCost, widget.order.shippingCost, screenWidth),
                  _buildRow(S.of(context).total, grandTotal, screenWidth, isTotal: true),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Container(
              width: screenWidth,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).orderStatus, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold)),
                  SizedBox(height: screenWidth * 0.01),
                  if (steps.isEmpty)
                    Text(S.of(context).orderPendingMessage, style: TextStyle(color: SecoundText, fontSize: screenWidth * 0.03)),
                  if (steps.isNotEmpty)
                    Column(children: List.generate(steps.length, (i) => _buildStep(i, screenWidth))),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            if (widget.showCancelledByCustomer)
              Center(child: Text(S.of(context).orderCancelledByCustomer, style: TextStyle(color: Color(0xffDD0C0C), fontWeight: FontWeight.bold, fontSize: screenWidth * 0.035))),
            if (!["delivered", "cancelled"].contains(widget.order.status))
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: KprimaryColor, minimumSize: Size(screenWidth, screenWidth * 0.12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    final action = widget.order.status == "pending"
                        ? S.of(context).confirm
                        : widget.order.status == "confirmed"
                        ? S.of(context).ship
                        : S.of(context).delivered;
                    final newStatus = widget.order.status == "pending"
                        ? "confirmed"
                        : widget.order.status == "confirmed"
                        ? "shipped"
                        : "delivered";
                    _showActionDialog(action, newStatus);
                  },
                  child: Text(
                    widget.order.status == "pending"
                        ? S.of(context).confirmOrder
                        : widget.order.status == "confirmed"
                        ? S.of(context).shipOrder
                        : S.of(context).markAsDelivered,
                    style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, double width, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.01),
      child: Row(
        children: [
          SizedBox(width: width * 0.3, child: Text(label, style: TextStyle(fontSize: width * 0.03, color: Colors.black54))),
          Expanded(child: Text(value, style: TextStyle(fontSize: width * 0.03, color: isTotal ? Color(0xffFF580E) : Colors.black, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal))),
        ],
      ),
    );
  }

  Widget _buildStep(int i, double width) {
    final isLast = i == steps.length - 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.04),
            decoration: BoxDecoration(color: const Color(0xffF6F6F5), borderRadius: BorderRadius.circular(width * 0.03)),
            child: Text(steps[i]['title']!, style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: width * 0.03)),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: width * 0.03),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: width * 0.04,
                height: width * 0.03,
                decoration: BoxDecoration(color: const Color(0xffFF580E), shape: BoxShape.circle),
              ),
            ),
            if (!isLast) Container(width: 3, height: 50, color: const Color(0xffFF580E)),
          ],
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: width * 0.005),
              child: Text(steps[i]['dayMonth']!, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: width * 0.03)),
            ),
            Text(steps[i]['time']!, style: TextStyle(color: Colors.grey, fontSize: width * 0.03)),
          ],
        ),
      ],
    );
  }
}

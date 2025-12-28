import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../Data/OrderData.dart';
import '../CancelOrderCubit.dart';
import '../CancelOrderState.dart';
import '../MyShipmentsCubit.dart';
import 'MyShipmentsPage.dart';
import 'widgets/CancelStatusDialog.dart';
import '../../../Model/OrderItem.dart';
import 'widgets/ProductThumb.dart';


class OrderDetailsAndTracker extends StatefulWidget {
  final OrderData data;

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
    _updateSteps();
  }

  void _updateSteps() {
    final track = widget.data.trackOrder;
    final orderDate = widget.data.orderDate;

    steps = [
      {
        'title': S.of(context).orderConfirmed,
        'dayMonth': track.acceptedTime != null
            ? _formatDate(track.acceptedTime!)
            : _formatDate(orderDate),
        'time': track.acceptedTime != null
            ? _extractTime(track.acceptedTime!)
            : _extractTime(orderDate),
      },
      {
        'title': S.of(context).shippedStatus,
        'dayMonth':
        track.shippedTime != null ? _formatDate(track.shippedTime!) : '',
        'time': track.shippedTime != null ? _extractTime(track.shippedTime!) : '',
      },
      {
        'title': S.of(context).receivedStatus,
        'dayMonth': track.completedTime != null
            ? _formatDate(track.completedTime!)
            : '',
        'time': track.completedTime != null
            ? _extractTime(track.completedTime!)
            : '',
      },
    ];

    if (widget.data.isCancelled) {
      currentStep = -1;
    } else if (widget.data.isDelivered) {
      currentStep = 2;
    } else if (track.shipped) {
      currentStep = 1;
    } else {
      currentStep = 0;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date != null) return '${date.day}/${date.month}/${date.year}';
    return dateString;
  }

  String _extractTime(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date != null) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '';
  }

  Future<void> _cancelWithStatusDialog() async {
    final cancelCubit = context.read<CancelOrderCubit>();
    cancelCubit.reset();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: cancelCubit,
        child: const CancelStatusDialog(),
      ),
    );

    await cancelCubit.cancelOrder(widget.data.orderId);

    if (!mounted) return;

    final st = cancelCubit.state;
    if (st is CancelOrderSuccess) {
      await context.read<MyShipmentsCubit>().refreshPendingAndCancelled();
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _showCancelConfirmDialog() {
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
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _cancelWithStatusDialog();
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

  Color _getButtonColor() {
    if (widget.data.isCancelled) return Colors.grey;
    if (widget.data.isDelivered) return Colors.grey;
    return  Color(0xffDD0C0C);
  }

  VoidCallback? _getButtonOnPressed() {
    if (widget.data.isCancelled || widget.data.isDelivered) return null;
    return _showCancelConfirmDialog;
  }

  String _getButtonText() {
    if (widget.data.isCancelled) return S.of(context).cancelled;
    if (widget.data.isDelivered) return S.of(context).receivedStatus;
    return S.of(context).cancelOrder;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

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
                      SizedBox(height: screenWidth * 0.03),
                      if (widget.data.items.isEmpty)
                        Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                          child: Text(
                            S.of(context).noItemsInOrder,
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: widget.data.items.map(_orderItemRow).toList(),
                        ),
                      SizedBox(height: screenWidth * 0.03),
                      Divider(color: Colors.grey.shade300),
                      SizedBox(height: screenWidth * 0.02),
                      _summaryRow(
                        label: S.of(context).priceLabel,
                        value: widget.data.total.toCurrencyText(),
                        screenWidth: screenWidth,
                        isBold: false,
                      ),
                      SizedBox(height: screenWidth * 0.015),
                      _summaryRow(
                        label: S.of(context).shippingCostLabel,
                        value: widget.data.fees.toCurrencyText(),
                        screenWidth: screenWidth,
                        isBold: false,
                      ),
                      SizedBox(height: screenWidth * 0.015),
                      _summaryRow(
                        label: S.of(context).totalLabel,
                        value: widget.data.finalTotal.toCurrencyText(),
                        screenWidth: screenWidth,
                        isBold: true,
                        valueColor: const Color(0xffFF580E),
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
                          final bool isActive = index <= currentStep;

                          final hasDate =
                              (step['dayMonth'] ?? '').trim().isNotEmpty;
                          final hasTime =
                              (step['time'] ?? '').trim().isNotEmpty;

                          return _buildStep(
                            title: step['title']!,
                            dayMonth: step['dayMonth']!,
                            time: step['time']!,
                            isActive: isActive,
                            isLast: index == steps.length - 1,
                            forceEmptyDateSpace: !(hasDate && hasTime),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    required double screenWidth,
    required bool isBold,
    Color valueColor = Colors.black,
  }) {
    return Row(
      children: [
        SizedBox(
          width: screenWidth * 0.35,
          child: Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    required String title,
    required String dayMonth,
    required String time,
    required bool isActive,
    required bool isLast,
    bool forceEmptyDateSpace = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardMinHeight = screenWidth * 0.14;

    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: cardMinHeight),
              padding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.03,
                horizontal: screenWidth * 0.04,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? KprimaryColor.withAlpha((0.1 * 255).round())
                    : const Color(0xffF6F6F5),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                border: Border.all(
                  color: isActive ? KprimaryColor : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Align(
                alignment: Alignment.centerRight,
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
                    color: isActive
                        ? const Color(0xffFF580E)
                        : const Color(0xffDEBEBF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 3,
                  height: 50,
                  color: isActive
                      ? const Color(0xffFF580E)
                      : Colors.grey.shade300,
                ),
            ],
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: screenWidth * 0.28,
            child: forceEmptyDateSpace
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenWidth * 0.032),
                SizedBox(height: screenWidth * 0.028),
              ],
            )
                : Column(
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
          ),
        ],
      ),
    );
  }

  Widget _orderItemRow(OrderItem item) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductThumb(
            size: screenWidth * 0.16,
            radius: screenWidth * 0.02,
            imageUrl: item.image,
          ),
          SizedBox(width: screenWidth * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName.isEmpty
                      ? S.of(context).unnamedProduct
                      : item.productName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  item.description.isEmpty
                      ? S.of(context).noDescription
                      : item.description,
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenWidth * 0.015),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.025,
                        vertical: screenWidth * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: KprimaryColor.withAlpha((0.15 * 255).round()),
                        borderRadius: BorderRadius.circular(screenWidth * 0.015),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.026,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    if (item.discount > 0)
                      Text(
                        '${S.of(context).discountLabel} ${item.discount}%',
                        style: TextStyle(
                          fontSize: screenWidth * 0.026,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      item.total.toCurrencyText(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.028,
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
    );
  }
}
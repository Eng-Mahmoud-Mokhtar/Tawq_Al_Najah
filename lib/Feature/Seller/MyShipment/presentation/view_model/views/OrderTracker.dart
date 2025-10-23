import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../../Core/Widgets/AppBar.dart';

class OrderTracker extends StatefulWidget {
  const OrderTracker({super.key});

  @override
  State<OrderTracker> createState() => _OrderTrackerState();
}

class _OrderTrackerState extends State<OrderTracker> {
  int currentStep = 0;
  Timer? _timer;

  final List<Map<String, String>> steps = [
    {'title': 'تم التوصيل', 'dayMonth': '17 أكتوبر 2025', 'time': '15:45'},
    {'title': 'في الطريق', 'dayMonth': '17 أكتوبر 2025', 'time': '09:30'},
    {'title': 'تم التحضير', 'dayMonth': '16 أكتوبر 2025', 'time': '21:20'},
    {'title': 'قيد التحضير', 'dayMonth': '16 أكتوبر 2025', 'time': '21:00'},
    {'title': 'تم الاستلام', 'dayMonth': '16 أكتوبر 2025', 'time': '20:50'},
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (currentStep < steps.length - 1) {
        setState(() {
          currentStep++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
              borderRadius: BorderRadius.circular(4),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title:'تفاصيل الطلب'),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'كود المنتج',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.03,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  'MR-255-BF',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.03,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade100, thickness: 10),
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
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
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tawqalnajah/Core/Widgets/AppBar.dart';
import '../../../../../../generated/l10n.dart';
import '../MonthlyOrderCount.dart';
import '../MonthlyProfit.dart';
import '../OrderReport.dart';
import 'ProfitDetailsPage.dart';

class FinancialAccountsPage extends StatefulWidget {
  const FinancialAccountsPage({super.key});

  @override
  State<FinancialAccountsPage> createState() => _FinancialAccountsPageState();
}

class _FinancialAccountsPageState extends State<FinancialAccountsPage> {
  List<OrderReport> allOrders = [];
  List<MonthlyOrderCount> monthlyOrderCounts = [];
  List<MonthlyProfit> monthlyProfits = [];
  int totalOrders = 0;
  double totalRevenue = 0;

  bool _isDataLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      _loadRealOrderData();
      _isDataLoaded = true;
    }
  }

  void _loadRealOrderData() {
    final s = S.of(context); // الآن آمن

    allOrders = [
      OrderReport(orderId: "256", amount: 169.99, code: "JKT-WINTER", quantity: 1, status: s.paid, date: "2025-10-15", month: "أكتوبر"),
      OrderReport(orderId: "261", amount: 214.98, code: "SALE-BF", quantity: 2, status: s.paid, date: "2025-10-14", month: "أكتوبر"),
      OrderReport(orderId: "255", amount: 2049.99, code: "PHONE-X1", quantity: 1, status: s.paid, date: "2025-10-10", month: "أكتوبر"),
      OrderReport(orderId: "257", amount: 99.97, code: "BURGER-DEAL", quantity: 3, status: s.paid, date: "2025-10-08", month: "أكتوبر"),
      OrderReport(orderId: "200", amount: 320.00, code: "SEP-001", quantity: 1, status: s.paid, date: "2025-09-20", month: "سبتمبر"),
      OrderReport(orderId: "201", amount: 180.50, code: "SEP-002", quantity: 2, status: s.paid, date: "2025-09-15", month: "سبتمبر"),
      OrderReport(orderId: "150", amount: 450.00, code: "AUG-001", quantity: 1, status: s.paid, date: "2025-08-10", month: "أغسطس"),
    ];

    totalOrders = allOrders.length;
    totalRevenue = allOrders.fold(0, (sum, o) => sum + o.amount);

    final Map<String, int> orderCountMap = {};
    final Map<String, double> profitMap = {};

    for (var order in allOrders) {
      orderCountMap[order.month] = (orderCountMap[order.month] ?? 0) + 1;
      profitMap[order.month] = (profitMap[order.month] ?? 0) + order.amount;
    }

    monthlyOrderCounts = orderCountMap.entries
        .map((e) => MonthlyOrderCount(month: e.key, count: e.value))
        .toList()
      ..sort((a, b) => _monthToNumber(a.month).compareTo(_monthToNumber(b.month)));

    monthlyProfits = profitMap.entries
        .map((e) => MonthlyProfit(month: e.key, profit: e.value))
        .toList()
      ..sort((a, b) => _monthToNumber(a.month).compareTo(_monthToNumber(b.month)));

    setState(() {}); // إعادة بناء الـ widget بعد تحميل البيانات
  }

  int _monthToNumber(String month) {
    const months = {
      'يناير': 1,
      'فبراير': 2,
      'مارس': 3,
      'أبريل': 4,
      'مايو': 5,
      'يونيو': 6,
      'يوليو': 7,
      'أغسطس': 8,
      'سبتمبر': 9,
      'أكتوبر': 10,
      'نوفمبر': 11,
      'ديسمبر': 12
    };
    return months[month] ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: s.FinancialAccounts),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            _buildTopContainers(screenWidth, s),
            SizedBox(height: screenWidth * 0.05),
            _buildOrdersChart(screenWidth, s),
            SizedBox(height: screenWidth * 0.06),
          ],
        ),
      ),
    );
  }

  Widget _buildTopContainers(double screenWidth, S s) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => ProfitDetailsPage(orders: allOrders))),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                  color: const Color(0xFFFF580E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(screenWidth * 5)),
              child: Icon(Icons.attach_money, color: const Color(0xFFFF580E), size: screenWidth * 0.05)),
          SizedBox(width: screenWidth * 0.02),
          Text(s.FinancialAccounts,
              style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[700], fontWeight: FontWeight.w600)),
          Spacer(),
          Text(totalRevenue.toStringAsFixed(2),
              style: TextStyle(fontSize: screenWidth * 0.038, fontWeight: FontWeight.bold, color: const Color(0xFFFF580E))),
        ]),
      ),
    );
  }

  Widget _buildOrdersChart(double screenWidth, S s) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.monthlyOrders, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          SizedBox(
            height: screenWidth * 0.7,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < monthlyOrderCounts.length) {
                          return Text(monthlyOrderCounts[value.toInt()].month, style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                ),
                borderData: FlBorderData(show: true),
                barGroups: monthlyOrderCounts
                    .asMap()
                    .entries
                    .map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(toY: e.value.count.toDouble(), color: const Color(0xffFF580E), width: screenWidth * 0.04)
                  ],
                ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';

class AccountInfoSeller extends StatefulWidget {
  const AccountInfoSeller({Key? key}) : super(key: key);

  @override
  State<AccountInfoSeller> createState() => _AccountInfoSellerState();
}

class _AccountInfoSellerState extends State<AccountInfoSeller>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        Future.microtask(() {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: SecoundColor,
      appBar: CustomAppBar(title: s.AccountInfo),
      body: Column(
        children: [
          // 🔹 Tabs
          TabBar(
            controller: _tabController,
            labelColor: KprimaryColor,
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.w400,
            ),
            indicatorColor: KprimaryColor,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(text: s.contract_history),
              Tab(text: s.ratings),
            ],
          ),

          // 🔹 محتوى التابات
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildContractTab(context, screenWidth, screenHeight, s),
                _buildRatingsTab(context, screenWidth, screenHeight, s),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildContractTab(
      BuildContext context,
      double screenWidth,
      double screenHeight,
      S s,
      ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.start_date,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: KprimaryText,
                    ),
                  ),
                  Text(
                    "1 / 5 / 2025",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.end_date,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: KprimaryText,
                    ),
                  ),
                  Text(
                    "1/8/2025",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // 🔘 زر التجديد
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.renew_success,style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),)),
                  );
                },
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                  child: Text(
                    s.renew_contract,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1D3A77),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  elevation: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📗 تبويب التقييمات (بدون تعديل)
  Widget _buildRatingsTab(
      BuildContext context,
      double screenWidth,
      double screenHeight,
      S s,
      ) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.overall_rating,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "4.3",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: KprimaryColor,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Icon(Icons.star,
                          color: Colors.amber, size: screenWidth * 0.05),
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(5, (index) {
                  int stars = 5 - index;
                  double percent = [0.6, 0.2, 0.1, 0.07, 0.03][index];
                  return Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.1,
                          child: Row(
                            children: [
                              Text(
                                "$stars ",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.star,
                                  color: Colors.amber,
                                  size: screenWidth * 0.05),
                            ],
                          ),
                        ),
                        Expanded(
                          child: LinearPercentIndicator(
                            lineHeight: 8.0,
                            percent: percent,
                            backgroundColor: Colors.grey[300],
                            progressColor: KprimaryColor,
                            barRadius: const Radius.circular(8),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Text(
                          "${(percent * 100).toStringAsFixed(0)}%",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

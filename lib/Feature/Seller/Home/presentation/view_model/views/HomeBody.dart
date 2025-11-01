import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import 'package:tawqalnajah/Feature/Seller/Notification/presentation/view_model/views/Notification.dart';
import 'package:tawqalnajah/Feature/Seller/RelatedProuducts/presentation/view_model/views/widgets/RelatedSection.dart';
import '../../../../Orders/presentation/view_model/views/FinancialAccountsPage.dart';
import '../../../../Orders/presentation/view_model/views/SellerActiveOrdersPage.dart';
import '../../../../Orders/presentation/view_model/views/SellerCancelledOrdersPage.dart';
import '../../../../Orders/presentation/view_model/views/SellerPendingOrdersPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userImage;
  int currentPage = 0;
  Timer? _timer;

  final List<String> offers = [
    'Assets/black-friday-sales-arrangement-with-tags.jpg',
    'Assets/discount-jacket-podium.jpg',
    'Assets/front-view-screaming-male-chef-holding-up-sale-sign-burger-kitchen.jpg',
    'Assets/hands-holding-modern-smartphone.jpg',
    'Assets/man-giving-some-keys-woman.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        currentPage = (currentPage + 1) % offers.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenWidth * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.065,
                        backgroundColor: Colors.white,
                        backgroundImage: userImage != null
                            ? NetworkImage(userImage!)
                            : null,
                        child: userImage == null
                            ? Icon(
                          Icons.person,
                          color: KprimaryText,
                          size: screenWidth * 0.06,
                        )
                            : null,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).HelloMahmoud,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            S.of(context).happyShopping,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none,
                      color: KprimaryColor,
                      size: screenWidth * 0.07,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                height: screenWidth * 0.4,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: offers.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String img = entry.value;
                    return AnimatedOpacity(
                      opacity: idx == currentPage ? 1.0 : 0.0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.03,
                          ),
                          image: DecorationImage(
                            image: AssetImage(img),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                S.of(context).ourServices,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: KprimaryText,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Wrap(
                spacing: screenWidth * 0.04,
                runSpacing: screenWidth * 0.04,
                alignment: WrapAlignment.center,
                children: [
                  buildServiceItem(
                    icon: Icons.shopping_cart_outlined,
                    title: S.of(context).newOrders,
                    screenWidth: screenWidth,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SellerPendingOrdersPage(),
                        ),
                      );
                    },
                  ),
                  buildServiceItem(
                    icon: Icons.inventory_2_outlined,
                    title: S.of(context).manageOrders,
                    screenWidth: screenWidth,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SellerActiveOrdersPage(),
                        ),
                      );
                    },
                  ),
                  buildServiceItem(
                    icon: Icons.cancel_outlined,
                    title: S.of(context).cancelledOrders,
                    screenWidth: screenWidth,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SellerCancelledOrdersPage(),
                        ),
                      );
                    },
                  ),
                  buildServiceItem(
                    icon: Icons.receipt_long_outlined,
                    title: S.of(context).FinancialAccounts,
                    screenWidth: screenWidth,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FinancialAccountsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              RelatedSection(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildServiceItem({
    required IconData icon,
    required String title,
    required double screenWidth,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (screenWidth - (screenWidth * 0.12)) / 2,
        height: screenWidth * 0.3,
        decoration: BoxDecoration(
          color: KprimaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: KprimaryColor, size: screenWidth * 0.07),
            SizedBox(height: screenWidth * 0.03),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: KprimaryText,
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

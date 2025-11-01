import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tawqalnajah/Feature/Buyer/Search/presentation/view_model/views/widgets/FilterBottomSheet.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/widgets/categoryItem.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/widgets/suggestions.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/widgets/tawqalOffers.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../Notification/presentation/view_model/views/Notification.dart';
import '../../../../Search/presentation/view_model/views/SearchPage.dart';
import '../../../../Search/presentation/view_model/filter_cubit.dart';
import 'HomeStructure.dart';

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

  final List<IconData> icons = [
    Icons.smartphone_sharp,
    Icons.dry_cleaning_outlined,
    Icons.table_restaurant_outlined,
    Icons.sports_volleyball_outlined,
    Icons.kitchen_outlined,
    Icons.health_and_safety_outlined,
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

  void _showFilterBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(screenWidth * 0.05)),
      ),
      builder: (context) {
        return FilterBottomSheet(screenWidth: screenWidth, screenHeight: screenHeight);
      },
    ).then((filters) {
      if (filters != null) {
        context.read<FilterCubit>().updateFilters(
          category: filters['category'],
          country: filters['country'],
          minPrice: filters['minPrice'],
          maxPrice: filters['maxPrice'],
          sortOrder: filters['sortOrder'],
          context: context,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchPage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> labels = [
      S.of(context).electronics,
      S.of(context).fashion,
      S.of(context).furniture,
      S.of(context).toys,
      S.of(context).kitchen,
      S.of(context).health,
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

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
                        backgroundImage: userImage != null ? NetworkImage(userImage!) : null,
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
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () {
                        context.read<BottomNavBCubit>().setIndex(1);
                      },
                      child: SizedBox(
                        height: screenWidth * 0.12, // نفس ارتفاع TextField
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xffE9E9E9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: screenWidth * 0.035),
                              Icon(
                                Icons.search,
                                color: Colors.grey,
                                size: screenWidth * 0.06,
                              ),
                              SizedBox(width: screenWidth * 0.035),
                              Expanded(
                                child: TextField(
                                  enabled: false,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.03,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: S.of(context).search,
                                    hintStyle: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: screenWidth * 0.035,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  GestureDetector(
                    onTap: () => _showFilterBottomSheet(context),
                    child: Container(
                      height: screenWidth * 0.12, // نفس ارتفاع TextField
                      width: screenWidth * 0.12,  // مربع
                      decoration: BoxDecoration(
                        color: KprimaryColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: screenWidth * 0.05,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                S.of(context).categories,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              SizedBox(
                height: screenWidth * 0.2,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: isArabic
                      ? EdgeInsets.only(left: screenWidth * 0.02)
                      : EdgeInsets.only(right: screenWidth * 0.02),
                  itemBuilder: (_, index) => categoryItem(
                    icons[index],
                    labels[index],
                    screenWidth,
                    context,
                  ),
                  separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.02),
                  itemCount: icons.length,
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              SizedBox(
                height: screenWidth * 0.4,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    ...offers.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String img = entry.value;
                      return AnimatedOpacity(
                        opacity: idx == currentPage ? 1.0 : 0.0,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(screenWidth * 0.03),
                            image: DecorationImage(
                              image: AssetImage(img),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    Positioned(
                      bottom: screenHeight * 0.02,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          int activeDot = currentPage % 3;
                          bool isActive = index == activeDot;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01),
                            width: isActive
                                ? screenWidth * 0.04
                                : screenWidth * 0.02,
                            height: screenWidth * 0.02,
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xffFF580E) : Colors.white70,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              TawqalOffersSection(screenWidth: MediaQuery.of(context).size.width,
                  screenHeight: MediaQuery.of(context).size.height),
              SizedBox(height: screenHeight * 0.01),
              SuggestionsSection(  screenWidth: MediaQuery.of(context).size.width,
                screenHeight: MediaQuery.of(context).size.height),
            ],
          ),
        ),
      ),
    );
  }
}

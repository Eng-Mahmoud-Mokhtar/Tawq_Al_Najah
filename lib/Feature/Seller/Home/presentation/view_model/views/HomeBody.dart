import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';
import 'package:tawqalnajah/Feature/Seller/Home/presentation/view_model/views/widgets/RelatedSeaction.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/widgets/HomeHeader.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/home_cubit.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/home_state.dart';
import 'package:tawqalnajah/Feature/Seller/Notification/presentation/view_model/views/Notification.dart';
import '../../../../../Buyer/Home/Data/repo/BannerRepository.dart';
import '../../../../../Buyer/Home/presentation/view_model/bannar_cubit.dart';
import '../../../../../Buyer/Home/presentation/view_model/views/widgets/BannerSection.dart';
import '../../../../../Buyer/Product/Data/Models/ProductModel.dart';
import '../../../../Orders/presentation/view_model/views/SellerNewOrdersPage.dart';
import '../../../../Orders/presentation/view_model/views/FinancialAccountsPage.dart';
import '../../../../Orders/presentation/view_model/views/SellerActiveOrdersPage.dart';
import '../../../../Orders/presentation/view_model/views/SellerCancelledOrdersPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userImage = '';
  String userName = '';

  late final BannerCubit _bannerCubit;
  late final HomeCubit _homeCubit;

  List<String> _banners = [];
  List<ProductModel> _suggestedProducts = [];
  bool _isLoadingBanners = false;
  bool _bannerHasError = false;

  @override
  void initState() {
    super.initState();
    _bannerCubit = BannerCubit(repo: BannerRepository());
    _homeCubit = HomeCubit();
    _loadTokenAndBanners();
    _homeCubit.loadProfile();
  }

  Future<void> _loadTokenAndBanners() async {
    const storage = FlutterSecureStorage();
    try {
      final token = await storage.read(key: 'user_token');
      if (token != null) {
        _bannerCubit.repo.token = token;
      }
      _bannerCubit.loadBanners();
    } catch (e) {
      _bannerCubit.loadBanners();
    }
  }

  @override
  void dispose() {
    _bannerCubit.close();
    _homeCubit.close();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _bannerCubit.loadBanners();
    await _homeCubit.loadProfile();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.35;
    final cardWidth = cardHeight * 0.65;

    return MultiBlocProvider(
      providers: [
        BlocProvider<BannerCubit>.value(value: _bannerCubit),
        BlocProvider<HomeCubit>.value(value: _homeCubit),
      ],
      child: BlocListener<BannerCubit, BannerState>(
        listener: (context, state) {
          if (state is BannerLoading) {
            setState(() {
              _isLoadingBanners = true;
              _bannerHasError = false;
            });
          } else if (state is BannerLoaded) {
            setState(() {
              _isLoadingBanners = false;
              _bannerHasError = false;
              _banners = state.banners;
              _suggestedProducts = state.suggestedProducts;
            });
          } else if (state is BannerError) {
            setState(() {
              _isLoadingBanners = false;
              _bannerHasError = true;
            });
          }
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: Colors.grey[100],
            body: RefreshIndicator(
              color: KprimaryColor,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                primary: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.04),
                    BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, homeState) {
                        return HomeHeader(
                          isLoading: homeState.isProfileLoading,
                          userName: homeState.userName.isEmpty ? userName : homeState.userName,
                          userImage: homeState.userImage.isEmpty ? userImage : homeState.userImage,
                          screenWidth: screenWidth,
                          onNotificationPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsPage(),
                              ),
                            );
                          },
                          onProfileTap: null,
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BannerSection(
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                            banners: _banners,
                            isLoading: _isLoadingBanners,
                            hasError: _bannerHasError,
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

                          // خدمات التاجر
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
                                      builder: (_) => const SellerNewOrdersPage(),
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
                            cardWidth: cardWidth,
                            cardHeight: cardHeight,
                            isLoading: _isLoadingBanners,
                            suggestedProducts: _suggestedProducts,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
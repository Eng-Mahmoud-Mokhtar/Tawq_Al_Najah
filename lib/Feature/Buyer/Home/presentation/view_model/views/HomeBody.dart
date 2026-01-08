import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/widgets/suggestions.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/widgets/tawqalOffers.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/widgets/HomeHeader.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../Buyer/Notification/presentation/view_model/views/Notification.dart';
import '../../../../Categories/presentation/view_model/views/Widgets/CategoryList.dart';
import '../../../../Categories/presentation/view_model/views/CategoryPage.dart';
import '../../../../Product/Data/Models/ProductModel.dart';
import '../../../Data/repo/BannerRepository.dart';
import '../bannar_cubit.dart';
import '../home_state.dart';
import 'HomeStructure.dart';
import 'widgets/BannerSection.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/Data/Model/CategoryModel.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/home_cubit.dart';
import '../../../../Categories/presentation/view_model/views/Widgets/CategoriesHeader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userImage = '';
  String userName = '';
  final List<IconData> icons = [
    Icons.storefront,
    Icons.smartphone_sharp,
    Icons.dry_cleaning_outlined,
    Icons.table_restaurant_outlined,
    Icons.sports_volleyball_outlined,
    Icons.kitchen_outlined,
    Icons.health_and_safety_outlined,
    Icons.book_outlined,

  ];

  late final BannerCubit _bannerCubit;
  late final HomeCubit _homeCubit;
  List<String> _banners = [];
  List<ProductModel> _tawqalProducts = [];
  List<ProductModel> _suggestedProducts = [];
  bool _categoriesHasError = false;
  bool _isLoadingBanners = false;
  bool _bannerHasError = false;

  @override
  void initState() {
    super.initState();
    _bannerCubit = BannerCubit(repo: BannerRepository());
    _homeCubit = HomeCubit();
    _loadTokenAndBanners();
    _homeCubit.loadProfile();
    _homeCubit.loadCategories();
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
      print('Error loading token: $e');
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
    await _homeCubit.loadCategories();
    await Future.delayed(const Duration(seconds: 1));
  }


  void _navigateToCategoryPage(BuildContext context, CategoryModel category, {String? displayLabel}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPage(
          apiName: category.name,
          displayName: displayLabel ?? category.name,
          categoryId: category.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> labels = [
      S.of(context).marketplace,
      S.of(context).electronics,
      S.of(context).fashion,
      S.of(context).furniture,
      S.of(context).toys,
      S.of(context).kitchen,
      S.of(context).health,
      S.of(context).books,
    ];
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
            print('Banners loaded successfully: ${state.banners.length} items');
            setState(() {
              _isLoadingBanners = false;
              _bannerHasError = false;
              _banners = state.banners;
              _tawqalProducts = state.tawqalProducts;
              _suggestedProducts = state.suggestedProducts;
            });
          } else if (state is BannerError) {
            print('Banner error: ${state.message}');
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
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenWidth * 0.06),
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
                    SizedBox(height: screenHeight * 0.02),
                    SearchFilterBar(
                      screenWidth: screenWidth,
                      onSearchTap: () => context.read<BottomNavBCubit>().setIndex(1),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, homeState) {
                        _categoriesHasError = homeState.categoriesHasError;
                        return CategoriesHeader(
                          screenWidth: screenWidth,
                          title: S.of(context).categories,
                          showRefresh: _categoriesHasError,
                          onRefresh: () => context.read<HomeCubit>().loadCategories(),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, homeState) {
                          return CategoryList(
                            categories: homeState.categories,
                            icons: icons,
                            labels: labels,
                            width: screenWidth,
                            onCategoryTap: (category, displayLabelLocal) {
                              _navigateToCategoryPage(context, category, displayLabel: displayLabelLocal);
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: BannerSection(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        banners: _banners,
                        isLoading: _isLoadingBanners,
                        hasError: _bannerHasError,
                      ),
                    ),
                    TawqalOffersSection(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      isLoading: _isLoadingBanners,
                      tawqalProducts: _tawqalProducts,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    SuggestionsSection(
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
            ),
          ),
        ),
      ),
    );
  }
}
class SearchFilterBar extends StatelessWidget {
  final double screenWidth;
  final VoidCallback onSearchTap;

  const SearchFilterBar({
    Key? key,
    required this.screenWidth,
    required this.onSearchTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: onSearchTap,
              child: SizedBox(
                height: screenWidth * 0.12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xffE9E9E9),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(128, 128, 128, 0.2),
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
            onTap: () => context.read<BottomNavBCubit>().setIndex(1),
            child: Container(
              height: screenWidth * 0.12,
              width: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: KprimaryColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(128, 128, 128, 0.2),
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
    );
  }
}

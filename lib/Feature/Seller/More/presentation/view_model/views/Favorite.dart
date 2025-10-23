import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../Home/presentation/view_model/views/HomeStructure.dart';
import '../../../../Product/presentation/view_model/views/widgets/ProductDetailsPage.dart';
import '../../../../cart/presentation/view_model/views/widgets/AdCard.dart';
import '../favorites_cubit.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> with RouteAware {
  final List<Map<String, dynamic>> _pendingRemovals = [];
  RouteObserver<ModalRoute<void>>? _routeObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = RouteObserver<ModalRoute<void>>();
    _routeObserver?.subscribe(this, ModalRoute.of(context)! as ModalRoute<void>);
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPop() {
    if (_pendingRemovals.isNotEmpty) {
      context.read<FavoritesCubit>().removeFavorites(_pendingRemovals);
    }
    super.didPop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final favoriteItems = state.favoriteItems;
        final filteredFavorites = favoriteItems.where((item) {
          return !_pendingRemovals.any((removed) => removed['name'] == item['name']);
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xfffafafa),
          appBar: CustomAppBar(
            title: S.of(context).favoriteProducts,
          ),
          body: filteredFavorites.isEmpty
              ? Center(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "Assets/empty-cart 1.png",
                    width: screenWidth * 0.5,
                    height: screenWidth * 0.5,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    S.of(context).noFavorites,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: KprimaryText,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    S.of(context).exclusiveOffer,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<BottomNavCubit>().setIndex(0);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeStructure(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KprimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: SizedBox(
                        height: screenWidth * 0.12,
                        child: Center(
                          child: Text(
                            S.of(context).browseProducts,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                              color: SecoundColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.15),

                ],
              ),
            ),
          )
              : GridView.builder(
            padding: EdgeInsets.all(screenWidth * 0.04),
            itemCount: filteredFavorites.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: screenWidth * 0.04,
              crossAxisSpacing: screenWidth * 0.04,
              childAspectRatio: 0.53,
            ),
            itemBuilder: (_, index) {
              return Stack(
                children: [
                  AdCard(
                    ad: filteredFavorites[index],
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsPage(ad: filteredFavorites[index]),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

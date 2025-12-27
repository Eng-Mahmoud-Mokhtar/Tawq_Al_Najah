import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tawqalnajah/Feature/Buyer/Product/presentation/view_model/favorite_cubit.dart';
import 'package:tawqalnajah/Feature/Buyer/Product/presentation/view_model/views/ProductDetailsPage.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/Widgets/buildImageError.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../Home/presentation/view_model/views/HomeStructure.dart';
import '../../../../Home/presentation/view_model/views/widgets/ImageHome.dart';
import '../../../../Product/Data/Models/ProductModel.dart';
import '../../../../Product/presentation/view_model/cart_cubit.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FavoritesPageState {
  final List<ProductModel> products;
  final bool isLoading;
  final Map<int, bool> favoriteLoading;
  final Map<int, bool> cartLoading;
  final String? errorMessage;
  final Set<int> serverFavoriteIds;

  FavoritesPageState({
    required this.products,
    required this.isLoading,
    Map<int, bool>? favoriteLoading,
    Map<int, bool>? cartLoading,
    this.errorMessage,
    Set<int>? serverFavoriteIds,
  })  : favoriteLoading = favoriteLoading ?? {},
        cartLoading = cartLoading ?? {},
        serverFavoriteIds = serverFavoriteIds ?? {};

  FavoritesPageState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    Map<int, bool>? favoriteLoading,
    Map<int, bool>? cartLoading,
    String? errorMessage,
    Set<int>? serverFavoriteIds,
  }) {
    return FavoritesPageState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      favoriteLoading: favoriteLoading ?? Map<int, bool>.from(this.favoriteLoading),
      cartLoading: cartLoading ?? Map<int, bool>.from(this.cartLoading),
      errorMessage: errorMessage,
      serverFavoriteIds: serverFavoriteIds ?? this.serverFavoriteIds,
    );
  }
}

class FavoritesPageCubit extends Cubit<FavoritesPageState> {
  final FavoriteCubit favoriteCubit;
  final CartCubit cartCubit;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  FavoritesPageCubit({
    required this.favoriteCubit,
    required this.cartCubit,
  }) : super(FavoritesPageState(products: [], isLoading: true, errorMessage: null, serverFavoriteIds: {}));

  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(state.copyWith(isLoading: true));
      return;
    }

    try {
      final token = await _storage.read(key: 'user_token');
      if (token == null) {
        emit(state.copyWith(products: [], isLoading: true));
        return;
      }

      _dio.options.headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await _dio.get(
        'https://toknagah.viking-iceland.online/api/user/products-favorite',
        options: Options(validateStatus: (status) => status != null && status < 500),
      );

      dynamic json = response.data;
      if (json is String) json = jsonDecode(json);

      if (response.statusCode == 401) {
        emit(state.copyWith(products: [], isLoading: true));
        return;
      }

      final List<dynamic> list = (json['data'] != null && json['data']['data'] is List)
          ? json['data']['data']
          : [];

      final List<ProductModel> loaded = [];
      final Set<int> serverIds = {};

      for (var item in list) {
        if (item is Map<String, dynamic>) {
          try {
            final product = ProductModel.fromJson(item);
            loaded.add(product);
            serverIds.add(product.id);
          } catch (e) {}
        }
      }

      favoriteCubit.syncWithServerFavorites(serverIds);

      emit(state.copyWith(
        products: loaded,
        isLoading: false,
        errorMessage: null,
        serverFavoriteIds: serverIds,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: true));
    }
  }

  Future<void> toggleFavorite(int productId) async {
    final favLoading = Map<int, bool>.from(state.favoriteLoading);
    if (favLoading[productId] == true) return;

    favLoading[productId] = true;
    emit(state.copyWith(favoriteLoading: favLoading));

    try {
      await favoriteCubit.toggleFavoriteWithApi(productId);
      final updatedProducts = List<ProductModel>.from(state.products)
        ..removeWhere((p) => p.id == productId);
      final updatedServerIds = Set<int>.from(state.serverFavoriteIds)..remove(productId);
      emit(state.copyWith(
        products: updatedProducts,
        serverFavoriteIds: updatedServerIds,
      ));
    } catch (e) {} finally {
      favLoading[productId] = false;
      emit(state.copyWith(favoriteLoading: favLoading));
    }
  }

  Future<void> toggleCart(int productId, Map<String, dynamic> productData) async {
    final cartLoading = Map<int, bool>.from(state.cartLoading);
    if (cartLoading[productId] == true) return;

    cartLoading[productId] = true;
    emit(state.copyWith(cartLoading: cartLoading));

    try {
      await cartCubit.toggleCartWithApi(productId, productData);
    } catch (e) {} finally {
      cartLoading[productId] = false;
      emit(state.copyWith(cartLoading: cartLoading));
    }
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favCubit = context.read<FavoriteCubit>();
    final cartCubit = context.read<CartCubit>();

    return BlocProvider(
      create: (_) {
        final c = FavoritesPageCubit(favoriteCubit: favCubit, cartCubit: cartCubit);
        c.loadFavorites();
        Future.microtask(() {
          cartCubit.loadCart();
          favCubit.loadFavorites();
        });
        return c;
      },
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  void _goToDetails(int id, Map<String, dynamic> data, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetails(productId: id, initialProductData: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xfffafafa),
        appBar: CustomAppBar(title: S.of(context).favoriteProducts),
        body: BlocBuilder<FavoritesPageCubit, FavoritesPageState>(
          builder: (context, state) {
            if (state.isLoading) return _buildShimmer(w);
            if (state.products.isEmpty) return _buildEmptyState(context, w, h);

            return GridView.builder(
              padding: EdgeInsets.all(w * 0.04),
              itemCount: state.products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: w * 0.04,
                crossAxisSpacing: w * 0.04,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (_, index) {
                final p = state.products[index];
                final map = p.toMap();

                return _buildCard(context, p, map, w); // تم تمرير ProductModel أيضًا
              },
            );
          },
        ),
      ),
    );
  }

  // تم تعديل الدالة لتأخذ ProductModel بالإضافة إلى Map
  Widget _buildCard(BuildContext context, ProductModel product, Map<String, dynamic> map, double w) {
    final cw = (w - 48) / 2;
    final ch = cw * 1.4;

    // حساب السعر والعملة بنفس طريقة TawqalOffersPage
    final price = product.priceAfterDiscount > 0 ? product.priceAfterDiscount : product.price;
    final currency = product.currencyType?.isNotEmpty == true
        ? product.currencyType!
        : S.of(context).SYP;

    return GestureDetector(
      onTap: () => _goToDetails(product.id, map, context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(cw * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(cw * 0.05)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: map['images'] != null && (map['images'] as List).isNotEmpty
                          ? ImageHome.getValidImageUrl((map['images'] as List)[0])
                          : '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorWidget: (_, __, ___) => buildImageErrorPlaceholder(context, cw, ch * 0.4),
                    ),
                    Positioned(
                      top: cw * 0.05,
                      left: cw * 0.05,
                      child: BlocSelector<FavoritesPageCubit, FavoritesPageState, bool>(
                        selector: (state) => state.favoriteLoading[product.id] ?? false,
                        builder: (context, isFavoriteLoading) {
                          final isFav = context.select<FavoritesPageCubit, bool>(
                                (c) => c.state.serverFavoriteIds.contains(product.id),
                          );
                          return GestureDetector(
                            onTap: () => context.read<FavoritesPageCubit>().toggleFavorite(product.id),
                            child: Container(
                              padding: EdgeInsets.all(cw * 0.03),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              child: isFavoriteLoading
                                  ? SizedBox(
                                width: cw * 0.06,
                                height: cw * 0.06,
                                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                                  : Icon(
                                Icons.favorite,
                                color: const Color(0xffFF580E),
                                size: cw * 0.1,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(cw * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        product.name,
                        style: TextStyle(fontSize: ch * 0.05, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: ch * 0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        product.description,
                        style: TextStyle(fontSize: ch * 0.045, color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: ch * 0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        // استخدام المتغيرات الجديدة للسعر والعملة
                        "$price $currency",
                        style: TextStyle(fontSize: ch * 0.05, fontWeight: FontWeight.bold, color: const Color(0xffFF580E)),
                      ),
                    ),
                    const Spacer(),
                    BlocSelector<FavoritesPageCubit, FavoritesPageState, bool>(
                      selector: (state) => state.cartLoading[product.id] ?? false,
                      builder: (context, isCartLoading) {
                        final isAdded = context.select<CartCubit, bool>((c) => c.state.cartIds.contains(product.id));
                        return ElevatedButton(
                          onPressed: isCartLoading ? null : () => context.read<FavoritesPageCubit>().toggleCart(product.id, map),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAdded ? Colors.grey.withOpacity(0.3) : const Color(0xffFF580E),
                            minimumSize: Size(double.infinity, ch * 0.14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(cw * 0.15),
                            ),
                          ),
                          child: isCartLoading
                              ? SizedBox(
                            width: ch * 0.03,
                            height: ch * 0.03,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : Text(
                            isAdded ? S.of(context).addedToCart : S.of(context).AddtoCart,
                            style: TextStyle(fontSize: ch * 0.045, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(double w) {
    final cw = (w - 48) / 2;
    return GridView.builder(
      padding: EdgeInsets.all(w * 0.04),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: w * 0.04,
        crossAxisSpacing: w * 0.04,
        childAspectRatio: 0.65,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cw * 0.05),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, double w, double h) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(w * 0.04),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "Assets/empty-cart 1.png",
              width: w * 0.5,
              height: w * 0.5,
            ),
            SizedBox(height: h * 0.03),
            Text(
              S.of(context).noFavorites,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: w * 0.035, fontWeight: FontWeight.bold, color: KprimaryText),
            ),
            SizedBox(height: h * 0.01),
            Text(
              S.of(context).exclusiveOffer,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: w * 0.03, color: Colors.grey[700]),
            ),
            SizedBox(height: h * 0.02),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeStructure()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: KprimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: SizedBox(
                  height: w * 0.12,
                  child: Center(
                    child: Text(
                      S.of(context).browseProducts,
                      style: TextStyle(fontSize: w * 0.03, fontWeight: FontWeight.bold, color: SecoundColor),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: h * 0.15),
          ],
        ),
      ),
    );
  }
}
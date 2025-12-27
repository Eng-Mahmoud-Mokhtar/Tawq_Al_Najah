import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../Product/Data/Models/ProductModel.dart';
import '../../../Product/presentation/view_model/cart_cubit.dart';
import '../../../Product/presentation/view_model/favorite_cubit.dart';
import 'FavoritesPageState.dart';

class FavoritesPageCubit extends Cubit<FavoritesPageState> {
  final FavoriteCubit favoriteCubit;
  final CartCubit cartCubit;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  FavoritesPageCubit({
    required this.favoriteCubit,
    required this.cartCubit,
  }) : super(FavoritesPageState(products: [], isLoading: true, errorMessage: null));

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
      for (var item in list) {
        if (item is Map<String, dynamic>) {
          try {
            loaded.add(ProductModel.fromJson(item));
          } catch (e) {
            print("❌ Failed parsing product: $e");
          }
        }
      }

      emit(state.copyWith(products: loaded, isLoading: false, errorMessage: null));
    } catch (e) {
      print("❌ Load favorites error: $e");
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

      final newProducts = List<ProductModel>.from(state.products)
        ..removeWhere((p) => p.id == productId);

      favLoading[productId] = false;
      emit(state.copyWith(products: newProducts, favoriteLoading: favLoading));
    } catch (e) {
      print("❌ Toggle favorite error: $e");
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
    } catch (e) {
      print("❌ Toggle cart error: $e");
    } finally {
      cartLoading[productId] = false;
      emit(state.copyWith(cartLoading: cartLoading));
    }
  }
}

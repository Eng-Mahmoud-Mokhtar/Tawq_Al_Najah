import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState(
      cartIds: {},
      currentSellerId: null,
      isLoading: false,
      errorMessage: null
  )) {
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cart = prefs.getStringList('cart_added_ids') ?? [];
      final sellerId = prefs.getInt('cart_seller_id');

      final cartIds = <int>{};
      for (var id in cart) {
        final parsedId = int.tryParse(id);
        if (parsedId != null) {
          cartIds.add(parsedId);
        }
      }

      emit(state.copyWith(
        cartIds: cartIds,
        currentSellerId: sellerId,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      print('Error loading cart: $e');
      emit(state.copyWith(
        errorMessage: null,
        isLoading: false,
      ));
    }
  }

  Future<void> toggleCart(int productId, int? sellerId) async {
    if (state.cartIds.contains(productId)) {
      return;
    }

    final newCartIds = Set<int>.from(state.cartIds);

    if (state.currentSellerId != null &&
        state.currentSellerId != sellerId &&
        newCartIds.isNotEmpty) {
      return;
    }

    newCartIds.add(productId);

    emit(state.copyWith(
      cartIds: newCartIds,
      currentSellerId: sellerId ?? state.currentSellerId,
      isLoading: false,
      errorMessage: null,
    ));

    await _saveCartLocal(newCartIds, sellerId ?? state.currentSellerId);
  }

  Future<void> toggleCartWithApi(int productId, Map<String, dynamic> productData) async {
    if (state.cartIds.contains(productId)) {
      return;
    }

    final newCartIds = Set<int>.from(state.cartIds);
    final productSellerId = _parseSellerId(productData['saller_id']);

    if (state.currentSellerId != null &&
        state.currentSellerId != productSellerId &&
        newCartIds.isNotEmpty) {
      return;
    }

    newCartIds.add(productId);

    emit(state.copyWith(
      cartIds: newCartIds,
      currentSellerId: productSellerId ?? state.currentSellerId,
      isLoading: false,
      errorMessage: null,
    ));

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'user_token');
      if (token == null) {
        await _saveCartLocal(newCartIds, productSellerId ?? state.currentSellerId);
        return;
      }

      final dio = Dio();
      dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await dio.post(
        'https://toknagah.viking-iceland.online/api/user/add-to-cart',
        data: {"product_id": productId, "quantity": 1},
        options: Options(validateStatus: (status) => true),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final responseData = response.data;
        if (responseData is Map && responseData['message'] != null) {
          emit(state.copyWith(
            errorMessage: responseData['message'].toString(),
            isLoading: false,
          ));
        }
      } else {
        emit(state.copyWith(errorMessage: null, isLoading: false));
      }

    } catch (e) {
      if (e is DioException &&
          (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout)) {
        emit(state.copyWith(
          errorMessage: 'Connection error',
          isLoading: false,
        ));
      }
    }

    await _saveCartLocal(newCartIds, productSellerId ?? state.currentSellerId);
  }

  Future<void> removeProduct(int productId) async {
    final newCartIds = Set<int>.from(state.cartIds);

    if (!newCartIds.contains(productId)) {
      return;
    }

    newCartIds.remove(productId);

    final newSellerId = newCartIds.isEmpty ? null : state.currentSellerId;

    emit(state.copyWith(
      cartIds: newCartIds,
      currentSellerId: newSellerId,
      isLoading: false,
      errorMessage: null,
    ));

    await _saveCartLocal(newCartIds, newSellerId);
  }

  Future<void> clearCart() async {
    emit(CartState(
        cartIds: {},
        currentSellerId: null,
        isLoading: false,
        errorMessage: null
    ));

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_added_ids');
    await prefs.remove('cart_seller_id');
  }

  Future<void> syncWithServerCart(Set<int> serverCartProductIds, {int? sellerId}) async {
    emit(state.copyWith(
      cartIds: serverCartProductIds,
      currentSellerId: sellerId ?? state.currentSellerId,
      isLoading: false,
      errorMessage: null,
    ));

    await _saveCartLocal(serverCartProductIds, sellerId ?? state.currentSellerId);
  }

  Future<void> _saveCartLocal(Set<int> ids, int? sellerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('cart_added_ids', ids.map((e) => e.toString()).toList());

      if (sellerId != null) {
        await prefs.setInt('cart_seller_id', sellerId);
      } else {
        await prefs.remove('cart_seller_id');
      }
    } catch (e) {
      print('Error saving cart locally: $e');
    }
  }

  int? _parseSellerId(dynamic sellerId) {
    if (sellerId == null) return null;
    if (sellerId is int) return sellerId;
    if (sellerId is String) return int.tryParse(sellerId);
    return null;
  }

  bool isProductInCart(int productId) {
    return state.cartIds.contains(productId);
  }

  int getCartCount() {
    return state.cartIds.length;
  }

  Set<int> getAllCartProductIds() {
    return Set<int>.from(state.cartIds);
  }

  void updateSellerId(int? sellerId) {
    emit(state.copyWith(
      currentSellerId: sellerId,
      isLoading: false,
      errorMessage: null,
    ));
  }

  void setLoading(bool isLoading) {
    emit(state.copyWith(
      isLoading: isLoading,
    ));
  }

  void setErrorMessage(String? errorMessage) {
    emit(state.copyWith(
      errorMessage: errorMessage,
    ));
  }

  void clearErrorMessage() {
    emit(state.copyWith(
      errorMessage: null,
    ));
  }
}

class CartState {
  final Set<int> cartIds;
  final int? currentSellerId;
  final bool isLoading;
  final String? errorMessage;

  CartState({
    required this.cartIds,
    required this.currentSellerId,
    this.isLoading = false,
    this.errorMessage,
  });

  CartState copyWith({
    Set<int>? cartIds,
    int? currentSellerId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CartState(
      cartIds: cartIds ?? this.cartIds,
      currentSellerId: currentSellerId ?? this.currentSellerId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
import 'package:bloc/bloc.dart';
import 'UserCartState.dart';

class UserCartBloc extends Cubit<UserCartState> {
  UserCartBloc() : super(UserCartState(cartItems: []));

  void setLoading(bool isLoading) {
    emit(state.copyWith(isLoading: isLoading));
  }

  void setProcessing(bool isProcessing) {
    emit(state.copyWith(isProcessing: isProcessing));
  }

  void setErrorMessage(String? errorMessage) {
    emit(state.copyWith(errorMessage: errorMessage));
  }

  void setUpdatingItemId(String? itemId) {
    emit(state.copyWith(updatingItemId: itemId));
  }

  void setDeletingItem(bool isDeleting) {
    emit(state.copyWith(isDeletingItem: isDeleting));
  }

  void updateCartData({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double shipping,
    required double total,
    required String currency,
    required int cartId,
  }) {
    emit(state.copyWith(
      cartItems: items,
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      currency: currency,
      cartId: cartId,
      isLoading: false,
      errorMessage: null,
      updatingItemId: null,
      isDeletingItem: false,
    ));
  }

  void updateItemQuantity(String itemId, int newQuantity) {
    final updatedItems = List<Map<String, dynamic>>.from(state.cartItems);
    bool itemUpdated = false;

    for (int i = 0; i < updatedItems.length; i++) {
      if (updatedItems[i]['api_data']?['id_item']?.toString() == itemId) {
        final updatedItem = Map<String, dynamic>.from(updatedItems[i]);
        updatedItem['quantity'] = newQuantity;
        updatedItems[i] = updatedItem;
        itemUpdated = true;
        break;
      }
    }

    if (!itemUpdated) return;

    final newTotals = _calculateTotals(updatedItems, state.shipping);

    emit(state.copyWith(
      cartItems: updatedItems,
      subtotal: newTotals['subtotal'] ?? 0.0,
      shipping: newTotals['shipping'] ?? 0.0,
      total: newTotals['total'] ?? 0.0,
      errorMessage: null,
      isDeletingItem: false,
    ));
  }

  void removeItem(String itemId, double currentShipping) {
    final updatedItems = List<Map<String, dynamic>>.from(state.cartItems)
      ..removeWhere((item) => item['api_data']?['id_item']?.toString() == itemId);

    final newTotals = _calculateTotals(updatedItems, currentShipping);

    emit(state.copyWith(
      cartItems: updatedItems,
      subtotal: newTotals['subtotal'] ?? 0.0,
      shipping: newTotals['shipping'] ?? 0.0,
      total: newTotals['total'] ?? 0.0,
      errorMessage: null,
      updatingItemId: null,
      isDeletingItem: false,
    ));
  }

  void restoreItem(String itemId, int quantity) {
    final updatedItems = List<Map<String, dynamic>>.from(state.cartItems);
    bool found = false;

    for (int i = 0; i < updatedItems.length; i++) {
      if (updatedItems[i]['api_data']?['id_item']?.toString() == itemId) {
        final updatedItem = Map<String, dynamic>.from(updatedItems[i]);
        updatedItem['quantity'] = quantity;
        updatedItems[i] = updatedItem;
        found = true;
        break;
      }
    }

    if (found) {
      final newTotals = _calculateTotals(updatedItems, state.shipping);

      emit(state.copyWith(
        cartItems: updatedItems,
        subtotal: newTotals['subtotal'] ?? 0.0,
        shipping: newTotals['shipping'] ?? 0.0,
        total: newTotals['total'] ?? 0.0,
        errorMessage: null,
        updatingItemId: null,
        isDeletingItem: false,
      ));
    }
  }

  void addNewItemToCart(Map<String, dynamic> newItem) {
    final updatedItems = List<Map<String, dynamic>>.from(state.cartItems);
    updatedItems.add(newItem);

    final newTotals = _calculateTotals(updatedItems, state.shipping);

    emit(state.copyWith(
      cartItems: updatedItems,
      subtotal: newTotals['subtotal'] ?? 0.0,
      shipping: newTotals['shipping'] ?? 0.0,
      total: newTotals['total'] ?? 0.0,
      errorMessage: null,
      updatingItemId: null,
      isDeletingItem: false,
    ));
  }

  Map<String, double> _calculateTotals(List<Map<String, dynamic>> items, double currentShipping) {
    double subtotal = 0.0;

    for (var item in items) {
      try {
        final priceRaw = item['ad']?['price_after_discount'] ?? item['ad']?['price'] ?? 0;
        final price = double.tryParse(priceRaw.toString()) ?? 0.0;

        final quantityRaw = item['quantity'] ?? 1;
        final quantity = int.tryParse(quantityRaw.toString()) ?? 1;

        subtotal += price * quantity;
      } catch (e) {
        // تجاهل أي خطأ في العنصر
      }
    }

    final shipping = currentShipping > 0 ? currentShipping : 0.0;
    final total = subtotal + shipping;

    return {
      'subtotal': subtotal,
      'shipping': shipping,
      'total': total,
    };
  }

  Set<int> getProductIds() {
    final Set<int> productIds = {};
    for (var item in state.cartItems) {
      try {
        final idStr = item['api_data']?['product_id']?.toString();
        final id = idStr != null ? int.tryParse(idStr) : null;
        if (id != null) productIds.add(id);
      } catch (e) {}
    }
    return productIds;
  }
}

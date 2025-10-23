import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState([]));

  void addToCart(Map<String, dynamic> ad) {
    final newCart = List<Map<String, dynamic>>.from(state.cartItems);
    final index = newCart.indexWhere((item) =>
    item['ad']['name'] == ad['name']);
    if (index != -1) {
      newCart[index]['quantity'] += 1;
    } else {
      newCart.add({'ad': ad, 'quantity': 1});
    }
    emit(CartState(newCart));
  }

  void increment(Map<String, dynamic> ad) {
    final newCart = List<Map<String, dynamic>>.from(state.cartItems);
    final index = newCart.indexWhere((item) =>
    item['ad']['name'] == ad['name']);
    if (index != -1) {
      newCart[index]['quantity'] += 1;
      emit(CartState(newCart));
    }
  }

  void decrement(Map<String, dynamic> ad) {
    final newCart = List<Map<String, dynamic>>.from(state.cartItems);
    final index = newCart.indexWhere((item) =>
    item['ad']['name'] == ad['name']);

    if (index != -1) {
      if (newCart[index]['quantity'] > 1) {
        newCart[index]['quantity'] -= 1;
      }
      emit(CartState(newCart));
    }
  }


  void removeFromCart(Map<String, dynamic> ad) {
    final newCart = List<Map<String, dynamic>>.from(state.cartItems);
    newCart.removeWhere((item) => item['ad']['name'] == ad['name']);
    emit(CartState(newCart));
  }

  bool isInCart(Map<String, dynamic> ad) {
    return state.cartItems.any((item) => item['ad']['name'] == ad['name']);
  }
}
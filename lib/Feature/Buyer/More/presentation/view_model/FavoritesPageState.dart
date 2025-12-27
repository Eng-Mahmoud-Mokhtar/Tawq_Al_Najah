import '../../../Product/Data/Models/ProductModel.dart';

class FavoritesPageState {
  final List<ProductModel> products;
  final bool isLoading;
  final Map<int, bool> favoriteLoading;
  final Map<int, bool> cartLoading;
  final String? errorMessage;

  FavoritesPageState({
    required this.products,
    required this.isLoading,
    Map<int, bool>? favoriteLoading,
    Map<int, bool>? cartLoading,
    this.errorMessage,
  })  : favoriteLoading = favoriteLoading ?? {},
        cartLoading = cartLoading ?? {};

  FavoritesPageState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    Map<int, bool>? favoriteLoading,
    Map<int, bool>? cartLoading,
    String? errorMessage,
  }) {
    return FavoritesPageState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      favoriteLoading: favoriteLoading ?? Map<int, bool>.from(this.favoriteLoading),
      cartLoading: cartLoading ?? Map<int, bool>.from(this.cartLoading),
      errorMessage: errorMessage,
    );
  }
}

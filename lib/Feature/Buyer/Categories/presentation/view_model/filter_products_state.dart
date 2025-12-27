part of 'filter_products_cubit.dart';

@immutable
class FilterProductsState {
  final double minPrice;
  final double maxPrice;
  const FilterProductsState({required this.minPrice, required this.maxPrice});
  FilterProductsState copyWith({double? minPrice, double? maxPrice}) {
    return FilterProductsState(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}


part of 'FilterRelated_cubit.dart';

@immutable
class FilterState {
  final String? countryId;
  final String? country;
  final double minPrice;
  final double maxPrice;
  final String sortOrder;

  const FilterState({
    this.countryId,
    this.country,
    required this.minPrice,
    required this.maxPrice,
    required this.sortOrder,
  });

  FilterState copyWith({
    String? countryId,
    String? country,
    double? minPrice,
    double? maxPrice,
    String? sortOrder,
  }) {
    return FilterState(
      countryId: countryId ?? this.countryId,
      country: country ?? this.country,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

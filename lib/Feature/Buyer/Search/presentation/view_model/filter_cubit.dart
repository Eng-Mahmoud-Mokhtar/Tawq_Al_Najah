import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import '../../../../../../generated/l10n.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit()
      : super(FilterState(
    categoryId: null,
    category: null, // null = show all
    countryId: null,
    country: null,  // null = show all
    minPrice: 0,
    maxPrice: 100000,
    sortOrder: 'Lowest Price',
  ));

  void updateFilters({
    required BuildContext context,
    String? categoryId,
    String? category,
    String? countryId,
    String? country,
    double? minPrice,
    double? maxPrice,
    String? sortOrder,
  }) {
    print(
        'Updating filters: categoryId=$categoryId, category=$category, countryId=$countryId, country=$country, '
            'minPrice=$minPrice, maxPrice=$maxPrice, sortOrder=$sortOrder'); // Debug

    emit(FilterState(
      categoryId: categoryId,
      category: category,
      countryId: countryId,
      country: country,
      minPrice: minPrice ?? state.minPrice,
      maxPrice: maxPrice ?? state.maxPrice,
      sortOrder: sortOrder ?? state.sortOrder,
    ));
  }

  void resetFilters(BuildContext context) {
    print('Resetting filters'); // Debug
    emit(FilterState(
      categoryId: null,
      category: null,
      countryId: null,
      country: null,
      minPrice: 0,
      maxPrice: 100000,
      sortOrder: S.of(context).lowestPrice,
    ));
  }
}

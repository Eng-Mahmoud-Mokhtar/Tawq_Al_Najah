import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/l10n.dart';
part 'FilterRelated_state.dart';

class FilterRelatedCubit extends Cubit<FilterState> {
  FilterRelatedCubit()
      : super(FilterState(
    countryId: null,
    country: null, // null = show all
    minPrice: 0,
    maxPrice: 100000,
    sortOrder: 'Lowest Price',
  ));

  void updateFilters({
    required BuildContext context,
    String? countryId,
    String? country,
    double? minPrice,
    double? maxPrice,
    String? sortOrder,
  }) {
    print(
        'Updating filters: countryId=$countryId, country=$country, minPrice=$minPrice, maxPrice=$maxPrice, sortOrder=$sortOrder'); // Debug

    emit(FilterState(
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
      countryId: null,
      country: null,
      minPrice: 0,
      maxPrice: 100000,
      sortOrder: S.of(context).lowestPrice,
    ));
  }
}

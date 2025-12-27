import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
part 'filter_products_state.dart';

const double kFilterMaxPrice = 10000;

class FilterProductsCubit extends Cubit<FilterProductsState> {
  FilterProductsCubit() : super(FilterProductsState(minPrice: 0, maxPrice: kFilterMaxPrice));
  void updateFilters({double? minPrice, double? maxPrice}) {
    emit(
      FilterProductsState(
        minPrice: minPrice ?? state.minPrice,
        maxPrice: maxPrice ?? state.maxPrice,
      ),
    );
  }

  void resetFilters() {
    emit(FilterProductsState(minPrice: 0, maxPrice: kFilterMaxPrice));
  }
}

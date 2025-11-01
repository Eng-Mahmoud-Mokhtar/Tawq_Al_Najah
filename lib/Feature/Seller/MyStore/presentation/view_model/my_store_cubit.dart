import 'package:flutter_bloc/flutter_bloc.dart';

import 'my_store_state.dart';

class MyStoreCubit extends Cubit<MyStoreState> {
  MyStoreCubit() : super(MyStoreState([]));

  void addAd(Map<String, dynamic> ad) {
    final updated = [...state.ads, ad];
    emit(MyStoreState(updated));
  }

  void updateAd(int index, Map<String, dynamic> updatedAd) {
    final updated = List<Map<String, dynamic>>.from(state.ads);
    updated[index] = updatedAd;
    emit(MyStoreState(updated));
  }

  void deleteAd(int index) {
    final updated = List<Map<String, dynamic>>.from(state.ads)..removeAt(index);
    emit(MyStoreState(updated));
  }

  void refreshAd(int index) {
    final updated = List<Map<String, dynamic>>.from(state.ads);
    emit(MyStoreState(updated));
  }

  void loadAds(List<Map<String, dynamic>> ads) {
    emit(MyStoreState(ads));
  }
}
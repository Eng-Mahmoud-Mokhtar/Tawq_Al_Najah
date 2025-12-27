import 'package:flutter_bloc/flutter_bloc.dart';

import 'MyPosts_state.dart';

class MyPostsCubit extends Cubit<MyPostsState> {
  MyPostsCubit() : super(MyPostsState([]));

  void addAd(Map<String, dynamic> ad) {
    final updated = [...state.ads, ad];
    emit(MyPostsState(updated));
  }

  void updateAd(int index, Map<String, dynamic> updatedAd) {
    final updated = List<Map<String, dynamic>>.from(state.ads);
    updated[index] = updatedAd;
    emit(MyPostsState(updated));
  }

  void deleteAd(int index) {
    final updated = List<Map<String, dynamic>>.from(state.ads)..removeAt(index);
    emit(MyPostsState(updated));
  }

  void refreshAd(int index) {
    final updated = List<Map<String, dynamic>>.from(state.ads);
    emit(MyPostsState(updated));
  }

  void loadAds(List<Map<String, dynamic>> ads) {
    emit(MyPostsState(ads));
  }
}
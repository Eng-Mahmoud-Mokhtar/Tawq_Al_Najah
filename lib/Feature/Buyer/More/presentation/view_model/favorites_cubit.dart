import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesState([]));

  void toggleFavorite(Map<String, dynamic> ad) {
    final newFavorites = List<Map<String, dynamic>>.from(state.favoriteItems);
    if (newFavorites.any((item) => item['name'] == ad['name'])) {
      newFavorites.removeWhere((item) => item['name'] == ad['name']);
    } else {
      newFavorites.add(ad);
    }
    emit(FavoritesState(newFavorites));
  }

  void removeFavorites(List<Map<String, dynamic>> itemsToRemove) {
    final newFavorites = List<Map<String, dynamic>>.from(state.favoriteItems);
    for (var ad in itemsToRemove) {
      newFavorites.removeWhere((item) => item['name'] == ad['name']);
    }
    emit(FavoritesState(newFavorites));
  }
}

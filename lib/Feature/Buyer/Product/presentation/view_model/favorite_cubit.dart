import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteCubit extends Cubit<Set<int>> {
  FavoriteCubit() : super({}) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final fav = prefs.getStringList('favorite_ids') ?? [];
      emit(fav.map(int.parse).toSet());
    } catch (e) {
      emit({});
    }
  }

  Future<void> toggleFavorite(int productId) async {
    try {
      final newFavorites = Set<int>.from(state);
      if (newFavorites.contains(productId)) {
        newFavorites.remove(productId);
      } else {
        newFavorites.add(productId);
      }
      emit(newFavorites);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'favorite_ids',
        newFavorites.map((e) => e.toString()).toList(),
      );
    } catch (e) {}
  }

  Future<void> toggleFavoriteWithApi(int productId) async {
    final newFavorites = Set<int>.from(state);

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'user_token');

      if (token != null) {
        final dio = Dio();
        dio.options.headers['Authorization'] = 'Bearer $token';

        final response = await dio.get(
          'https://toknagah.viking-iceland.online/api/user/products/$productId/favorite',
          options: Options(validateStatus: (status) => status != null && status < 500),
        );

        if (response.statusCode == 200 && response.data != null) {
          final message = response.data['message']?.toString().toLowerCase() ?? "";

          if (message.contains('add') || message.contains('added')) {
            newFavorites.add(productId);
          } else if (message.contains('remove') || message.contains('removed')) {
            newFavorites.remove(productId);
          } else {
            if (newFavorites.contains(productId)) {
              newFavorites.remove(productId);
            } else {
              newFavorites.add(productId);
            }
          }

          emit(newFavorites);
        }
      }
    } catch (e) {
      emit(newFavorites);
    } finally {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(
          'favorite_ids',
          newFavorites.map((e) => e.toString()).toList(),
        );
      } catch (e) {}
    }
  }

  Future<void> syncWithServerFavorites(Set<int> serverFavorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        'favorite_ids',
        serverFavorites.map((e) => e.toString()).toList(),
      );
      emit(serverFavorites);
    } catch (e) {}
  }
}
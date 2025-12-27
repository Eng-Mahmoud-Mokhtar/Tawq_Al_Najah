import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../Data/Model/CategoryModel.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/widgets/ImageHome.dart';
import 'home_state.dart' as hs;

class HomeCubit extends Cubit<hs.HomeState> {
  HomeCubit() : super(hs.HomeState.initial());

  Future<void> loadProfile() async {
    emit(state.copyWith(isProfileLoading: true));
    const storage = FlutterSecureStorage();
    const profileUrl =
        'https://toknagah.viking-iceland.online/api/user/show-profile';
    try {
      final token = await storage.read(key: 'user_token');
      if (token == null) {
        emit(state.copyWith(
          isProfileLoading: false,
          userName: 'ضيف',
          userImage: ImageHome.getValidImageUrl(null),
        ));
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        profileUrl,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        Map<String, dynamic> userData = {};

        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            userData = Map<String, dynamic>.from(data['data']);
          } else {
            userData = data;
          }
        } else if (data is String) {
          try {
            final decoded = jsonDecode(data);
            if (decoded is Map<String, dynamic>) {
              userData = decoded.containsKey('data')
                  ? Map<String, dynamic>.from(decoded['data'])
                  : decoded;
            }
          } catch (_) {}
        }

        final name = _extractName(userData);
        final image = _extractImage(userData);

        emit(state.copyWith(
          isProfileLoading: false,
          userName: name,
          userImage: image,
        ));
      } else {
        emit(state.copyWith(
          isProfileLoading: false,
          userName: 'ضيف',
          userImage: ImageHome.getValidImageUrl(null),
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isProfileLoading: false,
        userName: 'ضيف',
        userImage: ImageHome.getValidImageUrl(null),
      ));
    }
  }

  Future<void> loadCategories() async {
    emit(state.copyWith(categoriesHasError: false));
    const storage = FlutterSecureStorage();
    const categoriesUrl =
        'https://toknagah.viking-iceland.online/api/user/categories';
    try {
      final token = await storage.read(key: 'user_token');
      final headers = {'Accept': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final dio = Dio();
      final response = await dio.get(categoriesUrl, options: Options(headers: headers));

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> categoriesData = [];

        if (data is Map<String, dynamic>) {
          if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
            final dataMap = data['data'] as Map<String, dynamic>;
            if (dataMap.containsKey('data') && dataMap['data'] is List<dynamic>) {
              categoriesData = dataMap['data'] as List<dynamic>;
            }
          }
        }

        final List<CategoryModel> categories = categoriesData.map((item) {
          return CategoryModel.fromJson(item as Map<String, dynamic>);
        }).toList();

        if (categories.isEmpty) {
          final now = DateTime.now();
          final fallback = [
            CategoryModel(id: 1001, name: 'اثاث', description: 'اثاث', icon: null, createdAt: now, updatedAt: now),
            CategoryModel(id: 1002, name: 'الكترونيات', description: 'الكترونيات', icon: null, createdAt: now, updatedAt: now),
            CategoryModel(id: 1003, name: 'ملابس', description: 'ملابس', icon: null, createdAt: now, updatedAt: now),
          ];
          emit(state.copyWith(categories: fallback));
        } else {
          emit(state.copyWith(categories: categories));
        }
      } else {
        final now = DateTime.now();
        final fallback = [
          CategoryModel(id: 1001, name: 'اثاث', description: 'اثاث', icon: null, createdAt: now, updatedAt: now),
          CategoryModel(id: 1002, name: 'الكترونيات', description: 'الكترونيات', icon: null, createdAt: now, updatedAt: now),
          CategoryModel(id: 1003, name: 'ملابس', description: 'ملابس', icon: null, createdAt: now, updatedAt: now),
        ];
        emit(state.copyWith(categoriesHasError: true, categories: fallback));
      }
    } catch (e) {
      final now = DateTime.now();
      final fallback = [
        CategoryModel(id: 1001, name: 'اثاث', description: 'اثاث', icon: null, createdAt: now, updatedAt: now),
        CategoryModel(id: 1002, name: 'الكترونيات', description: 'الكترونيات', icon: null, createdAt: now, updatedAt: now),
        CategoryModel(id: 1003, name: 'ملابس', description: 'ملابس', icon: null, createdAt: now, updatedAt: now),
      ];
      emit(state.copyWith(categoriesHasError: true, categories: fallback));
    }
  }

  String _extractName(Map<String, dynamic> data) {
    final possibleKeys = [
      'name',
      'username',
      'full_name',
      'user_name',
      'Name',
      'fullName',
      'displayName',
    ];

    for (final key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null && data[key].toString().trim().isNotEmpty) {
        return data[key].toString().trim();
      }
    }

    return 'خطأ';
  }

  String _extractImage(Map<String, dynamic> data) {
    final possibleKeys = [
      'image',
      'profile_image',
      'avatar',
      'photo',
      'Image',
      'profileImage',
      'avatar_url',
      'picture',
      'profile_picture',
    ];

    for (final key in possibleKeys) {
      if (data.containsKey(key) && data[key] != null && data[key].toString().trim().isNotEmpty) {
        final imageUrl = data[key].toString();
        return ImageHome.getValidImageUrl(imageUrl);
      }
    }

    return ImageHome.getValidImageUrl(null);
  }
}

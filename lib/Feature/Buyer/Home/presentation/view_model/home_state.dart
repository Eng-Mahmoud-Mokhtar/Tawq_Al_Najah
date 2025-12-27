import 'package:equatable/equatable.dart';
import '../../Data/Model/CategoryModel.dart';

class HomeState extends Equatable {
  final bool isProfileLoading;
  final String userName;
  final String userImage;
  final List<CategoryModel> categories;
  final bool categoriesHasError;

  const HomeState({
    required this.isProfileLoading,
    required this.userName,
    required this.userImage,
    required this.categories,
    required this.categoriesHasError,
  });

  factory HomeState.initial() {
    return HomeState(
      isProfileLoading: true,
      userName: '',
      userImage: '',
      categories: const [],
      categoriesHasError: false,
    );
  }

  HomeState copyWith({
    bool? isProfileLoading,
    String? userName,
    String? userImage,
    List<CategoryModel>? categories,
    bool? categoriesHasError,
  }) {
    return HomeState(
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      categories: categories ?? this.categories,
      categoriesHasError: categoriesHasError ?? this.categoriesHasError,
    );
  }

  @override
  List<Object?> get props => [isProfileLoading, userName, userImage, categories, categoriesHasError];
}

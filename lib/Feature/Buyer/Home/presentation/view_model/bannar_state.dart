part of 'bannar_cubit.dart';

@immutable
abstract class BannerState {
  const BannerState();
}

class BannerInitial extends BannerState {
  const BannerInitial();
}

class BannerLoading extends BannerState {
  const BannerLoading();
}

class BannerLoaded extends BannerState {
  final List<String> banners;
  final List<ProductModel> tawqalProducts;
  final List<ProductModel> suggestedProducts;

  const BannerLoaded({
    required this.banners,
    required this.tawqalProducts,
    required this.suggestedProducts,
  });
}

class BannerError extends BannerState {
  final String message;
  const BannerError(this.message);
}

import '../../../Product/Data/Models/ProductModel.dart';

class BannerModel {
  final List<String> banners;
  final List<ProductModel> tawqalProducts;
  final List<ProductModel> suggestedProducts;

  BannerModel({
    required this.banners,
    required this.tawqalProducts,
    required this.suggestedProducts,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawBanners =
        json['bannars'] ?? json['banners'] ?? json['data']?['bannars'];

    final List<dynamic>? rawTawqalProducts =
        json['ProductToqTajah'] ?? json['data']?['ProductToqTajah'];

    final List<dynamic>? rawSuggestedProducts =
        json['products'] ?? json['data']?['products'];

    final List<String> bannersList =
    rawBanners != null ? rawBanners.map((e) => e.toString()).toList() : [];

    final List<ProductModel> tawqalList = rawTawqalProducts != null
        ? rawTawqalProducts.map((e) => ProductModel.fromJson(e)).toList()
        : [];

    final List<ProductModel> suggestedList = rawSuggestedProducts != null
        ? rawSuggestedProducts.map((e) => ProductModel.fromJson(e)).toList()
        : [];

    return BannerModel(
      banners: bannersList,
      tawqalProducts: tawqalList,
      suggestedProducts: suggestedList,
    );
  }
}

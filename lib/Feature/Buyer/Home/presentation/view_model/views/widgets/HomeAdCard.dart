import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tawqalnajah/Feature/Buyer/Product/presentation/view_model/cart_cubit.dart';
import 'package:tawqalnajah/Feature/Buyer/Product/presentation/view_model/favorite_cubit.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../../Core/Widgets/buildImageError.dart';
import 'ImageHome.dart';

class HomeAdCard extends StatefulWidget {
  final Map<String, dynamic> ad;
  final VoidCallback onTap;
  final Function(bool)? onFavoriteChanged;

  const HomeAdCard({
    super.key,
    required this.ad,
    required this.onTap,
    this.onFavoriteChanged,
  });

  @override
  State<HomeAdCard> createState() => _HomeAdCardState();
}

class _HomeAdCardState extends State<HomeAdCard> {
  bool _isAddingToCart = false;
  bool _isTogglingFavorite = false;

  Future<void> _handleAddToCart() async {
    if (_isAddingToCart) return;

    final cartCubit = context.read<CartCubit>();
    final productId = widget.ad['id'];
    final productSellerId = widget.ad['saller_id'];

    setState(() {
      _isAddingToCart = true;
    });

    try {
      await cartCubit.toggleCartWithApi(productId, widget.ad);
    } catch (e) {
      print('Cart error: $e');
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      final favoriteCubit = context.read<FavoriteCubit>();
      final productId = widget.ad['id'];
      await favoriteCubit.toggleFavoriteWithApi(productId);

      if (widget.onFavoriteChanged != null) {
        final newFavoriteState = favoriteCubit.state.contains(productId);
        widget.onFavoriteChanged!(newFavoriteState);
      }
    } catch (e) {
      print('Favorite error: $e');
    } finally {
      setState(() {
        _isTogglingFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.35;
    final cardWidth = cardHeight * 0.65;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        return BlocBuilder<FavoriteCubit, Set<int>>(
          builder: (context, favoriteState) {
            final productId = widget.ad['id'];
            final isInCart = cartState.cartIds.contains(productId);
            final isFavorite = favoriteState.contains(productId);

            // استخراج العملة بنفس طريقة TawqalOffersPage
            // تحقق من الحقل الصحيح بناءً على API
            final String currency;
            if (widget.ad['currency_type'] != null && widget.ad['currency_type'].toString().isNotEmpty) {
              currency = widget.ad['currency_type'].toString();
            } else if (widget.ad['currency'] != null && widget.ad['currency'].toString().isNotEmpty) {
              currency = widget.ad['currency'].toString();
            } else {
              currency = S.of(context).SYP; // افتراضي
            }

            // حساب السعر بنفس طريقة TawqalOffersPage
            final priceAfterDiscount = widget.ad['priceAfterDiscount'] != null
                ? widget.ad['priceAfterDiscount'].toDouble()
                : null;
            final price = widget.ad['price'] != null
                ? widget.ad['price'].toDouble()
                : 0.0;
            final finalPrice = priceAfterDiscount != null && priceAfterDiscount > 0
                ? priceAfterDiscount
                : price;

            return GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(cardWidth * 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(cardWidth * 0.05),
                        ),
                        child: _buildImageSection(
                          cardWidth,
                          cardHeight,
                          context,
                          isFavorite,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(cardWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      widget.ad['name']?.toString() ??
                                          S.of(context).unknown,
                                      style: TextStyle(
                                        fontSize: cardHeight * 0.04,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                  SizedBox(height: cardHeight * 0.01),
                                  Container(
                                    width: double.infinity,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      widget.ad['description']?.toString() ??
                                          S.of(context).noDescription,
                                      style: TextStyle(
                                        fontSize: cardHeight * 0.035,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                  SizedBox(height: cardHeight * 0.01),
                                  Container(
                                    width: double.infinity,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      // استخدام المتغيرات الجديدة
                                      "${finalPrice.toStringAsFixed(2)} $currency",
                                      style: TextStyle(
                                        fontSize: cardHeight * 0.04,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xffFF580E),
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                  SizedBox(height: cardHeight * 0.02),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isAddingToCart
                                          ? null
                                          : _handleAddToCart,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isInCart
                                            ? Colors.grey
                                            : const Color(0xffFF580E),
                                        minimumSize: Size(
                                          double.infinity,
                                          cardHeight * 0.12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            cardWidth * 0.15,
                                          ),
                                        ),
                                      ),
                                      child: _isAddingToCart
                                          ? SizedBox(
                                        width: cardHeight * 0.03,
                                        height: cardHeight * 0.03,
                                        child:
                                        const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : Text(
                                        isInCart
                                            ? S.of(context).addedToCart
                                            : S.of(context).AddtoCart,
                                        style: TextStyle(
                                          fontSize: cardHeight * 0.035,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageSection(
      double cardWidth,
      double cardHeight,
      BuildContext context,
      bool isFavorite,
      ) {
    final imageUrl =
    (widget.ad['images'] is List && widget.ad['images'].isNotEmpty)
        ? widget.ad['images'][0]
        : null;

    if (imageUrl == null || imageUrl.toString().isEmpty) {
      return buildImageErrorPlaceholder(context, cardWidth, cardHeight);
    }

    return Stack(
      children: [
        CachedNetworkImage(
          imageUrl: ImageHome.getValidImageUrl(imageUrl),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[300],
            ),
          ),
          errorWidget: (context, url, error) =>
              buildImageErrorPlaceholder(context, cardWidth, cardHeight / 2),
        ),
        Positioned(
          top: cardWidth * 0.05,
          left: cardWidth * 0.05,
          child: GestureDetector(
            onTap: _isTogglingFavorite ? null : _toggleFavorite,
            child: Container(
              padding: EdgeInsets.all(cardWidth * 0.03),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.5),
              ),
              child: _isTogglingFavorite
                  ? SizedBox(
                width: cardWidth * 0.06,
                height: cardWidth * 0.06,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color:
                isFavorite ? const Color(0xffFF580E) : Colors.white,
                size: cardWidth * 0.1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
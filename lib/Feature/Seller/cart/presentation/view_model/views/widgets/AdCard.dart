import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../More/presentation/view_model/favorites_cubit.dart';
import '../../cart_cubit.dart';

class AdCard extends StatefulWidget {
  final Map<String, dynamic> ad;
  final VoidCallback onTap;

  const AdCard({
    super.key,
    required this.ad,
    required this.onTap,
  });

  @override
  State<AdCard> createState() => _AdCardState();
}

class _AdCardState extends State<AdCard> {
  bool _isAddingToCart = false;
  bool _showAddedText = false;

  void _handleAddToCart() async {
    setState(() {
      _isAddingToCart = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    context.read<CartCubit>().addToCart(widget.ad);
    setState(() {
      _isAddingToCart = false;
      _showAddedText = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.45; // ارتفاع كافٍ لتجنب التجاوز
    final cardWidth = cardHeight * 0.55; // نسبة عرض من4اسبة

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final isInCart = cartState.cartItems.any((item) => item['ad']?['name'] == widget.ad['name']);
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favoritesState) {
            final isFavorite = favoritesState.favoriteItems.any((item) => item['name'] == widget.ad['name']);
            return GestureDetector(
              onTap: widget.ad.isEmpty ? null : widget.onTap,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxCardWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : cardWidth;
                  final maxCardHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : cardHeight;
                  final finalCardWidth = maxCardWidth < cardWidth ? maxCardWidth : cardWidth;
                  final finalCardHeight = maxCardHeight < cardHeight ? maxCardHeight : cardHeight;

                  return Container(
                    width: finalCardWidth,
                    height: finalCardHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(finalCardWidth * 0.05),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: widget.ad.isEmpty
                        ? const Center(child: Text('No Data Available'))
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image Section
                        Expanded(
                          flex: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(finalCardWidth * 0.05),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        (widget.ad['images'] is List && widget.ad['images'].isNotEmpty)
                                            ? widget.ad['images'][0]
                                            : 'Assets/fallback_image.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: finalCardHeight * 0.04,
                                  left: finalCardWidth * 0.04,
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<FavoritesCubit>().toggleFavorite(widget.ad);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(finalCardWidth * 0.025),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                      child: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: isFavorite ? Color(0xffFF580E) : Colors.white,
                                        size: finalCardWidth * 0.1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Content Section
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.all(finalCardWidth * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text Content
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Name Text
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        widget.ad['name']?.toString() ?? S.of(context).unknown,
                                        style: TextStyle(
                                          fontSize: finalCardHeight * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                    SizedBox(height: finalCardHeight * 0.015),
                                    // Description Text
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        widget.ad['description']?.toString() ?? S.of(context).noDescription,
                                        style: TextStyle(
                                          fontSize: finalCardHeight * 0.035,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                    SizedBox(height: finalCardHeight * 0.015),
                                    // Price Text
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "${widget.ad['price']?.toStringAsFixed(2) ?? '0.00'} ${widget.ad['currency']?.toString() ?? ''}",
                                        style: TextStyle(
                                          fontSize: finalCardHeight * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xffFF580E),
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isAddingToCart || isInCart ? null : _handleAddToCart,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffFF580E),
                                      minimumSize: Size(double.infinity, finalCardHeight * 0.13),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(finalCardWidth * 0.2),
                                      ),
                                    ),
                                    child: _isAddingToCart
                                        ? SizedBox(
                                      width: finalCardWidth * 0.08,
                                      height: finalCardWidth * 0.08,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : Text(
                                      _showAddedText ? S.of(context).addedToCart : S.of(context).AddtoCart,
                                      style: TextStyle(
                                        fontSize: finalCardHeight * 0.035,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                ),
                                SizedBox(height: finalCardHeight * 0.005),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
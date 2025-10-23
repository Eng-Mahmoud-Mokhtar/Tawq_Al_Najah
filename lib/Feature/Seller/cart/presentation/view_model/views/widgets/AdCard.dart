import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../More/presentation/view_model/favorites_cubit.dart';
import '../../cart_cubit.dart';

class AdCard extends StatefulWidget {
  final Map<String, dynamic> ad;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const AdCard({
    super.key,
    required this.ad,
    required this.screenWidth,
    required this.screenHeight,
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
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final isInCart = cartState.cartItems.any((item) => item['ad']['name'] == widget.ad['name']);
        return BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, favoritesState) {
            final isFavorite = favoritesState.favoriteItems.any((item) => item['name'] == widget.ad['name']);
            return GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: widget.screenWidth * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(widget.screenWidth * 0.03),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // ثابت على اليمين
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: widget.screenHeight * 0.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(widget.screenWidth * 0.03),
                            ),
                            image: DecorationImage(
                              image: AssetImage(widget.ad['images'][0] ?? 'Assets/fallback_image.png'),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                print('Failed to load ad image: ${widget.ad['images'][0]}');
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: widget.screenHeight * 0.01,
                          left: widget.screenWidth * 0.02,
                          child: GestureDetector(
                            onTap: () {
                              context.read<FavoritesCubit>().toggleFavorite(widget.ad);
                            },
                            child: Container(
                              padding: EdgeInsets.all(widget.screenWidth * 0.015),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.white,
                                size: widget.screenWidth * 0.05,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(widget.screenWidth * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end, // ثابت على اليمين
                        children: [
                          Text(
                            widget.ad['name'] ?? S.of(context).unknown,
                            style: TextStyle(
                              fontSize: widget.screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right, // ثابت على اليمين
                          ),
                          SizedBox(height: widget.screenHeight * 0.005),
                          Text(
                            widget.ad['description'] ?? S.of(context).noDescription,
                            style: TextStyle(
                              fontSize: widget.screenWidth * 0.03,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right, // ثابت على اليمين
                          ),
                          SizedBox(height: widget.screenHeight * 0.005),
                          Text(
                            "${widget.ad['price']?.toStringAsFixed(2) ?? '0.00'} ${widget.ad['currency'] ?? ''}",
                            style: TextStyle(
                              fontSize: widget.screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xffFF580E),
                            ),
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: widget.screenHeight * 0.01),
                          Wrap(
                            children: [
                              ElevatedButton(
                                onPressed: _isAddingToCart || isInCart ? null : _handleAddToCart,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffFF580E),
                                  minimumSize: Size(double.infinity, widget.screenHeight * 0.05),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(widget.screenWidth * 0.2),
                                  ),
                                ),
                                child: _isAddingToCart
                                    ? SizedBox(
                                  width: widget.screenWidth * 0.05,
                                  height: widget.screenWidth * 0.05,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  _showAddedText ? S.of(context).addedToCart : S.of(context).AddtoCart,
                                  style: TextStyle(
                                    fontSize: widget.screenWidth * 0.03,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
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
}

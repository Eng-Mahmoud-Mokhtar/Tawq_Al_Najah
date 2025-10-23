import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../generated/l10n.dart';
import '../../cart_cubit.dart';

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> cartItem;
  final double screenWidth;
  final double screenHeight;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    final ad = cartItem['ad'] as Map<String, dynamic>;
    final quantity = cartItem['quantity'] as int;

    // ✅ اتجاه ثابت من اليمين لليسار
    const textDirection = TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      image: DecorationImage(
                        image: AssetImage(ad['images'][0] ?? 'Assets/fallback_image.png'),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          print('Failed to load cart item image: ${ad['images'][0]}');
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          ad['name'] ?? S.of(context).unknown,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          ad['description'] ?? S.of(context).noDescription,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${(ad['price'] as double).toStringAsFixed(2)} ${ad['currency'] ?? ''}",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xffFF580E),
                              ),
                            ),
                            Wrap(
                              direction: Axis.horizontal,
                              spacing: screenWidth * 0.02,
                              children: [
                                GestureDetector(
                                  onTap: () => context.read<CartCubit>().decrement(ad),
                                  child: CircleAvatar(
                                    radius: screenWidth * 0.03,
                                    backgroundColor: Colors.grey[200],
                                    child: Icon(Icons.remove, color: Colors.black, size: screenWidth * 0.035),
                                  ),
                                ),
                                Text(
                                  "$quantity",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.read<CartCubit>().increment(ad),
                                  child: CircleAvatar(
                                    radius: screenWidth * 0.03,
                                    backgroundColor: Colors.grey[200],
                                    child: Icon(Icons.add, color: Colors.black, size: screenWidth * 0.035),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: screenHeight * 0.015,
              left: screenWidth * 0.02, // ✅ دائماً من اليمين
              child: IconButton(
                icon: Icon(
                  Icons.delete_outline_outlined,
                  color: Color(0xffFF580E),
                  size: screenHeight * 0.03,
                ),
                onPressed: () {
                  context.read<CartCubit>().removeFromCart(ad);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Color(0xffFF580E),
                      content: Text(
                        S.of(context).itemRemoved,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: S.of(context).itemRemoved,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

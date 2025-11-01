import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tawqalnajah/Feature/Buyer/cart/presentation/view_model/views/widgets/CartItemCard.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../Home/presentation/view_model/views/HomeStructure.dart';
import '../cart_cubit.dart';
import 'BuyOrder.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.cartItems.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xfffafafa),
            appBar: AppBarWithBottomB(title: S.of(context).Cart),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "Assets/empty-cart 1.png",
                      width: screenWidth * 0.5,
                      height: screenWidth * 0.5,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      S.of(context).emptyCart,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: KprimaryText,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      S.of(context).browseAndShopNow,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<BottomNavBCubit>().setIndex(0);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KprimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: SizedBox(
                          height: screenWidth * 0.12,
                          child: Center(
                            child: Text(
                              S.of(context).browseProducts,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: SecoundColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        double subtotal = 0.0;
        for (var item in state.cartItems) {
          subtotal += (item['ad']['price'] as double) * (item['quantity'] as int);
        }
        const double shipping = 20.00;
        final double total = subtotal + shipping;

        return Scaffold(
          backgroundColor: const Color(0xfffafafa),
          appBar: AppBarWithBottomB(title: S.of(context).Cart),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              children: [
                ...state.cartItems.map(
                      (cartItem) => Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                    child: Slidable(
                      key: ValueKey(cartItem),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.25,
                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              context.read<CartCubit>().removeFromCart(cartItem['ad']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(S.of(context).itemRemoved),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: S.of(context).delete,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: CartItemCard(
                          cartItem: cartItem,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.04),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).subtotal,
                            style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            subtotal.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).shippingCostLabel,
                            style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500),
                          ),
                          Text(
                            shipping.toStringAsFixed(2),
                            style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).totalLabel,
                            style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            total.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xffFF580E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyOrder(
                            productData: {
                              'items': state.cartItems,
                              'subtotal': subtotal,
                              'shippingCost': shipping,
                              'total': total,
                            },
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KprimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: SizedBox(
                      height: screenWidth * 0.12,
                      child: Center(
                        child: Text(
                          S.of(context).Checkout,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                            color: SecoundColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

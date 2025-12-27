import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tawqalnajah/Feature/Buyer/MyShipment/presentation/view_model/views/widgets/ShipmentCard.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../Data/OrderData.dart';
import '../../CancelOrderCubit.dart';
import '../../MyShipmentsCubit.dart';
import '../OrderDetailsAndTracker.dart';
import 'ShipmentsShimmerList.dart';


class ShipmentTab extends StatelessWidget {
  final List<OrderData> orders;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;

  const ShipmentTab({
    super.key,
    required this.orders,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) return const ShipmentsShimmerList();

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: screenWidth * 0.15),
            SizedBox(height: screenHeight * 0.02),
            Text(
              S.of(context).errorLoadingCategories,
              style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[700]),
            ),
            SizedBox(height: screenHeight * 0.02),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KprimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  S.of(context).tryAgain,
                  style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.white),
                ),
              ),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "Assets/empty-cart 1.png",
                width: screenWidth * 0.5,
                height: screenWidth * 0.5,
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                S.of(context).browseAndShopNow,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey[700]),
              ),
              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return ShipmentCard(
          data: order,
          onTap: () async {
            final shipmentsCubit = context.read<MyShipmentsCubit>();
            final cancelCubit = context.read<CancelOrderCubit>();

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: shipmentsCubit),
                    BlocProvider.value(value: cancelCubit),
                  ],
                  child: OrderDetailsAndTracker(data: order),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

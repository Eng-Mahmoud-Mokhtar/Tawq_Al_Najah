import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tawqalnajah/Core/Widgets/AppBar.dart';
import 'package:tawqalnajah/Feature/Seller/Orders/presentation/view_model/views/widgets/ShipmentCardSeller.dart';
import 'package:tawqalnajah/Feature/Seller/Orders/presentation/view_model/views/widgets/emptyState.dart';

import '../../../../../../generated/l10n.dart';
import '../OrdersCubit.dart';
import '../OrdersState.dart';

class SellerCancelledOrdersPage extends StatelessWidget {
  const SellerCancelledOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is! OrdersLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final orders = state.cancelled;
        final screenWidth = MediaQuery.of(context).size.width;

        if (orders.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xfffafafa),
            appBar: CustomAppBar(title: S.of(context).cancelledOrders),
            body: emptyState(context, S.of(context).noOrdersYet),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xfffafafa),
          appBar: CustomAppBar(title: "${S.of(context).cancelledOrders} (${orders.length})"),
          body: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return ShipmentCardSeller(data: orders[index], isCancelled: true);
            },
          ),
        );
      },
    );
  }
}

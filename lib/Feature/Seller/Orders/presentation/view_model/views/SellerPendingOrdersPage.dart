import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tawqalnajah/Core/Widgets/AppBar.dart';
import 'package:tawqalnajah/Feature/Seller/Orders/presentation/view_model/views/widgets/ShipmentCardSeller.dart';
import 'package:tawqalnajah/Feature/Seller/Orders/presentation/view_model/views/widgets/emptyState.dart';
import '../../../../../../generated/l10n.dart';
import '../OrdersCubit.dart';
import '../OrdersState.dart';

class SellerPendingOrdersPage extends StatelessWidget {
  const SellerPendingOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is! OrdersLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = state.pending;

        if (orders.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xfffafafa),
            appBar: CustomAppBar(title: S.of(context).pendingTab),
            body: emptyState(context, S.of(context).noOrdersYet),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xfffafafa),
          appBar: CustomAppBar(
            title: "${S.of(context).pendingTab} (${orders.length})",
          ),
          body: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ShipmentCardSeller(
                data: order,
                onStatusChange: (o, status) =>
                    context.read<OrdersCubit>().updateOrderStatus(o.orderId, "confirmed"),
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';
import 'package:tawqalnajah/Feature/Seller/Orders/presentation/view_model/views/widgets/ShipmentCardSeller.dart';
import 'package:tawqalnajah/Feature/Seller/Orders/presentation/view_model/views/widgets/emptyState.dart';

import '../../../../../../generated/l10n.dart';
import '../../../../Home/presentation/view_model/views/HomeStructure.dart';
import '../OrdersCubit.dart';
import '../OrdersState.dart';

class SellerActiveOrdersPage extends StatefulWidget {
  final bool fromBottomNav;

  const SellerActiveOrdersPage({super.key, this.fromBottomNav = false});

  @override
  State<SellerActiveOrdersPage> createState() => _SellerActiveOrdersPageState();
}

class _SellerActiveOrdersPageState extends State<SellerActiveOrdersPage> {
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        if (state is! OrdersLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final lists = [state.confirmed, state.shipped, state.delivered];
        final tabs = [
          S.of(context).confirmedOrders,
          S.of(context).shippedOrders,
          S.of(context).deliveredOrders
        ];
        final screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          backgroundColor: const Color(0xfffafafa),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: screenWidth * 0.05,
              ),
              onPressed: () {
                if (widget.fromBottomNav) {
                  context.read<BottomNavSCubit>().setIndex(0);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              S.of(context).manageOrders,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
                color: KprimaryText,
              ),
            ),
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  children: List.generate(tabs.length, (i) {
                    final isSelected = selectedTabIndex == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedTabIndex = i),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color: isSelected ? KprimaryColor : Colors.grey.shade200,
                            border: Border.all(color: isSelected ? KprimaryColor : Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(screenWidth * 0.05),
                          ),
                          child: Text(
                            "${tabs[i]} (${lists[i].length})",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: lists[selectedTabIndex].isEmpty
                    ? emptyState(context, S.of(context).noOrdersYet)
                    : ListView.builder(
                  itemCount: lists[selectedTabIndex].length,
                  itemBuilder: (context, index) {
                    final order = lists[selectedTabIndex][index];
                    return ShipmentCardSeller(
                      data: order,
                      onStatusChange: selectedTabIndex == 0
                          ? (o, status) => context.read<OrdersCubit>().updateOrderStatus(o.orderId, "shipped")
                          : selectedTabIndex == 1
                          ? (o, status) => context.read<OrdersCubit>().updateOrderStatus(o.orderId, "delivered")
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

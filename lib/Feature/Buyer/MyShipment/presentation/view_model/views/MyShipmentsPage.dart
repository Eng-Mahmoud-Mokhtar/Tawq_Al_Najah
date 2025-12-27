import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../Data/OrdersRepository.dart';
import '../CancelOrderCubit.dart';
import '../MyShipmentsCubit.dart';
import '../MyShipmentsState.dart';
import 'widgets/ShipmentTab.dart';
import 'widgets/ShipmentTabBar.dart';

extension CurrencyNumX on num {
  String toCurrencyText() => '${toStringAsFixed(2)} ${S.current.SYP}';
}

class MyShipmentsPage extends StatelessWidget {
  const MyShipmentsPage({super.key});

  static const String _baseUrl = 'https://toknagah.viking-iceland.online/api';

  @override
  Widget build(BuildContext context) {
    final repo = OrdersRepository(
      dio: Dio(),
      storage: const FlutterSecureStorage(),
      baseUrl: _baseUrl,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MyShipmentsCubit(repo: repo)..fetchTab(0, forceRefresh: true),
        ),
        BlocProvider(create: (_) => CancelOrderCubit(repo: repo)),
      ],
      child: BlocBuilder<MyShipmentsCubit, MyShipmentsState>(
        builder: (context, state) {
          final pages = [
            ShipmentTab(
              orders: state.pendingOrders,
              isLoading: state.isLoadingTab[0] ?? false,
              hasError: state.hasErrorTab[0] ?? false,
              onRetry: () =>
                  context.read<MyShipmentsCubit>().fetchTab(0, forceRefresh: true),
            ),
            ShipmentTab(
              orders: state.completedOrders,
              isLoading: state.isLoadingTab[1] ?? false,
              hasError: state.hasErrorTab[1] ?? false,
              onRetry: () =>
                  context.read<MyShipmentsCubit>().fetchTab(1, forceRefresh: true),
            ),
            ShipmentTab(
              orders: state.cancelledOrders,
              isLoading: state.isLoadingTab[2] ?? false,
              hasError: state.hasErrorTab[2] ?? false,
              onRetry: () =>
                  context.read<MyShipmentsCubit>().fetchTab(2, forceRefresh: true),
            ),
          ];

          return Scaffold(
            backgroundColor: const Color(0xfffafafa),
            appBar: CustomAppBar(title: S.of(context).myShipments),
            body: Column(
              children: [
                ShipmentTabBar(
                  selectedIndex: state.selectedIndex,
                  onTap: (i) async =>
                      context.read<MyShipmentsCubit>().changeTab(i),
                ),
                Expanded(child: pages[state.selectedIndex]),
              ],
            ),
          );
        },
      ),
    );
  }
}
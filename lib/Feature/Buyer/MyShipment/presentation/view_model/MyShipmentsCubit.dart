import 'package:bloc/bloc.dart';

import '../../Data/OrderData.dart';
import '../../Data/OrdersRepository.dart';
import 'MyShipmentsState.dart';

class MyShipmentsCubit extends Cubit<MyShipmentsState> {
  final OrdersRepository repo;

  MyShipmentsCubit({required this.repo})
      : super(
    const MyShipmentsState(
      selectedIndex: 0,
      pendingOrders: [],
      completedOrders: [],
      cancelledOrders: [],
      isLoadingTab: {0: false, 1: false, 2: false},
      hasErrorTab: {0: false, 1: false, 2: false},
    ),
  );

  String statusForIndex(int index) {
    switch (index) {
      case 1:
        return 'completed';
      case 2:
        return 'Cancelled';
      case 0:
      default:
        return 'pending';
    }
  }

  List<OrderData> ordersForIndex(int index) {
    switch (index) {
      case 1:
        return state.completedOrders;
      case 2:
        return state.cancelledOrders;
      case 0:
      default:
        return state.pendingOrders;
    }
  }

  void _setOrdersForIndex(int index, List<OrderData> value) {
    switch (index) {
      case 1:
        emit(state.copyWith(completedOrders: value));
        break;
      case 2:
        emit(state.copyWith(cancelledOrders: value));
        break;
      case 0:
      default:
        emit(state.copyWith(pendingOrders: value));
        break;
    }
  }

  Future<void> changeTab(int index) async {
    emit(state.copyWith(selectedIndex: index));
    await fetchTab(index, forceRefresh: false);
  }

  Future<void> fetchTab(int index, {bool forceRefresh = false}) async {
    final existing = ordersForIndex(index);
    if (!forceRefresh && existing.isNotEmpty) return;

    final isLoading = Map<int, bool>.from(state.isLoadingTab);
    final hasError = Map<int, bool>.from(state.hasErrorTab);
    isLoading[index] = true;
    hasError[index] = false;
    emit(state.copyWith(isLoadingTab: isLoading, hasErrorTab: hasError));

    try {
      final status = statusForIndex(index);
      final ids = await repo.fetchOrdersIdsByStatus(status);

      final futures = ids.map(repo.fetchOrderDetails).toList();
      final results = await Future.wait(futures);
      final orders = results.whereType<OrderData>().toList();

      _setOrdersForIndex(index, orders);

      final isLoading2 = Map<int, bool>.from(state.isLoadingTab);
      final hasError2 = Map<int, bool>.from(state.hasErrorTab);
      isLoading2[index] = false;
      hasError2[index] = false;
      emit(state.copyWith(isLoadingTab: isLoading2, hasErrorTab: hasError2));
    } catch (_) {
      final isLoading2 = Map<int, bool>.from(state.isLoadingTab);
      final hasError2 = Map<int, bool>.from(state.hasErrorTab);
      isLoading2[index] = false;
      hasError2[index] = true;
      emit(state.copyWith(isLoadingTab: isLoading2, hasErrorTab: hasError2));
    }
  }

  Future<void> refreshPendingAndCancelled() async {
    await fetchTab(0, forceRefresh: true);
    await fetchTab(2, forceRefresh: true);
  }
}

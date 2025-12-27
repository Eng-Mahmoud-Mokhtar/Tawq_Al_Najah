import '../../Data/OrderData.dart';

class MyShipmentsState {
  final int selectedIndex;
  final List<OrderData> pendingOrders;
  final List<OrderData> completedOrders;
  final List<OrderData> cancelledOrders;
  final Map<int, bool> isLoadingTab;
  final Map<int, bool> hasErrorTab;

  const MyShipmentsState({
    required this.selectedIndex,
    required this.pendingOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.isLoadingTab,
    required this.hasErrorTab,
  });

  MyShipmentsState copyWith({
    int? selectedIndex,
    List<OrderData>? pendingOrders,
    List<OrderData>? completedOrders,
    List<OrderData>? cancelledOrders,
    Map<int, bool>? isLoadingTab,
    Map<int, bool>? hasErrorTab,
  }) {
    return MyShipmentsState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      isLoadingTab: isLoadingTab ?? this.isLoadingTab,
      hasErrorTab: hasErrorTab ?? this.hasErrorTab,
    );
  }
}

import 'SellerOrderModel.dart';

abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<SellerOrderModel> orders;
  OrdersLoaded(this.orders);

  List<SellerOrderModel> get pending =>
      orders.where((o) => o.status == "pending").toList();
  List<SellerOrderModel> get confirmed =>
      orders.where((o) => o.status == "confirmed").toList();
  List<SellerOrderModel> get shipped =>
      orders.where((o) => o.status == "shipped").toList();
  List<SellerOrderModel> get delivered =>
      orders.where((o) => o.status == "delivered").toList();
  List<SellerOrderModel> get cancelled =>
      orders.where((o) => o.status == "cancelled").toList();
}
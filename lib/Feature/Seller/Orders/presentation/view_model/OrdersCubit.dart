import 'package:flutter_bloc/flutter_bloc.dart';

import 'OrdersState.dart';
import 'SellerOrderModel.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersInitial()) {
    _loadSampleOrders();
  }

  List<SellerOrderModel> _allOrders = [];

  void _loadSampleOrders() {
    _allOrders = [
      SellerOrderModel(
        orderId: "256",
        customerName: "أحمد محمد",
        customerPhone: "+966 50 123 4567",
        customerAddress:
        "المملكة العربية السعودية - الرياض - حي الملقا - شارع الملك فهد",
        productImage: "Assets/discount-jacket-podium.jpg",
        productName: "جاكيت شتوي",
        description: "جاكيت أنيق بتخفيض خاص.",
        quantity: 1,
        totalPrice: "149.99 ر.س",
        shippingCost: "20.00 ر.س",
        orderDate: "2025-10-15",
        status: "pending",
        category: "ملابس",
      ),
      SellerOrderModel(
        orderId: "261",
        customerName: "فاطمة علي",
        customerPhone: "+966 55 987 6543",
        customerAddress:
        "المملكة العربية السعودية - جدة - حي الصفا - شارع الأمير سلطان",
        productImage: "Assets/black-friday-sales-arrangement-with-tags.jpg",
        productName: "تخفيضات الجمعة السوداء",
        description: "عروض مذهلة على المنتجات المختارة.",
        quantity: 2,
        totalPrice: "199.98 ر.س",
        shippingCost: "15.00 ر.س",
        orderDate: "2025-10-14",
        status: "confirmed",
        confirmedDate: "2025-10-14",
        confirmedTime: "10:20",
        category: "عروض",
      ),
      SellerOrderModel(
        orderId: "255",
        customerName: "خالد سالم",
        customerPhone: "+966 54 111 2222",
        customerAddress:
        "المملكة العربية السعودية - الدمام - حي الروضة - شارع الملك سعود",
        productImage: "Assets/hands-holding-modern-smartphone.jpg",
        productName: "هاتف ذكي",
        description: "هاتف بتقنية حديثة.",
        quantity: 1,
        totalPrice: "1999.99 ر.س",
        shippingCost: "50.00 ر.س",
        orderDate: "2025-10-10",
        status: "delivered",
        confirmedDate: "2025-10-10",
        confirmedTime: "12:00",
        shippedDate: "2025-10-11",
        shippedTime: "08:45",
        deliveredDate: "2025-10-12",
        deliveredTime: "16:20",
        category: "إلكترونيات",
      ),
      SellerOrderModel(
        orderId: "257",
        customerName: "نورة عبدالله",
        customerPhone: "+966 53 333 4444",
        customerAddress:
        "المملكة العربية السعودية - مكة - حي العزيزية - شارع الحج",
        productImage:
        "Assets/front-view-screaming-male-chef-holding-up-sale-sign-burger-kitchen.jpg",
        productName: "عرض البرجر",
        description: "وجبة برجر شهية بسعر مميز.",
        quantity: 3,
        totalPrice: "89.97 ر.س",
        shippingCost: "10.00 ر.س",
        orderDate: "2025-10-08",
        status: "shipped",
        confirmedDate: "2025-10-08",
        confirmedTime: "18:30",
        shippedDate: "2025-10-09",
        shippedTime: "11:15",
        category: "طعام",
      ),
      SellerOrderModel(
        orderId: "258",
        customerName: "عبدالرحمن",
        customerPhone: "+966 56 555 6666",
        customerAddress:
        "المملكة العربية السعودية - المدينة - حي قباء - شارع قباء",
        productImage: "Assets/man-giving-some-keys-woman.jpg",
        productName: "مفاتيح سيارة",
        description: "عرض خاص على إكسسوارات السيارات.",
        quantity: 1,
        totalPrice: "49.99 ر.س",
        shippingCost: "15.00 ر.س",
        orderDate: "2025-10-05",
        status: "cancelled",
        category: "إكسسوارات",
      ),
    ];
    emit(OrdersLoaded(_allOrders));
  }

  void updateOrderStatus(String orderId, String newStatus) {
    final index = _allOrders.indexWhere((o) => o.orderId == orderId);
    if (index == -1) return;

    final now = DateTime.now();
    final date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final time =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final updatedOrder = _allOrders[index].copyWith(
      status: newStatus,
      confirmedDate: newStatus != "pending"
          ? (newStatus == "confirmed"
          ? date
          : _allOrders[index].confirmedDate ?? date)
          : null,
      confirmedTime: newStatus != "pending"
          ? (newStatus == "confirmed"
          ? time
          : _allOrders[index].confirmedTime ?? time)
          : null,
      shippedDate: newStatus == "shipped" || newStatus == "delivered"
          ? date
          : _allOrders[index].shippedDate,
      shippedTime: newStatus == "shipped" || newStatus == "delivered"
          ? time
          : _allOrders[index].shippedTime,
      deliveredDate: newStatus == "delivered"
          ? date
          : _allOrders[index].deliveredDate,
      deliveredTime: newStatus == "delivered"
          ? time
          : _allOrders[index].deliveredTime,
    );

    _allOrders[index] = updatedOrder;
    emit(OrdersLoaded(List.from(_allOrders)));
  }
}

import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Buyer/MyShipment/presentation/view_model/ShipmentCardData.dart';
import 'package:tawqalnajah/Feature/Buyer/MyShipment/presentation/view_model/views/widgets/ShipmentTab.dart';
import 'package:tawqalnajah/Feature/Buyer/MyShipment/presentation/view_model/views/widgets/ShipmentTabBar.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../Core/Widgets/AppBar.dart';

class MyShipmentsPage extends StatefulWidget {
  const MyShipmentsPage({super.key});

  @override
  State<MyShipmentsPage> createState() => _MyShipmentsPageState();
}

class _MyShipmentsPageState extends State<MyShipmentsPage> {
  int selectedIndex = 0;

  List<ShipmentCardData> currentShipments = [];
  List<ShipmentCardData> completedShipments = [];
  List<ShipmentCardData> cancelledShipments = [];

  @override
  void initState() {
    super.initState();
    _splitShipments();
  }

  void _splitShipments() {
    final all = <ShipmentCardData>[
      ShipmentCardData(
        shipmentNumber: "256",
        productImage: "Assets/discount-jacket-podium.jpg",
        productName: "سترة شتوية",
        description: "سترة أنيقة بخصم خاص. مصنوعة من خامات عالية الجودة.",
        quantity: 1,
        category: "الأزياء",
        price: "149.99 ريال",
        totalPrice: "149.99 ريال",
        shippingCost: "20.00 ريال",
        orderDate: "2025-10-15",
        isDelivered: false,
        orderConfirmedDate: "2025-10-15",
        orderConfirmedTime: "15:45",
        shippedDate: "2025-10-16",
        shippedTime: "09:30",
        deliveredDate: "2025-10-17",
        deliveredTime: "20:50",
      ),
      ShipmentCardData(
        shipmentNumber: "261",
        productImage: "Assets/black-friday-sales-arrangement-with-tags.jpg",
        productName: "عروض الجمعة السوداء",
        description: "عروض مذهلة على منتجات مختارة.",
        quantity: 2,
        category: "إلكترونيات",
        price: "99.99 ريال",
        totalPrice: "199.98 ريال",
        shippingCost: "15.00 ريال",
        orderDate: "2025-10-14",
        isDelivered: false,
        orderConfirmedDate: "2025-10-14",
        orderConfirmedTime: "10:20",
        shippedDate: "2025-10-15",
        shippedTime: "14:00",
        deliveredDate: "2025-10-16",
        deliveredTime: "18:30",
      ),
      ShipmentCardData(
        shipmentNumber: "255",
        productImage: "Assets/hands-holding-modern-smartphone.jpg",
        productName: "هاتف ذكي",
        description: "أحدث هاتف بتقنيات متطورة وميزات جديدة كلياً.",
        quantity: 1,
        category: "إلكترونيات",
        price: "1999.99 ريال",
        totalPrice: "1999.99 ريال",
        shippingCost: "50.00 ريال",
        orderDate: "2025-10-10",
        isDelivered: true,
        orderConfirmedDate: "2025-10-10",
        orderConfirmedTime: "12:00",
        shippedDate: "2025-10-11",
        shippedTime: "08:45",
        deliveredDate: "2025-10-12",
        deliveredTime: "16:20",
      ),
      ShipmentCardData(
        shipmentNumber: "257",
        productImage: "Assets/front-view-screaming-male-chef-holding-up-sale-sign-burger-kitchen.jpg",
        productName: "وجبة برجر",
        description: "وجبة برجر لذيذة بسعر مميز. مصنوعة من مكونات طازجة.",
        quantity: 3,
        category: "المطبخ",
        price: "29.99 ريال",
        totalPrice: "89.97 ريال",
        shippingCost: "10.00 ريال",
        orderDate: "2025-10-08",
        isDelivered: true,
        orderConfirmedDate: "2025-10-08",
        orderConfirmedTime: "18:30",
        shippedDate: "2025-10-09",
        shippedTime: "11:15",
        deliveredDate: "2025-10-10",
        deliveredTime: "13:45",
      ),
      ShipmentCardData(
        shipmentNumber: "258",
        productImage: "Assets/man-giving-some-keys-woman.jpg",
        productName: "مفاتيح سيارة",
        description: "عرض خاص على إكسسوارات السيارات. متينة وسهلة الاستخدام.",
        quantity: 1,
        category: "إكسسوارات",
        price: "49.99 ريال",
        totalPrice: "49.99 ريال",
        shippingCost: "15.00 ريال",
        orderDate: "2025-10-05",
        isDelivered: false,
        orderConfirmedDate: "2025-10-05",
        orderConfirmedTime: "09:00",
        shippedDate: "2025-10-06",
        shippedTime: "12:30",
        deliveredDate: "2025-10-07",
        deliveredTime: "19:00",
      ),
      ShipmentCardData(
        shipmentNumber: "259",
        productImage: "Assets/discount-jacket-podium.jpg",
        productName: "سماعات لاسلكية",
        description: "سماعات بتقنية متقدمة وصوت عالي الجودة.",
        quantity: 1,
        category: "إلكترونيات",
        price: "299.99 ريال",
        totalPrice: "299.99 ريال",
        shippingCost: "25.00 ريال",
        orderDate: "2025-10-04",
        isDelivered: false,
        orderConfirmedDate: "2025-10-04",
        orderConfirmedTime: "16:00",
        shippedDate: "2025-10-05",
        shippedTime: "10:00",
        deliveredDate: "2025-10-06",
        deliveredTime: "17:30",
      ),
    ];

    currentShipments = all.where((s) => !s.isDelivered).toList();
    completedShipments = all.where((s) => s.isDelivered).toList();
    cancelledShipments = [];
  }

  void _cancelShipment(ShipmentCardData shipment) {
    setState(() {
      currentShipments.remove(shipment);
      cancelledShipments.add(shipment);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ShipmentTab(shipments: currentShipments, onCancel: _cancelShipment),
      ShipmentTab(shipments: completedShipments, onCancel: null),
      ShipmentTab(shipments: cancelledShipments, onCancel: null, isCancelled: true),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).myShipments),
      body: Column(
        children: [
          ShipmentTabBar(
            selectedIndex: selectedIndex,
            onTap: (i) => setState(() => selectedIndex = i),
            tabCount: 3,
          ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Seller/MyShipment/presentation/view_model/ShipmentCardData.dart';
import 'package:tawqalnajah/Feature/Seller/MyShipment/presentation/view_model/views/widgets/ShipmentTab.dart';
import 'package:tawqalnajah/Feature/Seller/MyShipment/presentation/view_model/views/widgets/ShipmentTabBar.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../Core/Widgets/AppBar.dart';

class MyShipmentsPage extends StatefulWidget {
  const MyShipmentsPage({super.key});

  @override
  State<MyShipmentsPage> createState() => _MyShipmentsPageState();
}

class _MyShipmentsPageState extends State<MyShipmentsPage> {
  int selectedIndex = 0;
  List<ShipmentCardData> allShipments = [
    ShipmentCardData(
      shipmentNumber: "256",
      productImage: "Assets/discount-jacket-podium.jpg",
      productName: "جاكيت شتوي",
      description: "جاكيت أنيق بتخفيض خاص. مصنوع من مواد عالية الجودة.",
      quantity: 1,
      category: "Fashion",
      price: "149.99 ر.س",
      totalPrice: "149.99 ر.س",
      shippingCost: "20.00 ر.س",
      orderDate: "2025-10-15",
      isDelivered: false,
      isCancelled: false,
    ),
    ShipmentCardData(
      shipmentNumber: "261",
      productImage: "Assets/black-friday-sales-arrangement-with-tags.jpg",
      productName: "تخفيضات الجمعة السوداء",
      description: "عروض مذهلة على المنتجات المختارة.",
      quantity: 2,
      category: "Electronics",
      price: "99.99 ر.س",
      totalPrice: "199.98 ر.س",
      shippingCost: "15.00 ر.س",
      orderDate: "2025-10-14",
      isDelivered: false,
      isCancelled: false,
    ),
    ShipmentCardData(
      shipmentNumber: "255",
      productImage: "Assets/hands-holding-modern-smartphone.jpg",
      productName: "هاتف ذكي",
      description: "هاتف بتقنية حديثة. يدعم أحدث الميزات.",
      quantity: 1,
      category: "Electronics",
      price: "1999.99 ر.س",
      totalPrice: "1999.99 ر.س",
      shippingCost: "50.00 ر.س",
      orderDate: "2025-10-10",
      isDelivered: true,
      isCancelled: false,
    ),
    ShipmentCardData(
      shipmentNumber: "257",
      productImage: "Assets/front-view-screaming-male-chef-holding-up-sale-sign-burger-kitchen.jpg",
      productName: "عرض البرجر",
      description: "وجبة برجر شهية بسعر مميز. تحتوي على مكونات طازجة.",
      quantity: 3,
      category: "Kitchen",
      price: "29.99 ر.س",
      totalPrice: "89.97 ر.س",
      shippingCost: "10.00 ر.س",
      orderDate: "2025-10-08",
      isDelivered: true,
      isCancelled: false,
    ),
    ShipmentCardData(
      shipmentNumber: "258",
      productImage: "Assets/man-giving-some-keys-woman.jpg",
      productName: "مفاتيح سيارة",
      description: "عرض خاص على إكسسوارات السيارات. متينة وسهلة الاستخدام.",
      quantity: 1,
      category: "Accessories",
      price: "49.99 ر.س",
      totalPrice: "49.99 ر.س",
      shippingCost: "15.00 ر.س",
      orderDate: "2025-10-05",
      isDelivered: false,
      isCancelled: true,
      cancellationReason: "Out of Stock",
    ),
    ShipmentCardData(
      shipmentNumber: "259",
      productImage: "Assets/discount-jacket-podium.jpg",
      productName: "سماعات لاسلكية",
      description: "سماعات بتقنية متقدمة. جودة صوت عالية.",
      quantity: 1,
      category: "Electronics",
      price: "299.99 ر.س",
      totalPrice: "299.99 ر.س",
      shippingCost: "25.00 ر.س",
      orderDate: "2025-10-04",
      isDelivered: false,
      isCancelled: true,
      cancellationReason: "Shipping Not Available to This Location",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final List<Widget> pages = [
      ShipmentTab(
        shipments: allShipments.where((s) => !s.isDelivered && !s.isCancelled).toList(),
      ),
      ShipmentTab(
        shipments: allShipments.where((s) => s.isDelivered).toList(),
      ),
      ShipmentTab(
        shipments: allShipments.where((s) => s.isCancelled).toList(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).myShipments),
      body: Column(
        children: [
          ShipmentTabBar(
            selectedIndex: selectedIndex,
            onTap: (i) => setState(() => selectedIndex = i),
          ),
          SizedBox(height: screenWidth * 0.04),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}






import 'package:flutter/material.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';

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

class ShipmentTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const ShipmentTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final tabs = [
      S.of(context).currentTab,
      S.of(context).completedTab,
      S.of(context).cancelledTab,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.015,
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: isSelected ? KprimaryColor : Colors.grey.shade200,
                  border: Border.all(
                    color: isSelected ? KprimaryColor : Colors.grey.shade400,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(screenWidth * 0.05),
                ),
                child: Center(
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ShipmentCardData {
  final String shipmentNumber;
  final String productImage;
  final String productName;
  final String description;
  final int quantity;
  final String category;
  final String price;
  final String totalPrice;
  final String shippingCost;
  final String orderDate;
  final bool isDelivered;
  final bool isCancelled;
  final String? cancellationReason;

  ShipmentCardData({
    required this.shipmentNumber,
    required this.productImage,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.category,
    required this.price,
    required this.totalPrice,
    required this.shippingCost,
    required this.orderDate,
    required this.isDelivered,
    this.isCancelled = false,
    this.cancellationReason,
  });
}

class ShipmentTab extends StatelessWidget {
  final List<ShipmentCardData> shipments;

  const ShipmentTab({super.key, required this.shipments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: shipments.length,
      itemBuilder: (context, index) {
        return ShipmentCard(data: shipments[index]);
      },
    );
  }
}

class ShipmentCard extends StatelessWidget {
  final ShipmentCardData data;

  const ShipmentCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return GestureDetector(
      onTap: data.isCancelled
          ? null
          : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsAndTracker(data: data),
          ),
        );
      },
      child: Directionality(
        textDirection: textDirection,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.02,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          data.productImage,
                          width: screenWidth * 0.18,
                          height: screenWidth * 0.18,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.productName,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.01),
                              Text(
                                data.description,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: screenWidth * 0.015),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.03,
                                      vertical: screenWidth * 0.01,
                                    ),
                                    decoration: BoxDecoration(
                                      color: KprimaryColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(screenWidth * 0.015),
                                    ),
                                    child: Text(
                                      'x${data.quantity}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: screenWidth * 0.025,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    data.category,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    data.price,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xffFF580E),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (data.isCancelled)
                      Padding(
                        padding: EdgeInsets.only(top: screenWidth * 0.02),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              data.cancellationReason ?? S.of(context).cancellationReasonNotSpecified,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Color(0xffDD0C0C),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (data.isDelivered)
                Positioned(
                  top: 0,
                  left: textDirection == TextDirection.rtl ? 0 : null,
                  right: textDirection == TextDirection.ltr ? 0 : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: KprimaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(screenWidth * 0.03),
                        bottomRight: Radius.circular(screenWidth * 0.03),
                      ),
                    ),
                    child: Text(
                      S.of(context).receivedStatus,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (data.isCancelled)
                Positioned(
                  top: 0,
                  left: textDirection == TextDirection.rtl ? 0 : null,
                  right: textDirection == TextDirection.ltr ? 0 : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenWidth * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffDD0C0C),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(screenWidth * 0.03),
                        bottomRight: Radius.circular(screenWidth * 0.03),
                      ),
                    ),
                    child: Text(
                      S.of(context).cancelledStatus,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailsAndTracker extends StatefulWidget {
  final ShipmentCardData data;

  const OrderDetailsAndTracker({super.key, required this.data});

  @override
  State<OrderDetailsAndTracker> createState() => _OrderDetailsAndTrackerState();
}

class _OrderDetailsAndTrackerState extends State<OrderDetailsAndTracker> {
  int currentStep = 0;
  List<Map<String, String>> steps = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    steps = [
      {
        'title': S.of(context).orderConfirmed,
        'dayMonth': '${widget.data.orderDate.split('-')[2]} ${S.of(context).getMonth(widget.data.orderDate.split('-')[1])} ${widget.data.orderDate.split('-')[0]}',
        'time': '15:45',
      },
      {
        'title': S.of(context).shippedStatus,
        'dayMonth': '${int.parse(widget.data.orderDate.split('-')[2]) + 1} ${S.of(context).getMonth(widget.data.orderDate.split('-')[1])} ${widget.data.orderDate.split('-')[0]}',
        'time': '09:30',
      },
      {
        'title': S.of(context).receivedStatus,
        'dayMonth': '${int.parse(widget.data.orderDate.split('-')[2]) + 2} ${S.of(context).getMonth(widget.data.orderDate.split('-')[1])} ${widget.data.orderDate.split('-')[0]}',
        'time': '20:50',
      },
    ];
    if (widget.data.isDelivered) {
      currentStep = 2; // Stop at final step for completed
    } else {
      // For current shipments, set different steps based on shipment number
      if (widget.data.shipmentNumber == "256") {
        currentStep = 0; // Stop at first step
      } else if (widget.data.shipmentNumber == "261") {
        currentStep = 1; // Stop at second step
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
    final grandTotal = (double.parse(widget.data.totalPrice.split(' ')[0]) + double.parse(widget.data.shippingCost.split(' ')[0])).toString() + ' ر.س';

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).orderDetails),
      body: Directionality(
        textDirection: textDirection,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).productDetails,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(
                              S.of(context).descriptionLabel,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.data.description,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(
                              S.of(context).quantityLabel,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Text(
                            '${widget.data.quantity}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(
                              S.of(context).priceLabel,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.data.totalPrice,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(
                              S.of(context).shippingCostLabel,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              widget.data.shippingCost,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: screenWidth * 0.3,
                            child: Text(
                              S.of(context).totalLabel,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              grandTotal,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffFF580E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).orderStatus,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Column(
                        children: List.generate(steps.length, (index) {
                          final step = steps[index];
                          return _buildStep(
                            title: step['title']!,
                            dayMonth: step['dayMonth']!,
                            time: step['time']!,
                            isActive: index <= currentStep,
                            isLast: index == steps.length - 1,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required String title,
    required String dayMonth,
    required String time,
    required bool isActive,
    required bool isLast,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: screenWidth * 0.03,
              horizontal: screenWidth * 0.04,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffF6F6F5),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.black : Colors.grey,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: screenWidth * 0.04,
                height: screenWidth * 0.03,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xffFF580E) : const Color(0xffDEBEBF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (!isLast)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 3,
                height: 50,
                color: isActive ? const Color(0xffFF580E) : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenWidth * 0.005),
              child: Text(
                dayMonth,
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.03,
                ),
              ),
            ),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.03,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

extension LocalizationExtension on S {
  String getMonth(String month) {
    const months = {
      '01': 'january',
      '02': 'february',
      '03': 'march',
      '04': 'april',
      '05': 'may',
      '06': 'june',
      '07': 'july',
      '08': 'august',
      '09': 'september',
      '10': 'october',
      '11': 'november',
      '12': 'december',
    };
    final monthKey = months[month] ?? 'january';
    switch (monthKey) {
      case 'january':
        return january;
      case 'february':
        return february;
      case 'march':
        return march;
      case 'april':
        return april;
      case 'may':
        return may;
      case 'june':
        return june;
      case 'july':
        return july;
      case 'august':
        return august;
      case 'september':
        return september;
      case 'october':
        return october;
      case 'november':
        return november;
      case 'december':
        return december;
      default:
        return '';
    }
  }
}
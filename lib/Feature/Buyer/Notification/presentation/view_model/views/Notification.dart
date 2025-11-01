import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../Home/presentation/view_model/views/HomeStructure.dart';

class NotificationItem {
  final String title;
  final String content;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.content,
    this.isRead = false,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await Future.delayed(const Duration(seconds: 2)); // وقت التحميل
    setState(() {
      notifications = [
        NotificationItem(
          title: S.of(context).newNotification,
          content: 'تم إضافة عرض جديد على منتجاتك المفضلة!',
          isRead: false,
        ),
        NotificationItem(
          title: S.of(context).newNotification,
          content: 'تم تحديث الأسعار لهذا الأسبوع.',
          isRead: false,
        ),
        NotificationItem(
          title: S.of(context).newNotification,
          content: 'لديك منتجات في السلة لم تكمل الشراء بعد.',
          isRead: true,
        ),
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).notificationsTitle),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: isLoading
            ? _buildShimmerLoading(screenWidth, screenHeight)
            : notifications.isEmpty
            ? _buildEmptyState(screenWidth, screenHeight, context)
            : ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final item = notifications[index];
            return Container(
              margin:
              EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(screenWidth * 0.03),
                border: Border.all(
                  color: KprimaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(screenWidth * 0.03),
                child: Slidable(
                  key: ValueKey(item.hashCode),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          setState(() {
                            notifications.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                S.of(context).itemRemoved,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor:
                              const Color(0xffDD0C0C),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        backgroundColor: const Color(0xffDD0C0C),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: S.of(context).delete,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        item.isRead = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: item.isRead
                            ? Colors.white
                            : KprimaryColor.withOpacity(0.1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: screenWidth * 0.12,
                            height: screenWidth * 0.12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              image: const DecorationImage(
                                image: AssetImage(
                                    'Assets/Ellipse 9.png'),
                                fit: BoxFit.contain,
                              ),
                              border: Border.all(
                                color:
                                KprimaryColor.withOpacity(0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: KprimaryColor.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.035,
                                    color: KprimaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                    height: screenHeight * 0.005),
                                Text(
                                  item.content,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.03,
                                    color: SecoundText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(double screenWidth, double screenHeight) {
    return ListView.separated(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: 4,
      separatorBuilder: (_, __) => SizedBox(height: screenHeight * 0.015),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: screenHeight * 0.12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      double screenWidth, double screenHeight, BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.5,
              height: screenWidth * 0.5,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('Assets/empty 1.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              S.of(context).noNotifications,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
                color: KprimaryText,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              S.of(context).exclusiveOffer,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeStructure(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: KprimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: SizedBox(
                  height: screenWidth * 0.12,
                  child: Center(
                    child: Text(
                      S.of(context).browseProducts,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                        color: SecoundColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.1),
          ],
        ),
      ),
    );
  }
}

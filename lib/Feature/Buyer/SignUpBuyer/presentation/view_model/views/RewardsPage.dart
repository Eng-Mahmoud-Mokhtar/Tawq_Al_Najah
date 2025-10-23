// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../../../../../../Core/Widgets/AppBar.dart';
// import '../../../../../../Core/utiles/Colors.dart';
//
// class RewardsPage extends StatelessWidget {
//   const RewardsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     // بيانات الإحالة
//     final referralCode = "TQ-78453";
//     final int usedBy = 10;
//     final double rewardPerPerson = 0.1;
//
//     // بيانات الدعم
//     final int donations = 5;
//     final double rewardPerDonation = 0.2;
//
//     // الحسابات
//     final double referralEarnings = usedBy * rewardPerPerson;
//     final double donationEarnings = donations * rewardPerDonation;
//     final double totalEarnings = referralEarnings + donationEarnings;
//
//     final bool canWithdraw = totalEarnings >= 1.0;
//
//     return Scaffold(
//       backgroundColor: const Color(0xfffafafa),
//       appBar: const CustomAppBar(title: 'المكافآت'),
//       body: Padding(
//         padding: EdgeInsets.all(screenWidth * 0.05),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: screenWidth * 0.05),
//
//               // الصورة والعنوان الرئيسي
//               Center(
//                 child: Column(
//                   children: [
//                     Image.asset(
//                       'Assets/open-package.png',
//                       width: screenWidth * 0.25,
//                       height: screenWidth * 0.25,
//                       fit: BoxFit.contain,
//                     ),
//                     SizedBox(height: screenWidth * 0.05),
//                     Text(
//                       'تابع مكافآتك من الإحالات والدعم',
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.045,
//                         fontWeight: FontWeight.bold,
//                         color: KprimaryText,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: screenWidth * 0.08),
//
//               // كود الإحالة
//               _buildReferralCodeBox(referralCode, screenWidth, context),
//
//               SizedBox(height: screenWidth * 0.04),
//
//               // عنوان قسم الإحالة
//               Text(
//                 'مكافآت الإحالة',
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.04,
//                   fontWeight: FontWeight.bold,
//                   color: KprimaryText,
//                 ),
//               ),
//               SizedBox(height: screenWidth * 0.04),
//
//               _buildRewardSection(
//                 label1: 'عدد المستخدمين عبر كودك',
//                 value1: usedBy.toString(),
//                 label2: 'المكافأة لكل مستخدم',
//                 value2: '\$${rewardPerPerson.toStringAsFixed(2)}',
//                 total: referralEarnings,
//                 screenWidth: screenWidth,
//               ),
//
//               SizedBox(height: screenWidth * 0.04),
//
//               // عنوان قسم الدعم
//               Text(
//                 'مكافآت الدعم',
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.04,
//                   fontWeight: FontWeight.bold,
//                   color: KprimaryText,
//                 ),
//               ),
//               SizedBox(height: screenWidth * 0.04),
//
//               _buildRewardSection(
//                 label1: 'عدد مرات الدعم',
//                 value1: donations.toString(),
//                 label2: 'المكافأة لكل دعم',
//                 value2: '\$${rewardPerDonation.toStringAsFixed(2)}',
//                 total: donationEarnings,
//                 screenWidth: screenWidth,
//               ),
//
//               SizedBox(height: screenWidth * 0.04),
//               Text(
//                 'إجمالي الأرباح',
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.04,
//                   fontWeight: FontWeight.bold,
//                   color: KprimaryText,
//                 ),
//               ),
//               SizedBox(height: screenWidth * 0.04),
//               _buildTotalSection(
//                 screenWidth,
//                 screenHeight,
//                 totalEarnings,
//                 canWithdraw,
//                 context,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildReferralCodeBox(
//       String referralCode, double screenWidth, BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: screenWidth * 0.04,
//         vertical: screenWidth * 0.02,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(screenWidth * 0.02),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             referralCode,
//             style: TextStyle(
//               fontSize: screenWidth * 0.04,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1.2,
//               color: KprimaryText,
//             ),
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.copy_rounded,
//               color: const Color(0xffFF580E),
//               size: screenWidth * 0.05,
//             ),
//             onPressed: () {
//               Clipboard.setData(ClipboardData(text: referralCode));
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   behavior: SnackBarBehavior.floating,
//                   backgroundColor: Colors.orange.shade50,
//                   elevation: 8,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   duration: const Duration(seconds: 3),
//                   content: Row(
//                     children: [
//                       Container(
//                         decoration: const BoxDecoration(
//                           color: Color(0xffFF580E),
//                           shape: BoxShape.circle,
//                         ),
//                         padding: const EdgeInsets.all(8),
//                         child: Icon(
//                           Icons.check,
//                           color: Colors.white,
//                           size: screenWidth * 0.05,
//                         ),
//                       ),
//                       SizedBox(width: screenWidth * 0.02),
//                       Expanded(
//                         child: Text(
//                           'تم نسخ الكود بنجاح',
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.035,
//                             color: Colors.black87,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRewardSection({
//     required String label1,
//     required String value1,
//     required String label2,
//     required String value2,
//     required double total,
//     required double screenWidth,
//   }) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(screenWidth * 0.02),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _buildRow(label1, value1, screenWidth),
//           SizedBox(height: screenWidth * 0.02),
//           _buildRow(label2, value2, screenWidth),
//           SizedBox(height: screenWidth * 0.04),
//           Divider(thickness: 1, color: Colors.grey.shade300),
//           SizedBox(height: screenWidth * 0.02),
//           _buildRow('الإجمالي', '\$${total.toStringAsFixed(2)}', screenWidth,
//               valueColor: Colors.green),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTotalSection(double screenWidth, double screenHeight,
//       double totalEarnings, bool canWithdraw, BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(screenWidth * 0.04),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(screenWidth * 0.02),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'الإجمالي',
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.035,
//                   fontWeight: FontWeight.bold,
//                   color: KprimaryText,
//                 ),
//               ),
//               Text(
//                 '\$${totalEarnings.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.05,
//                   fontWeight: FontWeight.bold,
//                   color: KprimaryColor,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: screenWidth * 0.04),
//           SizedBox(
//             width: double.infinity,
//             height: screenHeight * 0.05,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: canWithdraw
//                     ? KprimaryColor
//                     : KprimaryColor.withOpacity(0.3),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: canWithdraw
//                   ? () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       'تم سحب \$${totalEarnings.toStringAsFixed(2)} بنجاح',
//                       style:
//                       TextStyle(fontSize: screenWidth * 0.035),
//                     ),
//                     backgroundColor: Colors.green.shade400,
//                   ),
//                 );
//               }
//                   : null,
//               child: Text(
//                 'سحب الأرباح',
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.035,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRow(String label, String value, double screenWidth,
//       {Color valueColor = Colors.black}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: screenWidth * 0.035,
//             color: Colors.black54,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: screenWidth * 0.035,
//             fontWeight: FontWeight.bold,
//             color: valueColor,
//           ),
//         ),
//       ],
//     );
//   }
// }

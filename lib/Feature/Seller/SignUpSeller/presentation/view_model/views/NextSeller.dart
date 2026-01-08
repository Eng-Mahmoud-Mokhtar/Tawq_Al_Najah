// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:tawqalnajah/core/utiles/colors.dart';
// import 'package:tawqalnajah/core/utiles/images.dart';
// import 'package:tawqalnajah/core/widgets/button.dart';
// import 'package:tawqalnajah/generated/l10n.dart';
// import 'PaymentSignUp.dart';
//
// class NextSignUp extends StatefulWidget {
//   const NextSignUp({super.key});
//   @override
//   State<NextSignUp> createState() => _NextSignUpState();
// }
//
// class _NextSignUpState extends State<NextSignUp> {
//   String? selectedContract;
//   String? selectedActivity;
//   final TextEditingController customDurationController =
//       TextEditingController();
//   final TextEditingController socialLinkController = TextEditingController();
//   final TextEditingController branchesCountController = TextEditingController();
//   final TextEditingController areaController = TextEditingController();
//   final TextEditingController pricePerMonthController = TextEditingController();
//   double pricePerMeter = 1.0;
//   final List<TextEditingController> branchLocationControllers = [];
//   final List<Map<String, dynamic>> socialLinks = [];
//   double totalPrice = 0.0;
//   int months = 0;
//   double monthlyPrice = 0.0;
//   @override
//   void dispose() {
//     customDurationController.dispose();
//     socialLinkController.dispose();
//     branchesCountController.dispose();
//     areaController.dispose();
//     pricePerMonthController.dispose();
//     for (var controller in branchLocationControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }
//
//   Map<String, dynamic>? detectPlatform(String url) {
//     if (url.contains('facebook')) {
//       return {
//         'name': 'Facebook',
//         'icon': FontAwesomeIcons.facebook,
//         'color': Colors.blue,
//       };
//     } else if (url.contains('instagram')) {
//       return {
//         'name': 'Instagram',
//         'icon': FontAwesomeIcons.instagram,
//         'color': Colors.purple,
//       };
//     } else if (url.contains('whatsapp') || url.contains('wa.me')) {
//       return {
//         'name': 'WhatsApp',
//         'icon': FontAwesomeIcons.whatsapp,
//         'color': Colors.green,
//       };
//     } else if (url.contains('snapchat')) {
//       return {
//         'name': 'Snapchat',
//         'icon': FontAwesomeIcons.snapchat,
//         'color': Colors.amber[700],
//       };
//     }
//     return null;
//   }
//
//   Widget buildField(
//     String label,
//     String hint, {
//     TextInputType? type,
//     String? suffix,
//     TextEditingController? controller,
//     Function(String)? onChanged,
//     bool readOnly = false,
//   }) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: KprimaryText,
//             fontSize: screenWidth * 0.035,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: screenHeight * 0.008),
//         SizedBox(
//           height: screenWidth * 0.12,
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//               color: readOnly ? Colors.grey.shade300 : const Color(0xffFAFAFA),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: const Color(0xffE9E9E9)),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: controller,
//                     onChanged: onChanged,
//                     readOnly: readOnly,
//                     keyboardType: type ?? TextInputType.text,
//                     style: TextStyle(
//                       fontSize: screenWidth * 0.03,
//                       color: KprimaryText,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: hint,
//                       hintStyle: TextStyle(
//                         fontSize: screenWidth * 0.03,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade600,
//                       ),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.symmetric(
//                         vertical: screenWidth * 0.035,
//                         horizontal: screenWidth * 0.035,
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (suffix != null)
//                   Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth * 0.035,
//                     ),
//                     child: Text(
//                       suffix,
//                       style: TextStyle(
//                         color: Colors.grey.shade700,
//                         fontSize: screenWidth * 0.03,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget buildActivityDropdown() {
//     final s = S.of(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final List<String> activities = [
//       s.fashion,
//       s.electronics,
//       s.health,
//       s.toys,
//       s.furniture,
//       s.kitchen,
//       s.books,
//       s.otherCategory,
//     ];
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           s.activityType,
//           style: TextStyle(
//             color: KprimaryText,
//             fontSize: screenWidth * 0.035,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         SizedBox(height: 8),
//         Container(
//           height: screenWidth * 0.12,
//           padding: EdgeInsets.symmetric(
//             horizontal: screenWidth * 0.035,
//             vertical: 4,
//           ),
//           decoration: BoxDecoration(
//             color: const Color(0xffFAFAFA),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: const Color(0xffE9E9E9)),
//           ),
//           child: DropdownButtonHideUnderline(
//             child: DropdownButton<String>(
//               value: selectedActivity,
//               hint: Text(
//                 s.enterActivityType,
//                 style: TextStyle(
//                   fontSize: screenWidth * 0.03,
//                   color: Colors.grey.shade600,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//               isExpanded: true,
//               icon: Icon(
//                 Icons.keyboard_arrow_down,
//                 color: Colors.grey,
//                 size: screenWidth * 0.05,
//               ),
//               dropdownColor: const Color(0xffFAFAFA),
//               style: TextStyle(
//                 fontSize: screenWidth * 0.03,
//                 color: KprimaryText,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Tajawal',
//               ),
//               items: activities.map((activity) {
//                 return DropdownMenuItem(value: activity, child: Text(activity));
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedActivity = value;
//                 });
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void updatePrice(String areaValue) {
//     double area = double.tryParse(areaValue) ?? 0;
//     monthlyPrice = area * pricePerMeter;
//     pricePerMonthController.text = monthlyPrice.toStringAsFixed(2);
//     calculateTotalPrice();
//   }
//
//   void calculateTotalPrice() {
//     final s = S.of(context);
//     if (selectedContract == s.threeMonths) {
//       months = 3;
//     } else if (selectedContract == s.sixMonths) {
//       months = 6;
//     } else if (selectedContract == s.oneYear) {
//       months = 12;
//     } else if (selectedContract == s.other) {
//       months = int.tryParse(customDurationController.text) ?? 0;
//     } else {
//       months = 0;
//     }
//     totalPrice = monthlyPrice * months;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final s = S.of(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       backgroundColor: SecoundColor,
//       body: Stack(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(screenWidth * 0.04),
//             child: CustomScrollView(
//               slivers: [
//                 SliverToBoxAdapter(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: screenHeight * 0.1),
//                       Center(
//                         child: Image.asset(
//                           KprimaryImage,
//                           width: screenWidth * 0.5,
//                           height: screenHeight * 0.15,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.05),
//                       Row(
//                         children: [
//                           Expanded(child: buildActivityDropdown()),
//                           SizedBox(width: screenWidth * 0.03),
//                           Expanded(
//                             child: buildField(
//                               s.branchesCount,
//                               s.enterBranchesCount,
//                               type: TextInputType.number,
//                               controller: branchesCountController,
//                               onChanged: (value) {
//                                 int count = int.tryParse(value) ?? 0;
//                                 setState(() {
//                                   branchLocationControllers.clear();
//                                   for (int i = 0; i < count; i++) {
//                                     branchLocationControllers.add(
//                                       TextEditingController(),
//                                     );
//                                   }
//                                 });
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                       if (branchLocationControllers.isNotEmpty) ...[
//                         SizedBox(height: screenHeight * 0.02),
//                         Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: List.generate(
//                             branchLocationControllers.length,
//                             (index) => Padding(
//                               padding: EdgeInsets.only(
//                                 bottom: screenHeight * 0.02,
//                               ),
//                               child: buildField(
//                                 "${s.branch} ${index + 1}",
//                                 s.enterBranchLocation,
//                                 controller: branchLocationControllers[index],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                       SizedBox(height: screenHeight * 0.02),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: buildField(
//                               s.totalArea,
//                               s.enterTotalArea,
//                               type: TextInputType.number,
//                               controller: areaController,
//                               suffix: "م²",
//                               onChanged: updatePrice,
//                             ),
//                           ),
//                           SizedBox(width: screenWidth * 0.03),
//                           Expanded(
//                             child: buildField(
//                               s.monthlyPrice,
//                               "0.00",
//                               controller: pricePerMonthController,
//                               suffix: "\$",
//                               readOnly: true,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: screenHeight * 0.03),
//                       Text(
//                         s.contractDuration,
//                         style: TextStyle(
//                           color: KprimaryText,
//                           fontSize: screenWidth * 0.035,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.01),
//                       Wrap(
//                         spacing: screenWidth * 0.05,
//                         runSpacing: 8,
//                         children:
//                             [s.threeMonths, s.sixMonths, s.oneYear, s.other]
//                                 .map(
//                                   (value) => IntrinsicHeight(
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Radio<String>(
//                                           value: value,
//                                           groupValue: selectedContract,
//                                           onChanged: (val) {
//                                             setState(() {
//                                               selectedContract = val;
//                                               if (val != s.other) {
//                                                 customDurationController
//                                                     .clear();
//                                               }
//                                               calculateTotalPrice();
//                                             });
//                                           },
//                                           activeColor: KprimaryColor,
//                                           materialTapTargetSize:
//                                               MaterialTapTargetSize.shrinkWrap,
//                                         ),
//                                         SizedBox(width: 4),
//                                         Text(
//                                           value,
//                                           style: TextStyle(
//                                             fontSize: screenWidth * 0.03,
//                                             fontWeight: FontWeight.bold,
//                                             color: KprimaryText,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 )
//                                 .toList(),
//                       ),
//                       if (selectedContract == s.other) ...[
//                         SizedBox(height: screenHeight * 0.015),
//                         buildField(
//                           s.customDuration,
//                           s.enterCustomDuration,
//                           controller: customDurationController,
//                           type: TextInputType.number,
//                           onChanged: (value) {
//                             calculateTotalPrice();
//                           },
//                         ),
//                       ],
//                       SizedBox(height: screenHeight * 0.02),
//                       Text(
//                         s.uploadDocs,
//                         style: TextStyle(
//                           color: KprimaryText,
//                           fontSize: screenWidth * 0.035,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.01),
//                       Container(
//                         width: double.infinity,
//                         height: screenWidth * 0.2,
//                         decoration: BoxDecoration(
//                           color: const Color(0xffFAFAFA),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: const Color(0xffE9E9E9)),
//                         ),
//                         child: Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.cloud_upload_outlined,
//                                 size: screenWidth * 0.05,
//                                 color: Colors.grey.shade600,
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 s.addFile,
//                                 style: TextStyle(
//                                   color: Colors.grey.shade600,
//                                   fontSize: screenWidth * 0.03,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.02),
//                       Text(
//                         s.socialLinks,
//                         style: TextStyle(
//                           color: KprimaryText,
//                           fontSize: screenWidth * 0.035,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.01),
//                       Column(
//                         children: socialLinks
//                             .map(
//                               (link) => Container(
//                                 margin: EdgeInsets.only(
//                                   bottom: screenHeight * 0.01,
//                                 ),
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: screenWidth * 0.03,
//                                 ),
//                                 height: screenWidth * 0.12,
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xffFAFAFA),
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: const Color(0xffE9E9E9),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(link['icon'], color: link['color']),
//                                     SizedBox(width: screenWidth * 0.03),
//                                     Expanded(
//                                       child: Text(
//                                         link['url'],
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: screenWidth * 0.03,
//                                           color: KprimaryText,
//                                         ),
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                     IconButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           socialLinks.remove(link);
//                                         });
//                                       },
//                                       icon: const Icon(
//                                         Icons.close,
//                                         color: Color(0xffDD0C0C),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                       ),
//                       if (socialLinks.length < 3)
//                         SizedBox(
//                           height: screenWidth * 0.12,
//                           child: DecoratedBox(
//                             decoration: BoxDecoration(
//                               color: const Color(0xffFAFAFA),
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(
//                                 color: const Color(0xffE9E9E9),
//                               ),
//                             ),
//                             child: TextField(
//                               controller: socialLinkController,
//                               onSubmitted: (value) {
//                                 final platform = detectPlatform(value.trim());
//                                 if (platform != null &&
//                                     value.trim().isNotEmpty) {
//                                   setState(() {
//                                     socialLinks.add({
//                                       'url': value.trim(),
//                                       'icon': platform['icon'],
//                                       'color': platform['color'],
//                                     });
//                                     socialLinkController.clear();
//                                   });
//                                 }
//                               },
//                               style: TextStyle(
//                                 fontSize: screenWidth * 0.03,
//                                 color: KprimaryText,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               decoration: InputDecoration(
//                                 hintText: s.enterSocialLink,
//                                 hintStyle: TextStyle(
//                                   fontSize: screenWidth * 0.03,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.grey.shade600,
//                                 ),
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   vertical: screenWidth * 0.035,
//                                   horizontal: screenWidth * 0.035,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       SizedBox(height: screenHeight * 0.05),
//                       Button(
//                         text: s.Next,
//                         onPressed: () {
//                           calculateTotalPrice();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => PaymentPage(
//                                 totalPrice: totalPrice,
//                                 months: months,
//                                 monthlyPrice: monthlyPrice,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       SizedBox(height: screenHeight * 0.05),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             top: screenHeight * 0.01,
//             child: SafeArea(
//               child: IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: Icon(
//                   Icons.arrow_back_ios_new,
//                   color: KprimaryText,
//                   size: screenHeight * 0.03,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

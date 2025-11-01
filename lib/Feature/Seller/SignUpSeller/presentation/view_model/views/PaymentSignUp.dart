import 'package:flutter/material.dart';
import '../../../../../../Core/Widgets/Button.dart';
import '../../../../../../Core/utiles/Colors.dart';
import 'SuccessPage.dart';
import '../../../../../../generated/l10n.dart'; // استدعاء Localization

class PaymentPage extends StatelessWidget {
  final double totalPrice;
  final int months;
  final double monthlyPrice;

  const PaymentPage({
    super.key,
    required this.totalPrice,
    required this.months,
    required this.monthlyPrice,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: SecoundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.13),
                Text(
                  S.of(context).subscriptionDetails, // "تفاصيل الاشتراك"
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                    color: KprimaryText,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: screenWidth * 0.025,
                        offset: Offset(0, screenWidth * 0.01),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPriceRow(context, S.of(context).monthlyPrice, "${monthlyPrice.toStringAsFixed(0)} ${S.of(context).SYP}"),
                      _buildPriceRow(context, S.of(context).duration, "$months ${S.of(context).months}"),
                      Divider(height: screenHeight * 0.03, thickness: 1),
                      _buildPriceRow(
                        context,
                        S.of(context).total, // "الإجمالي"
                        "${totalPrice.toStringAsFixed(0)} ${S.of(context).SYP}",
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  S.of(context).choosePaymentMethod, // "اختر طريقة الدفع"
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                    color: KprimaryText,
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                _buildPaymentOption(
                  context,
                  image: 'Assets/visa.png',
                  title: S.of(context).visa, // "Visa"
                  subtitle: S.of(context).payWithVisa, // "ادفع باستخدام بطاقة فيزا الخاصة بك"
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildPaymentOption(
                  context,
                  image: 'Assets/card.png',
                  title: S.of(context).masterCard, // "MasterCard"
                  subtitle: S.of(context).payWithMasterCard, // "ادفع باستخدام بطاقة ماستر كارد"
                ),
                SizedBox(height: screenHeight * 0.02),
                Button(
                  text: S.of(context).payNow, // "ادفع الآن"
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const SuccessPage()),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.01,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: KprimaryText,
                  size: screenHeight * 0.03,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value, {bool isTotal = false}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.033,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: KprimaryText.withOpacity(isTotal ? 1 : 0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
              color: isTotal ? KprimaryColor : KprimaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      BuildContext context, {
        required String image,
        required String title,
        required String subtitle,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      borderRadius: BorderRadius.circular(screenWidth * 0.03),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SuccessPage()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: screenWidth * 0.02,
              offset: Offset(0, screenWidth * 0.01),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: screenWidth * 0.15,
              width: screenWidth * 0.15,
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Image.asset(image, fit: BoxFit.contain),
            ),
            SizedBox(width: screenWidth * 0.02),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      color: KprimaryText,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: screenWidth * 0.05, color: KprimaryColor),
          ],
        ),
      ),
    );
  }
}

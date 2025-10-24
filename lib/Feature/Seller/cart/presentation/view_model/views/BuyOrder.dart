import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../../Core/Widgets/AppBar.dart';

class BuyOrder extends StatefulWidget {
  final Map<String, dynamic> productData;

  const BuyOrder({super.key, required this.productData});

  @override
  _BuyOrderState createState() => _BuyOrderState();
}

class _BuyOrderState extends State<BuyOrder> {
  bool isCashSelected = true;
  bool isVisaSelected = false;
  bool showCreditCardForm = false;

  final GlobalKey<FormState> cardFormKey = GlobalKey<FormState>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  void _togglePaymentMethod(bool isCash) {
    setState(() {
      if (isCash) {
        isCashSelected = true;
        isVisaSelected = false;
        showCreditCardForm = false;
      } else {
        isCashSelected = false;
        isVisaSelected = true;
        showCreditCardForm = true;
      }
    });
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
    final bool isArabic = textDirection == TextDirection.rtl;
    final List<dynamic> items = widget.productData['items'] ?? [];
    final double subtotal = widget.productData['subtotal'] ?? 0.0;
    final double shipping = widget.productData['shippingCost'] ?? 0.0;
    final double total = widget.productData['total'] ?? subtotal + shipping;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(
        title: S.of(context).orderDetails,
      ),
      body: Directionality(
        textDirection: textDirection,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Center(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...items.map((item) {
                      final product = item['ad'];
                      final int quantity = item['quantity'];
                      final double price = product['price'];
                      final double itemTotal = price * quantity;

                      return Container(
                        margin: EdgeInsets.only(bottom: screenWidth * 0.02),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          child: Directionality(
                            textDirection: TextDirection.rtl, // 👈 دا بيخلي الاتجاه ثابت من اليمين لليسار دائمًا
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  product['images']?[0] ?? 'Assets/fallback_image.png',
                                  width: screenWidth * 0.18,
                                  height: screenWidth * 0.18,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.image,
                                    size: screenWidth * 0.15,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? S.of(context).unknown,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: screenWidth * 0.01),
                                      Text(
                                        product['description'] ?? S.of(context).noDescription,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: screenWidth * 0.015),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Wrap(
                                            direction: Axis.horizontal,
                                            spacing: screenWidth * 0.02,
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
                                                  'x$quantity',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: screenWidth * 0.025,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                product['category'] ?? S.of(context).categoryUnknown,
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.03,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            itemTotal.toStringAsFixed(2),
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.03,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xffFF580E),
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: screenWidth * 0.04),
                    Text(
                      S.of(context).paymentMethod,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    GestureDetector(
                      onTap: () => _togglePaymentMethod(true),
                      child: Container(
                        height: screenWidth * 0.12,
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            textDirection == TextDirection.rtl
                                ? Checkbox(
                              value: isCashSelected,
                              onChanged: (_) => _togglePaymentMethod(true),
                              activeColor: KprimaryColor,
                            )
                                : Expanded(
                              child: Text(
                                S.of(context).cash,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            textDirection == TextDirection.rtl
                                ? Expanded(
                              child: Text(
                                S.of(context).cash,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                                : Checkbox(
                              value: isCashSelected,
                              onChanged: (_) => _togglePaymentMethod(true),
                              activeColor: KprimaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.02),
                    GestureDetector(
                      onTap: () => _togglePaymentMethod(false),
                      child: Container(
                        height: screenWidth * 0.12,
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            textDirection == TextDirection.rtl
                                ? Checkbox(
                              value: isVisaSelected,
                              onChanged: (_) => _togglePaymentMethod(false),
                              activeColor: KprimaryColor,
                            )
                                : Expanded(
                              child: Text(
                                S.of(context).visa,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            textDirection == TextDirection.rtl
                                ? Expanded(
                              child: Text(
                                S.of(context).visa,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                                : Checkbox(
                              value: isVisaSelected,
                              onChanged: (_) => _togglePaymentMethod(false),
                              activeColor: KprimaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (showCreditCardForm) ...[
                      SizedBox(height: screenWidth * 0.04),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: CreditCardWidget(
                            cardNumber: cardNumber,
                            expiryDate: expiryDate,
                            cardHolderName: cardHolderName,
                            cvvCode: cvvCode,
                            showBackView: isCvvFocused,
                            cardBgColor: KprimaryColor,
                            obscureCardNumber: true,
                            obscureCardCvv: true,
                            isHolderNameVisible: true,
                            onCreditCardWidgetChange: (_) {},
                            customCardTypeIcons: <CustomCardTypeIcon>[
                              CustomCardTypeIcon(
                                cardType: CardType.visa,
                                cardImage: Image.asset(
                                  'Assets/visa.png',
                                  height: screenWidth * 0.05,
                                  width: screenWidth * 0.05,
                                ),
                              ),
                              CustomCardTypeIcon(
                                cardType: CardType.mastercard,
                                cardImage: Image.asset(
                                  'Assets/card.png',
                                  height: screenWidth * 0.05,
                                  width: screenWidth * 0.05,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: KprimaryColor,
                          colorScheme: ColorScheme.light(primary: KprimaryColor),
                        ),
                        child: CreditCardForm(
                          formKey: cardFormKey,
                          cardNumber: cardNumber,
                          expiryDate: expiryDate,
                          cvvCode: cvvCode,
                          cardHolderName: cardHolderName,
                          onCreditCardModelChange: onCreditCardModelChange,
                          inputConfiguration: InputConfiguration(
                            cardNumberDecoration: InputDecoration(
                              labelText: S.of(context).cardNumber,
                              labelStyle: TextStyle(
                                color: KprimaryText,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: 'XXXX XXXX XXXX XXXX',
                              hintStyle: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                              filled: true,
                              fillColor: const Color(0xffFAFAFA),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.035,
                                horizontal: screenWidth * 0.035,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xffE9E9E9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: KprimaryText),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            expiryDateDecoration: InputDecoration(
                              labelText: S.of(context).expiryDate,
                              labelStyle: TextStyle(
                                color: KprimaryText,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: 'MM/YY',
                              hintStyle: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                              filled: true,
                              fillColor: const Color(0xffFAFAFA),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.035,
                                horizontal: screenWidth * 0.035,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xffE9E9E9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: KprimaryText),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            cvvCodeDecoration: InputDecoration(
                              labelText: S.of(context).cvv,
                              labelStyle: TextStyle(
                                color: KprimaryText,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: 'XXX',
                              hintStyle: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                              filled: true,
                              fillColor: const Color(0xffFAFAFA),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.035,
                                horizontal: screenWidth * 0.035,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xffE9E9E9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: KprimaryText),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            cardHolderDecoration: InputDecoration(
                              labelText: S.of(context).cardHolderName,
                              labelStyle: TextStyle(
                                color: KprimaryText,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: S.of(context).FullName,
                              hintStyle: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                              filled: true,
                              fillColor: const Color(0xffFAFAFA),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.035,
                                horizontal: screenWidth * 0.035,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xffE9E9E9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: KprimaryText),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: screenWidth * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            S.of(context).subtotal,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff4D4D4D),
                            ),
                          ),
                        ),
                        Text(
                          subtotal.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: isArabic ? TextAlign.left : TextAlign.right,
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            S.of(context).shippingCost,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff4D4D4D),
                            ),
                          ),
                        ),
                        Text(
                          shipping.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: isArabic ? TextAlign.left : TextAlign.right,
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    Divider(color: KprimaryText, thickness: 1),
                    SizedBox(height: screenWidth * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            S.of(context).totalLabel,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          total.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xffFF580E),
                          ),
                          textAlign: isArabic ? TextAlign.left : TextAlign.right,
                        ),
                      ],
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isVisaSelected && cardFormKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: KprimaryColor,
                                content: Text(S.of(context).paymentSuccess),
                              ),
                            );
                          } else if (isCashSelected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: KprimaryColor,
                                content: Text(S.of(context).orderSuccess),
                              ),
                            );
                          }
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
                              S.of(context).completePurchase,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                                color: SecoundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

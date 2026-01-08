import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:shimmer/shimmer.dart';
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
  bool _isLoading = false;
  bool _isDataLoading = true;

  final GlobalKey<FormState> cardFormKey = GlobalKey<FormState>();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isDataLoading = false;
        });
      }
    });
  }

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

  void _placeOrder() {
    if (_isLoading) return;

    if (isVisaSelected && !cardFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;
    final List<dynamic> items = widget.productData['items'] ?? [];
    final double subtotal = widget.productData['subtotal'] ?? 0.0;
    final double shipping = widget.productData['shippingCost'] ?? 0.0;
    final double total = widget.productData['total'] ?? subtotal + shipping;
    final String mainCurrency = widget.productData['currency'] ?? 'SYP';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(
        title: S.of(context).orderDetails,
      ),
      body: _isDataLoading
          ? Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: screenWidth * 0.45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(bottom: screenWidth * 0.03),
              ),
              Container(
                width: double.infinity,
                height: screenWidth * 0.25,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(bottom: screenWidth * 0.03),
              ),
              Container(
                width: double.infinity,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(bottom: screenWidth * 0.03),
              ),
              Container(
                width: double.infinity,
                height: screenWidth * 0.1,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(bottom: screenWidth * 0.03),
              ),
              Container(
                width: double.infinity,
                height: screenWidth * 0.14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      )
          : Directionality(
        textDirection: textDirection,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                      Text(
                        S.of(context).orderSummary,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: KprimaryText,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      ...items.map((item) {
                        final product = item['ad'];
                        final apiData = item['api_data'] ?? {};
                        final int quantity = item['quantity'];
                        final double price = product['price_after_discount'] ?? product['price'];
                        final double itemTotal = price * quantity;

                        // استخراج العملة من بيانات المنتج نفسه
                        final String productCurrency = apiData['product_currency'] ??
                            product['currency'] ??
                            S.of(context).SYP;

                        return Container(
                          margin: EdgeInsets.only(bottom: screenWidth * 0.015),
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: screenWidth * 0.15,
                                height: screenWidth * 0.15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[100],
                                ),
                                child: product['images'] != null && product['images'].isNotEmpty
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    product['images'][0],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Icon(
                                        Icons.shopping_bag,
                                        size: screenWidth * 0.08,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                )
                                    : Center(
                                  child: Icon(
                                    Icons.shopping_bag,
                                    size: screenWidth * 0.08,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? S.of(context).unknown,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        fontWeight: FontWeight.bold,
                                        color: KprimaryText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: screenWidth * 0.005),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02,
                                            vertical: screenWidth * 0.008,
                                          ),
                                          decoration: BoxDecoration(
                                            color: KprimaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'x$quantity',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.025,
                                              fontWeight: FontWeight.bold,
                                              color: KprimaryColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Text(
                                          '$productCurrency ${itemTotal.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.03,
                                            color: const Color(0xffFF580E),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                SizedBox(height: screenWidth * 0.03),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                      Text(
                        S.of(context).paymentMethod,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: KprimaryText,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      GestureDetector(
                        onTap: () => _togglePaymentMethod(true),
                        child: Container(
                          height: screenWidth * 0.12,
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          margin: EdgeInsets.only(bottom: screenWidth * 0.01),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isCashSelected ? KprimaryColor : Colors.grey.shade300,
                              width: isCashSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isCashSelected ? KprimaryColor.withOpacity(0.05) : Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).cash,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w600,
                                  color: isCashSelected ? KprimaryColor : KprimaryText,
                                ),
                              ),
                              Container(
                                width: screenWidth * 0.06,
                                height: screenWidth * 0.06,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isCashSelected ? KprimaryColor : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isCashSelected
                                    ? Center(
                                  child: Container(
                                    width: screenWidth * 0.03,
                                    height: screenWidth * 0.03,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: KprimaryColor,
                                    ),
                                  ),
                                )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _togglePaymentMethod(false),
                        child: Container(
                          height: screenWidth * 0.12,
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isVisaSelected ? KprimaryColor : Colors.grey.shade300,
                              width: isVisaSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isVisaSelected ? KprimaryColor.withOpacity(0.05) : Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).visa,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w600,
                                  color: isVisaSelected ? KprimaryColor : KprimaryText,
                                ),
                              ),
                              Container(
                                width: screenWidth * 0.06,
                                height: screenWidth * 0.06,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isVisaSelected ? KprimaryColor : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isVisaSelected
                                    ? Center(
                                  child: Container(
                                    width: screenWidth * 0.03,
                                    height: screenWidth * 0.03,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: KprimaryColor,
                                    ),
                                  ),
                                )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (showCreditCardForm) ...[
                  SizedBox(height: screenWidth * 0.03),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                      children: [
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
                            ),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.03),
                        CreditCardForm(
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
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xffE9E9E9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: KprimaryText),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xffE9E9E9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: KprimaryText),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xffE9E9E9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: KprimaryText),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xffE9E9E9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: KprimaryText),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
                SizedBox(height: screenWidth * 0.03),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).subtotal,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: KprimaryText,
                            ),
                          ),
                          Text(
                            '$mainCurrency ${subtotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600,
                              color: KprimaryText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.015),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).shippingCost,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: KprimaryText,
                            ),
                          ),
                          Text(
                            '$mainCurrency ${shipping.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600,
                              color: KprimaryText,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.02),
                      Divider(color: Colors.grey[300], height: 1),
                      SizedBox(height: screenWidth * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            S.of(context).total,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: KprimaryText,
                            ),
                          ),
                          Text(
                            '$mainCurrency ${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xffFF580E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: KprimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: KprimaryColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: KprimaryColor,
                        size: screenWidth * 0.05,
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Text(
                          isCashSelected
                              ? S.of(context).cashDeliveryNote
                              : S.of(context).cardPaymentNote,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: KprimaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading ? Colors.grey : KprimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      _isLoading ? S.of(context).processing : S.of(context).completePurchase,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                        color: SecoundColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
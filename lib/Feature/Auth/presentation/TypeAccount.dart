import 'package:flutter/material.dart';
import '../../../../../Core/utiles/Colors.dart';
import '../../../../../Core/utiles/Images.dart';
import '../../../../../generated/l10n.dart';
import '../../Buyer/SignUpBuyer/presentation/view_model/views/sign_up_buyer.dart';
import '../../Seller/SignUpSeller/presentation/view_model/views/SignUpSeller.dart';
import 'SocialPartnership.dart';

class TypeAccount extends StatefulWidget {
  const TypeAccount({Key? key}) : super(key: key);

  @override
  State<TypeAccount> createState() => _TypeAccountState();
}

class _TypeAccountState extends State<TypeAccount> {
  String? selectedAccount;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: SecoundColor,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1),
                Image.asset(
                  KprimaryImage,
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.15,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.1),
                Text(
                  S.of(context).ChooseAccountType,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: KprimaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAccountBox(
                      context,
                      icon: Icons.storefront_outlined,
                      label: S.of(context).seller,
                      isSelected: selectedAccount == "seller",
                      onTap: () {
                        setState(() {
                          selectedAccount = "seller";
                        });
                      },
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),
                    _buildAccountBox(
                      context,
                      icon: Icons.shopping_cart_outlined,
                      label: S.of(context).buyer,
                      isSelected: selectedAccount == "buyer",
                      onTap: () {
                        setState(() {
                          selectedAccount = "buyer";
                        });
                      },
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SocialPartnership(),
                      ),
                    );
                  },
                  child: Text(
                    S.of(context).CommunityPartnerships,
                    style: TextStyle(
                      color: KprimaryColor,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: screenWidth * 0.12,
                  child: ElevatedButton(
                    onPressed: selectedAccount == null
                        ? null
                        : () {
                      if (selectedAccount == "seller") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpSeller(),
                          ),
                        );
                      } else if (selectedAccount == "buyer") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpBuyer(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedAccount == null
                          ? Colors.grey[400]
                          : KprimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      S.of(context).Next,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.01,
            child: SafeArea(
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
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

  Widget _buildAccountBox(
      BuildContext context, {
        required IconData icon,
        required String label,
        required bool isSelected,
        required VoidCallback onTap,
        required double screenWidth,
        required double screenHeight,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: screenWidth * 0.35,
        height: screenHeight * 0.2,
        decoration: BoxDecoration(
          color: isSelected ? KprimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          border: Border.all(color: KprimaryColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: screenWidth * 0.1,
              color: isSelected ? Colors.white : KprimaryColor,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : KprimaryColor,
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

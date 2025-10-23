import 'package:flutter/material.dart';
import '../../../../../Core/Widgets/code.dart';
import '../../../../../Core/utiles/Colors.dart';
import '../../../../../Core/utiles/Images.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../Core/Widgets/Button.dart';
import '../../../../Seller/Home/presentation/view_model/views/HomeStructure.dart';

class ResetCode extends StatelessWidget {
  const ResetCode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: SecoundColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.12),
                  Image.asset(
                    KprimaryImage,
                    width: screenWidth * 0.5,
                    height: screenHeight * 0.15,

                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Text(
                    S.of(context).VerifyPhoneNumber,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    S.of(context).SubVerifyPhoneNumber,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: SecoundText,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  const Code(),
                  SizedBox(height: screenHeight * 0.04),
                  Button(text:S.of(context).Verify, onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeStructure()),
                    );
                  },
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: KprimaryColor.withOpacity(0.4),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.03,
                        decoration: TextDecoration.underline,
                        decorationColor: KprimaryColor.withOpacity(0.4),
                      ),
                    ),
                    child:  Text( S.of(context).ResendCode),
                  ),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../Feature/Auth/presentation/login.dart';
import '../../generated/l10n.dart';
import '../utiles/Colors.dart';
class AlreadyHaveAccount extends StatelessWidget {
  const AlreadyHaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.of(context).AlreadyHaveAnAccount,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: screenWidth * 0.03,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: screenWidth * 0.0125),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
          child: Text(
            S.of(context).login,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: screenWidth * 0.03,
              color:KprimaryColor,
              decoration: TextDecoration.underline,
              decorationColor: KprimaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

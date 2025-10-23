import 'package:flutter/material.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../TypeAccount.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.of(context).NotAMember,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: screenWidth * 0.03,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: screenWidth * 0.0125),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TypeAccount()),
            );
          },
          child: Text(
            S.of(context).SignUp,
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

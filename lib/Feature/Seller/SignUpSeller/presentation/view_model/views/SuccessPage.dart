import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Auth/presentation/view_model/views/login.dart';
import '../../../../../../Core/Widgets/Button.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: SecoundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'Assets/Business mission-rafiki.png',
                width: screenWidth * 0.8,
              ),
              Text(
                s.requestSent,
                style: TextStyle(
                  color: KprimaryText,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                s.requestReview,
                style: TextStyle(
                color: Colors.grey,
                fontSize: screenWidth * 0.035,
              ),
          textAlign: TextAlign.center,
        ),
              SizedBox(height: screenHeight * 0.06),
              Button(
                text: s.login,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

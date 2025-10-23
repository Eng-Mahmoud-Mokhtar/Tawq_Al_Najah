import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Auth/presentation/view_model/views/widgets/dontHaveAccountRow.dart';
import 'package:tawqalnajah/Feature/Seller/Home/presentation/view_model/views/HomeStructure.dart';
import '../../../../../Core/Widgets/phoneNumber.dart';
import '../../../../../Core/utiles/Colors.dart';
import '../../../../../Core/utiles/Images.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../Core/Widgets/Button.dart';
import 'Reset Code.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: SecoundColor,
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeight * 0.1),
                      Image.asset(
                        KprimaryImage,
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.15,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: screenHeight * 0.2),
                      const PhoneNumber(),
                      SizedBox(height: screenHeight * 0.03),
                      Button(
                        text: S.of(context).login,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ResetCode()),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      const CreateAccount(),
                    ],
                  ),
                  Positioned(
                    top: screenHeight * 0.01,
                    child: SafeArea(
                      child: IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomeStructure()),
                          );                        },
                        icon: Icon(
                          Icons.close,
                          color: KprimaryText,
                          size: screenHeight * 0.03,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

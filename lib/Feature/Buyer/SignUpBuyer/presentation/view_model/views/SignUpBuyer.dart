import 'package:flutter/material.dart';
import 'package:tawqalnajah/Core/Widgets/ReferralCode.dart';
import '../../../../../../Core/Widgets/Button.dart';
import '../../../../../../Core/Widgets/Country&city.dart';
import '../../../../../../Core/Widgets/Location.dart';
import 'widgets/Name.dart';
import '../../../../../../Core/Widgets/alreadyHaveAccount.dart';
import '../../../../../../Core/Widgets/phoneNumber.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../Core/utiles/Images.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../Auth/presentation/view_model/views/login.dart';

class SignUpBuyer extends StatelessWidget {
  const SignUpBuyer({Key? key}) : super(key: key);

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
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.1),
                      Center(
                        child: Image.asset(
                          KprimaryImage,
                          width: screenWidth * 0.5,
                          height: screenHeight * 0.15,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Name(),
                          SizedBox(height: screenHeight * 0.02),
                          const PhoneNumber(),
                          SizedBox(height: screenHeight * 0.02),
                          const ReferralCode(),
                          SizedBox(height: screenHeight * 0.02),
                          CountryCity(),
                          SizedBox(height: screenHeight * 0.02),
                          Location(),
                          SizedBox(height: screenHeight * 0.02),
                          Button(
                            text: S.of(context).SignUp,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Login(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          const AlreadyHaveAccount(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.01,
            child: SafeArea(
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);                        },
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
}


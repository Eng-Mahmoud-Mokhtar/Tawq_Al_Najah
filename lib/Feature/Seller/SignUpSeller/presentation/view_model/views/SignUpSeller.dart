import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Seller/SignUpSeller/presentation/view_model/views/widgets/NameSeller.dart';
import 'package:tawqalnajah/core/utiles/colors.dart';
import 'package:tawqalnajah/core/utiles/images.dart';
import 'package:tawqalnajah/core/widgets/button.dart';
import 'package:tawqalnajah/core/widgets/location.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../Core/Widgets/Country&city.dart';
import '../../../../../../Core/Widgets/ReferralCode.dart';
import '../../../../../../Core/Widgets/alreadyHaveAccount.dart';
import '../../../../../../Core/Widgets/phoneNumber.dart';
import 'NextSeller.dart';

class SignUpSeller extends StatefulWidget {
  const SignUpSeller({Key? key}) : super(key: key);
  @override
  State<SignUpSeller> createState() => _SignUpSellerState();
}

class _SignUpSellerState extends State<SignUpSeller> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
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
                          const NameSeller(),
                          SizedBox(height: screenHeight * 0.02),
                          PhoneNumber(),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            S.of(context).email,
                            style: TextStyle(
                              color: KprimaryText,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          SizedBox(
                            height: screenWidth * 0.12,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xffFAFAFA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xffE9E9E9),
                                ),
                              ),
                              child: TextField(
                                controller: _emailController,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: KprimaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                  hintText: S.of(context).email,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.035,
                                    horizontal: screenWidth * 0.035,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            S.of(context).password,
                            style: TextStyle(
                              color: KprimaryText,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          SizedBox(
                            height: screenWidth * 0.12,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xffFAFAFA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xffE9E9E9),
                                ),
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: KprimaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                  ),
                                  hintText: S.of(context).password,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.035,
                                    horizontal: screenWidth * 0.035,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey.shade600,
                                      size: screenWidth * 0.05,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          const ReferralCode(),
                          SizedBox(height: screenHeight * 0.02),
                          CountryCity(),
                          SizedBox(height: screenHeight * 0.02),
                          Location(),
                          SizedBox(height: screenHeight * 0.02),
                          Button(
                            text: S.of(context).Next,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NextSignUp(),
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
}

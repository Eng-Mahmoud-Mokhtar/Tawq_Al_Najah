import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tawqalnajah/Core/Widgets/buildLanguage.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';
import 'package:tawqalnajah/Feature/Seller/More/presentation/view_model/views/widgets/AccountInfoSeller.dart';
import 'package:tawqalnajah/Feature/Seller/More/presentation/view_model/views/widgets/BankAccount.dart';
import 'package:tawqalnajah/Feature/Seller/More/presentation/view_model/views/widgets/EditProfile.dart';
import 'package:tawqalnajah/Feature/Seller/More/presentation/view_model/views/widgets/RewardsPage.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../Auth/presentation/view_model/views/login.dart';
import '../../../../../Buyer/More/presentation/view_model/views/AboutUs.dart';
import '../../../../../Buyer/More/presentation/view_model/views/PrivacyPolicy.dart';
import '../../../../../Buyer/More/presentation/view_model/views/Support.dart';
import '../../../../../Buyer/More/presentation/view_model/views/TermsConditions.dart';
import '../../../../../Buyer/More/presentation/view_model/views/widgets/buildProfileOption.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});
  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  File? _profileImage;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final locale = Localizations.localeOf(context);

    List<Widget> profileItems(BuildContext context) => [
      buildProfileOption(
        context,
        label: S.of(context).AccountInfo,
        imagePath: 'Assets/ثيهف.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const AccountInfoSeller(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).bankAccount,
        imagePath: 'Assets/credit-card.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const BankAccountPage(),
      ),
      buildLanguageSwapOption(
        context,
        locale: locale,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),
      buildProfileOption(
        context,
        label: S.of(context).AppSupport,
        imagePath: 'Assets/fluent_people-community-32-regular.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const Support(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).Rewards,
        imagePath: 'Assets/hand.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const RewardsPage(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).AboutUs,
        imagePath: 'Assets/icons8-about-48.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const AboutUs(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).PrivacyPolicy,
        imagePath: 'Assets/ic_sharp-security.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const PrivacyPolicy(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).TermsandConditions,
        imagePath: 'Assets/icons8-terms-and-conditions-48.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const TermsConditions(),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
        child: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.012),
            decoration: BoxDecoration(
              color: const Color(0xffDD0C0C),
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'Assets/log-out.png',
                  color: Colors.white,
                  width: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  S.of(context).logout,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBarWithBottomB(title: S.of(context).more),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            decoration: BoxDecoration(
              color: const Color(0xfffafafa),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileSeller()),
                    );
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfffafafa),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.005),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: KprimaryColor.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: screenWidth * 0.06,
                                backgroundColor: Colors.white,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: _profileImage == null
                                    ? Icon(
                                  Icons.person,
                                  color: KprimaryText,
                                  size: screenWidth * 0.05,
                                )
                                    : null,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   Text(
                                    "محمود استور",
                                    style: TextStyle(
                                      fontSize:  screenWidth * 0.035,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${S.of(context).joinedSince} 25/10/2025",
                                    style: TextStyle(
                                      fontSize:  screenWidth * 0.03,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.mode_edit_outlined,
                              color: KprimaryColor,
                              size: screenWidth * 0.06,
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              decoration: BoxDecoration(
                color: SecoundColor,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: ListView.separated(
                itemCount: profileItems(context).length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.grey.shade100,
                  thickness: 1,
                  height: screenHeight * 0.01,
                ),
                itemBuilder: (context, index) => profileItems(context)[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:tawqalnajah/Core/Widgets/buildLanguage.dart';
import 'package:tawqalnajah/Feature/Buyer/More/presentation/view_model/views/widgets/buildProfileOption.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../Auth/presentation/view_model/views/login.dart';
import '../../../../MyShipment/presentation/view_model/views/MyShipmentsPage.dart';
import 'AboutUs.dart';
import 'EditProfile.dart';
import 'Favorite.dart';
import 'PrivacyPolicy.dart';
import 'InviteFriends.dart';
import 'Support.dart';
import 'TermsConditions.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, String>? selectedCountry;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final locale = Localizations.localeOf(context);

    List<Widget> profileItems(BuildContext context) => [
      buildProfileOption(
        context,
        label: S.of(context).editProfile,
        imagePath: 'Assets/ثيهف.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const EditProfile(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).MyShipments,
        imagePath: 'Assets/sops.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const MyShipmentsPage(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).favoriteProducts,
        imagePath: 'Assets/solar_heart-outline.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const FavoritesPage(),
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
        label: S.of(context).InviteFriends,
        imagePath: 'Assets/hand.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const InviteFriends(),
      ),
      buildProfileOption(
        context,
        label:  S.of(context).AboutUs,
        imagePath: 'Assets/icons8-about-48.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const AboutUs(),
      ),
      buildProfileOption(
        context,
        label:  S.of(context).PrivacyPolicy,
        imagePath: 'Assets/ic_sharp-security.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const PrivacyPolicy(),
      ),
      buildProfileOption(
        context,
        label:  S.of(context).TermsandConditions,
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
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.012,
            ),
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
                  fit: BoxFit.contain,
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xfffafafa),
      appBar: AppBarWithBottomB(title: S.of(context).more),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal:screenWidth * 0.04),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.03),
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
    );
  }
}

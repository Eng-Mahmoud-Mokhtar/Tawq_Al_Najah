import 'package:flutter/material.dart';
import 'package:tawqalnajah/Core/Widgets/buildLanguage.dart';
import 'package:tawqalnajah/Feature/Buyer/More/presentation/view_model/views/TypeSelection.dart';
import 'package:tawqalnajah/Feature/Buyer/More/presentation/view_model/views/widgets/buildProfileOption.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../Seller/More/presentation/view_model/views/widgets/BankAccount.dart';
import '../../../../MyPosts/presentation/view_model/views/MyPosts.dart';
import '../../../../MyShipment/presentation/view_model/views/MyShipmentsPage.dart';
import '../../../Data/Model/logout_view_model.dart';
import 'AboutUs.dart';
import 'EditProfile.dart';
import 'Favorite.dart';
import 'PrivacyPolicy.dart';
import 'Marketing.dart';
import 'TermsConditions.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final LogoutViewModel _logoutVM = LogoutViewModel();
  bool _isLoggingOut = false;

  void _showLogoutConfirmationDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final s = S.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'Assets/log-out.png',
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                  color: const Color(0xffDD0C0C),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  s.areYouSureLogout,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: screenWidth * 0.12,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _performLogout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffDD0C0C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            s.yes,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: SizedBox(
                        height: screenWidth * 0.12,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFAFAFA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            s.cancel,
                            style: TextStyle(
                              color: KprimaryText,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performLogout() {
    _logoutVM.performLogout(
      context,
      onStateChanged: (isLoading) {
        if (mounted) setState(() => _isLoggingOut = isLoading);
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: GestureDetector(
        onTap: _isLoggingOut ? null : () => _showLogoutConfirmationDialog(context),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.012),
          decoration: BoxDecoration(
            color: _isLoggingOut ? Colors.grey : const Color(0xffDD0C0C),
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoggingOut)
                SizedBox(
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Image.asset(
                  'Assets/log-out.png',
                  color: Colors.white,
                  width: screenWidth * 0.05,
                  fit: BoxFit.contain,
                ),
              SizedBox(width: screenWidth * 0.02),
              Text(
                _isLoggingOut ? S.of(context).loggingOut : S.of(context).logout,
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
    );
  }

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
        page:  EditProfile(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).bankAccount,
        imagePath: 'Assets/credit-card.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const BankAccountPage(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).myAds,
        imagePath: 'Assets/icons8-ads-100.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const MyPosts(),
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
        label: S.of(context).support,
        imagePath: 'Assets/fluent_people-community-32-regular.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const TypeSelection(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).Marketing,
        imagePath: 'Assets/hand.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const Marketing(),
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
      _buildLogoutButton(context),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBarWithBottomB(title: S.of(context).more),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
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

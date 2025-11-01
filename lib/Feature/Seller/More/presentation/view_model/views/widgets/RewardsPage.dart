import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final referralCode = "TQ-78453";
    final int referralUsers = 9;
    final int supports = 5;

    final int totalRewards = referralUsers + supports;
    final bool canRequestReward = totalRewards >= 15;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).Rewards),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenWidth * 0.05),
              Image.asset(
                'Assets/open-package.png',
                width: screenWidth * 0.25,
                height: screenWidth * 0.25,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenWidth * 0.05),
              Text(
                S.of(context).rewards_description,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                  color: KprimaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenWidth * 0.08),

              // كود الدعوة
              _buildReferralCodeBox(referralCode, screenWidth, context),
              SizedBox(height: screenWidth * 0.06),

              // قسم المكافآت المدمج
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow(S.of(context).yourReferralUsers, referralUsers.toString(), screenWidth),
                    SizedBox(height: screenWidth * 0.02),
                    _buildRow(S.of(context).support_count, supports.toString(), screenWidth),
                    SizedBox(height: screenWidth * 0.04),
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.05,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canRequestReward
                              ? KprimaryColor
                              : KprimaryColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: canRequestReward
                            ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                S.of(context).rewardRequestSent,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                              backgroundColor: KprimaryColor,
                            ),
                          );
                        }
                            : null,
                        child: Text(
                          S.of(context).requestReward,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }

  Widget _buildReferralCodeBox(
      String referralCode, double screenWidth, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            referralCode,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: KprimaryText,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.copy_rounded,
              color: const Color(0xffFF580E),
              size: screenWidth * 0.05,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: referralCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.orange.shade50,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  duration: const Duration(seconds: 3),
                  content: Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xffFF580E),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: screenWidth * 0.05,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: Text(
                          S.of(context).codeCopiedSuccess,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, double screenWidth,
      {Color valueColor = Colors.black}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

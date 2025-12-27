import 'package:flutter/material.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final VoidCallback onNextPressed;
  final int currentPage;
  final bool isRtl;

  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.onNextPressed,
    required this.currentPage,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 50),
        Expanded(
          flex: 1,
          child: Center(
            child: Container(
              width: screenWidth * 0.9,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Container(
          height: screenWidth * 0.6,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    int displayIndex = isRtl ? 2 - index : index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01),
                      width: currentPage == displayIndex
                          ? screenWidth * 0.06
                          : screenWidth * 0.02,
                      height: screenWidth * 0.02,
                      decoration: BoxDecoration(
                        color: currentPage == displayIndex
                            ? const Color(0xffFF580E)
                            : const Color(0xfff6cdbb),
                        borderRadius:
                        BorderRadius.circular(screenWidth * 0.04),
                      ),
                    );
                  }),
                ),
                SizedBox(height:screenWidth * 0.03),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: KprimaryText,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: SecoundText,
                    fontSize: screenWidth * 0.03,
                  ),
                ),
                SizedBox(height:screenHeight * 0.05),
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  child: ElevatedButton(
                    onPressed: onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KprimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      currentPage == 2 ? S.of(context).Start : S.of(context).Next,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SecoundColor,
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

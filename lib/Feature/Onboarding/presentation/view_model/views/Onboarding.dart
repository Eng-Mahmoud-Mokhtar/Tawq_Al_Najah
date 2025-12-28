import 'package:flutter/material.dart';
import '../../../../../Core/utiles/Colors.dart';
import '../../../../../generated/l10n.dart';
import '../../../../Auth/presentation/login.dart';
import 'Widgets/OnboardingPage.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _skipToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _skipToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final locale = Localizations.localeOf(context);
    final isRtl = locale.languageCode == 'en';

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: KprimaryColor,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      OnboardingPage(
                        image:
                        'Assets/Online world-bro.png',
                        title: S.of(context).OnBoarding1title,
                        description: S.of(context).OnBoarding1description,
                        onNextPressed: _nextPage,
                        currentPage: _currentPage,
                        isRtl: isRtl,
                      ),
                      OnboardingPage(
                        image:
                        'Assets/Online Groceries-amico.png',
                        title: S.of(context).OnBoarding2title,
                        description: S.of(context).OnBoarding2description,
                        onNextPressed: _nextPage,
                        currentPage: _currentPage,
                        isRtl: isRtl,
                      ),
                      OnboardingPage(
                        image:
                        'Assets/Shopping bag-amico.png',
                        title: S.of(context).OnBoarding3title,
                        description: S.of(context).OnBoarding3description,
                        onNextPressed: _nextPage,
                        currentPage: _currentPage,
                        isRtl: isRtl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage < 2
                      ? TextButton(
                    onPressed: () => _skipToLogin(context),
                    child: Text(
                      S.of(context).Skip,
                      style: TextStyle(
                        color: SecoundColor,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

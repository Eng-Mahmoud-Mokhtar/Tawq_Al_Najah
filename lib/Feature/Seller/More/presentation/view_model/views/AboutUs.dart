import 'package:flutter/material.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../generated/l10n.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: CustomAppBar(title:S.of(context).AboutUs),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Text(
          'نحن فريق متخصص في تطوير تطبيقات التجارة الإلكترونية، نهدف إلى تقديم أفضل الخدمات لعملائنا.',
          style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

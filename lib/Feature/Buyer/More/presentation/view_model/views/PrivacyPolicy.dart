import 'package:flutter/material.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../generated/l10n.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).PrivacyPolicy),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Text(
          'نحن نحترم خصوصيتك ونحمي بياناتك الشخصية. لا نشارك معلوماتك مع أطراف ثالثة دون إذنك.',
          style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black87),
        ),
      ),
    );
  }
}

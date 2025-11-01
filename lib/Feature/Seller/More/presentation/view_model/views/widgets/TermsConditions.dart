import 'package:flutter/material.dart';
import '../../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../../generated/l10n.dart';

class TermsConditions extends StatelessWidget {
  const TermsConditions({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).TermsandConditions),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Text(
          'باستخدام التطبيق، توافق على شروط الخدمة لدينا. يرجى قراءة الشروط بعناية.',
          style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black87),
        ),
      ),
    );
  }
}

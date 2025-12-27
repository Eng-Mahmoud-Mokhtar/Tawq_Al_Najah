import 'package:flutter/material.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/Widgets/Button.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../Core/utiles/Images.dart';
import '../../../../../../generated/l10n.dart';
import 'Packges.dart';
import 'inKindSupport.dart';


class TypeSelection extends StatefulWidget {
  const TypeSelection({super.key});

  @override
  State<TypeSelection> createState() => _TypeSelectionState();
}

class _TypeSelectionState extends State<TypeSelection> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).support),
      body: Directionality(
        textDirection: textDirection,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Center(
                child: Image.asset(
                  KprimaryImage,
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.2,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(
                S.of(context).selectSupportType,
                style: TextStyle(
                  color: KprimaryText,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Button(
                text: S.of(context).packages,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Packages(),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              Button(
                text: S.of(context).inKindSupport,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InKindSupport(),
                    ),
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
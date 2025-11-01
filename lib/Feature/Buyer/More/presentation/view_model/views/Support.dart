import 'package:flutter/material.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/Widgets/Button.dart';
import '../../../../../../Core/Widgets/Country&city.dart';
import '../../../../../../Core/Widgets/Location.dart';
import '../../../../SignUpBuyer/presentation/view_model/views/widgets/Name.dart';
import '../../../../../../Core/Widgets/phoneNumber.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../Core/utiles/Images.dart';
import '../../../../../../generated/l10n.dart';

class Support extends StatelessWidget {
  const Support({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).appSupport),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                KprimaryImage,
                width: screenWidth * 0.5,
                height: screenHeight * 0.15,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: screenHeight * 0.15),
            Text(
              S.of(context).chooseSupportType,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.04),
            Button(
              text: S.of(context).financialSupport,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FinancialSupportForm()),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            Button(
              text: S.of(context).inKindSupport,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InKindSupportForm()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ======================== Financial Support Form ========================
class FinancialSupportForm extends StatelessWidget {
  const FinancialSupportForm({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).financialSupportForm),
      body: Directionality(
        textDirection: textDirection,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        KprimaryImage,
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.15,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    const Name(),
                    SizedBox(height: screenHeight * 0.02),
                    const PhoneNumber(),
                    SizedBox(height: screenHeight * 0.02),
                    const CountryCity(),
                    SizedBox(height: screenHeight * 0.02),
                    const Location(),
                    SizedBox(height: screenHeight * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).charityName,
                          style: TextStyle(
                            color: KprimaryText,
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        SizedBox(
                          height: screenWidth * 0.12,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xffE9E9E9)),
                            ),
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: KprimaryText,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                                hintText: S.of(context).enterCharityName,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.035,
                                  horizontal: screenWidth * 0.035,
                                ),
                              ),
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).donationAmount,
                          style: TextStyle(
                            color: KprimaryText,
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        SizedBox(
                          height: screenWidth * 0.12,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xffE9E9E9)),
                            ),
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: KprimaryText,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                                hintText: S.of(context).enterDonationAmount,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.035,
                                  horizontal: screenWidth * 0.035,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Button(
                      text: S.of(context).submitRequest,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: KprimaryColor,
                            content: Text(
                              S.of(context).requestReviewNotification,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================== In-Kind Support Form ========================
class InKindSupportForm extends StatelessWidget {
  const InKindSupportForm({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).inKindSupportForm),
      body: Directionality(
        textDirection: textDirection,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        KprimaryImage,
                        width: screenWidth * 0.5,
                        height: screenHeight * 0.15,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    const Name(),
                    SizedBox(height: screenHeight * 0.02),
                    const PhoneNumber(),
                    SizedBox(height: screenHeight * 0.02),
                    const CountryCity(),
                    SizedBox(height: screenHeight * 0.02),
                    const Location(),
                    SizedBox(height: screenHeight * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).inKindSupportType,
                          style: TextStyle(
                            color: KprimaryText,
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        SizedBox(
                          height: screenWidth * 0.12,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xffE9E9E9)),
                            ),
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: KprimaryText,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                                hintText: S.of(context).inKindSupportExample,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.035,
                                  horizontal: screenWidth * 0.035,
                                ),
                              ),
                              keyboardType: TextInputType.text,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).descriptionLabel,
                          style: TextStyle(
                            color: KprimaryText,
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        SizedBox(
                          height: screenWidth * 0.24,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xffFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xffE9E9E9)),
                            ),
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: KprimaryText,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                                hintText: S.of(context).inKindDescriptionExample,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: screenWidth * 0.035,
                                  horizontal: screenWidth * 0.035,
                                ),
                              ),
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Button(
                      text: S.of(context).submitRequest,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: KprimaryColor,
                            content: Text(
                              S.of(context).requestSentNotification,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.03),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
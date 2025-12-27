import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Core/Widgets/CountryCubit.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../../../Core/Widgets/CountryState.dart';
import 'country_content.dart';

class PhoneFieldWidget extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;
  final TextEditingController phoneController;
  final String selectedCountryCode;
  final bool isCountryCodeSelected;
  final Function(String) onCountryCodeChanged;
  final Map<String, String> errors;

  const PhoneFieldWidget({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.phoneController,
    required this.selectedCountryCode,
    required this.isCountryCodeSelected,
    required this.onCountryCodeChanged,
    required this.errors,
  });

  void showCountryPicker(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.95,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: CountryContentWidget(
                screenWidth: screenWidth,
                onCountrySelected: (countryCode, countryShort) {
                  onCountryCodeChanged(countryCode);
                },
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountryCubit, CountryState>(
      builder: (context, countryState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).PhoneNumber,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold),
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
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => showCountryPicker(context),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02),
                          child: Row(
                            children: [
                              Text(selectedCountryCode,
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.bold)),
                              Icon(Icons.keyboard_arrow_down,
                                  size: screenWidth * 0.05,
                                  color: Colors.grey.shade500),
                              SizedBox(width: screenWidth * 0.01),
                              Container(
                                height: screenWidth * 0.1,
                                width: 1.0,
                                color: Colors.grey.shade300,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintStyle: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            hintText: '1001234567',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.035),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Show error for country code if not selected
            if (!isCountryCodeSelected && errors.containsKey('code_phone'))
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Please select a country code',
                  style: TextStyle(
                    color: Color(0xffDD0C0C),
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ),
            // Show phone field errors
            if (errors['phone'] != null)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  errors['phone']!,
                  style: TextStyle(
                    color: Color(0xffDD0C0C),
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ),
            if (errors['code_phone'] != null)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  errors['code_phone']!,
                  style: TextStyle(
                    color: Color(0xffDD0C0C),
                    fontSize: screenWidth * 0.03,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
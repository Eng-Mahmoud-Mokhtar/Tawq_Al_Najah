import 'package:flutter/material.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../domain/cubits/login_cubit.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final LoginState state;
  final double screenWidth;
  final double screenHeight;

  const EmailField({
    super.key,
    required this.controller,
    required this.state,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).email,
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
            child: TextField(
              controller: controller,
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
                hintText: S.of(context).email,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenWidth * 0.035,
                  horizontal: screenWidth * 0.035,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
        if (state.errors['email'] != null)
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              state.errors['email']!,
              style: TextStyle(
                color: Color(0xffDD0C0C),
                fontSize: screenWidth * 0.03,
              ),
            ),
          ),
      ],
    );
  }
}
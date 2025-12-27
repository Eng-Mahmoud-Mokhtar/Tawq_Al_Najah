import 'package:flutter/material.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../domain/cubits/login_cubit.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final LoginState state;
  final double screenWidth;
  final double screenHeight;

  const PasswordField({
    super.key,
    required this.controller,
    required this.state,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).password,
          style: TextStyle(
            color: KprimaryText,
            fontSize: widget.screenWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: widget.screenHeight * 0.01),
        SizedBox(
          height: widget.screenWidth * 0.12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffE9E9E9)),
            ),
            child: TextField(
              controller: widget.controller,
              obscureText: _obscurePassword,
              style: TextStyle(
                fontSize: widget.screenWidth * 0.03,
                color: KprimaryText,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  fontSize: widget.screenWidth * 0.03,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
                hintText: S.of(context).password,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.screenWidth * 0.035,
                  horizontal: widget.screenWidth * 0.035,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                    size: widget.screenWidth * 0.05,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        if (widget.state.errors['password'] != null)
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              widget.state.errors['password']!,
              style: TextStyle(
                color: Color(0xffDD0C0C),
                fontSize: widget.screenWidth * 0.03,
              ),
            ),
          ),
      ],
    );
  }
}
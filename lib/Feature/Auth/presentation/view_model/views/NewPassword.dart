import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../../Core/Widgets/Button.dart';
import '../../../../../Core/utiles/Colors.dart';
import '../../../../../Core/utiles/Images.dart';
import '../../../../../generated/l10n.dart';
import '../../../domain/cubits/new_password_cubit.dart';


class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const NewPasswordScreen({
    Key? key,
    required this.email,
    required this.otp,
  }) : super(key: key);

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => NewPasswordCubit(
        dio: Dio(),
        email: widget.email,
        otp: widget.otp,
      ),
      child: Scaffold(
        backgroundColor: SecoundColor,
        body: BlocConsumer<NewPasswordCubit, NewPasswordState>(
          listener: (context, state) {},
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.08),
                            Center(
                              child: Image.asset(
                                KprimaryImage,
                                width: screenWidth * 0.5,
                                height: screenHeight * 0.15,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.05),
                            Text(
                              S.of(context).setNewPassword,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            _buildPasswordField(
                              context,
                              controller: _newPasswordController,
                              label: S.of(context).newPassword,
                              obscureText: state.obscureNewPassword,
                              hasError: state.hasError,
                              onToggleVisibility: () {
                                context.read<NewPasswordCubit>().toggleNewPasswordVisibility();
                              },
                              onChanged: (value) {
                                if (state.hasError) {
                                  context.read<NewPasswordCubit>().clearError(context);
                                }
                              },
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            _buildPasswordField(
                              context,
                              controller: _confirmPasswordController,
                              label: S.of(context).confirmPassword,
                              obscureText: state.obscureConfirmPassword,
                              hasError: state.hasError,
                              onToggleVisibility: () {
                                context.read<NewPasswordCubit>().toggleConfirmPasswordVisibility();
                              },
                              onChanged: (value) {
                                if (state.hasError) {
                                  context.read<NewPasswordCubit>().clearError(context);
                                }
                              },
                            ),
                            if (state.error != null)
                              Padding(
                                padding: EdgeInsets.only(top: 16.0),
                                child: Text(
                                  state.error!,
                                  style: TextStyle(
                                    color: Color(0xffDD0C0C),
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            SizedBox(height: screenHeight * 0.04),
                            Button(
                              text: _getButtonText(state.buttonText, context),
                              onPressed: state.isLoading
                                  ? () {}
                                  : () {
                                context.read<NewPasswordCubit>().resetPassword(
                                  newPassword: _newPasswordController.text,
                                  confirmPassword:
                                  _confirmPasswordController.text,
                                  context: context,
                                );
                              },
                            ),
                            SizedBox(height: screenHeight * 0.03),
                          ],
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.01,
                        child: SafeArea(
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: KprimaryText,
                              size: screenHeight * 0.03,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required bool obscureText,
        required bool hasError,
        required VoidCallback onToggleVisibility,
        required ValueChanged<String> onChanged,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: KprimaryText,
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xffFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasError ? Color(0xffDD0C0C): const Color(0xffE9E9E9),
              width: hasError ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: KprimaryText,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: screenWidth * 0.035,
                horizontal: screenWidth * 0.035,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey.shade600,
                  size: screenWidth * 0.05,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getButtonText(String buttonText, BuildContext context) {
    switch (buttonText) {
      case 'Resetting...':
        return S.of(context).resetting;
      case 'Success':
        return S.of(context).resetSuccess;
      case 'Failed':
        return S.of(context).resetFailed;
      default:
        return S.of(context).resetPassword;
    }
  }
}
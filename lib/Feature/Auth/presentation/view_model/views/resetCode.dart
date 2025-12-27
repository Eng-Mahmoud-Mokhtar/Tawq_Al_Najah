import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:tawqalnajah/Feature/Auth/presentation/view_model/views/widgets/code_widget.dart';
import '../../../../../Core/Widgets/Button.dart';
import '../../../../../Core/utiles/Colors.dart';
import '../../../../../Core/utiles/Images.dart';
import '../../../../../generated/l10n.dart';
import '../../../domain/cubits/verify_code_cubit.dart';


class ResetCode extends StatefulWidget {
  final String email;
  const ResetCode({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetCode> createState() => _ResetCodeState();
}

class _ResetCodeState extends State<ResetCode> {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => VerifyCodeCubit(dio: Dio(), email: widget.email),
      child: Scaffold(
        backgroundColor: SecoundColor,
        body: BlocConsumer<VerifyCodeCubit, VerifyCodeState>(
          listener: (context, state) {},
          builder: (context, state) {
            return SingleChildScrollView(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.12),
                        Image.asset(
                          KprimaryImage,
                          width: screenWidth * 0.5,
                          height: screenHeight * 0.15,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Text(
                          '${S.of(context).codeSentTo}\n${widget.email}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: SecoundText,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        CodeWidget(
                          hasError: state.hasError,
                          onCodeChanged: (code) {
                            _codeController.text = code;
                            if (state.hasError) {
                              context.read<VerifyCodeCubit>().clearError();
                            }
                            if (code.length == 4) {
                              context.read<VerifyCodeCubit>().verifyCode(code, context);
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        Button(
                          text: _getButtonText(state.buttonText, context),
                          onPressed: state.isLoading
                              ? () {}
                              : () {
                            if (_codeController.text.length == 4) {
                              context
                                  .read<VerifyCodeCubit>()
                                  .verifyCode(_codeController.text, context);
                            } else {
                              context.read<VerifyCodeCubit>().emit(
                                state.copyWith(
                                  error: S.of(context).codeMustBe4Digits,
                                  hasError: true,
                                  buttonText: S.of(context).verify,
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextButton(
                          onPressed: state.canResend && !state.isLoading
                              ? () {
                            context.read<VerifyCodeCubit>().resendCode(context);
                          }
                              : () {},
                          style: TextButton.styleFrom(
                            foregroundColor: state.canResend && !state.isLoading
                                ? KprimaryColor
                                : KprimaryColor.withOpacity(0.4),
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.03,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          child: Text(
                            state.canResend
                                ? S.of(context).ResendCode
                                : '${S.of(context).ResendCode} (${context.read<VerifyCodeCubit>().formattedCountdown})',
                          ),
                        ),
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
            );
          },
        ),
      ),
    );
  }

  String _getButtonText(String buttonText, BuildContext context) {
    switch (buttonText) {
      case 'Verifying...':
        return S.of(context).verifying;
      case 'Success':
        return S.of(context).verificationSuccess;
      case 'Failed':
        return S.of(context).verificationFailed;
      case 'Sending...':
        return S.of(context).sending;
      default:
        return S.of(context).verify;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:tawqalnajah/Feature/Auth/presentation/view_model/views/resetCode.dart';
import '../../../../../Core/Widgets/Button.dart';
import '../../../../../Core/utiles/Colors.dart';
import '../../../../../Core/utiles/Images.dart';
import '../../../../../generated/l10n.dart';
import '../../../domain/cubits/forgot_password_cubit.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(dio: Dio()),
      child: Scaffold(
        backgroundColor: SecoundColor,
        body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            if (state.isSuccess && state.email != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResetCode(email: state.email!),
                ),
              );
            }
          },
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
                            SizedBox(height: screenHeight * 0.18),
                            Column(
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
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFAFAFA),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: state.error != null
                                          ? Color(0xffDD0C0C)
                                          : const Color(0xffE9E9E9),
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _emailController,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: KprimaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: S.of(context).email,
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
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (value) {
                                      if (state.error != null) {
                                        context.read<ForgotPasswordCubit>().clearError();
                                      }
                                    },
                                  ),
                                ),
                                if (state.error != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      state.error!,
                                      style: TextStyle(
                                        color: Color(0xffDD0C0C),
                                        fontSize: screenWidth * 0.03,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                SizedBox(height: screenHeight * 0.04),
                              ],
                            ),
                            Button(
                              text: state.isLoading
                                  ? S.of(context).Sending
                                  : S.of(context).resetCode,
                              onPressed: state.isLoading
                                  ? () {}
                                  : () {
                                context
                                    .read<ForgotPasswordCubit>()
                                    .sendResetCode(
                                  _emailController.text.trim(),
                                  context,
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
}
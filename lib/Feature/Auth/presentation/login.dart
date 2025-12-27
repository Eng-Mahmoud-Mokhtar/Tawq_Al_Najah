import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tawqalnajah/Feature/Auth/presentation/view_model/views/widgets/PasswordField.dart';
import 'package:tawqalnajah/Feature/Auth/presentation/view_model/views/widgets/dontHaveAccountRow.dart';
import 'package:tawqalnajah/Feature/Auth/presentation/view_model/views/widgets/email_field.dart';
import '../../../Core/utiles/Colors.dart';
import '../../../Core/utiles/Images.dart';
import '../../../generated/l10n.dart';
import '../domain/cubits/login_cubit.dart';
import 'view_model/views/ResetPassword.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) => LoginCubit(dio: Dio(), context: context),
      child: Scaffold(
        backgroundColor: SecoundColor,
        body: BlocConsumer<LoginCubit, LoginState>(
          listener: (context, state) {},
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.1),
                        Center(
                          child: Image.asset(
                            KprimaryImage,
                            width: screenWidth * 0.5,
                            height: screenHeight * 0.15,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.1),
                        EmailField(
                          controller: _emailController,
                          state: state,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        PasswordField(
                          controller: _passwordController,
                          state: state,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),

                        // General Errors
                        if (state.errors['general'] != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              state.errors['general']!,
                              style: TextStyle(
                                color: Color(0xffDD0C0C),
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                          ),
                        if (state.errors['network'] != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              state.errors['network']!,
                              style: TextStyle(
                                color: Color(0xffDD0C0C),
                                fontSize: screenWidth * 0.03,
                              ),
                            ),
                          ),

                        SizedBox(height: screenHeight * 0.01),
                        Align(
                          alignment: Directionality.of(context) == TextDirection.rtl
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ResetPassword()),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              S.of(context).forgotPassword,
                              style: TextStyle(
                                color: KprimaryColor,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: screenWidth * 0.12,
                          child: ElevatedButton(
                            onPressed: state.isLoading
                                ? null
                                : () {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text;
                              context.read<LoginCubit>().loginUser(email, password);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.isLoading ? Colors.grey[400] : KprimaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: state.isLoading
                                ? SizedBox(
                              width: screenWidth * 0.05,
                              height: screenWidth * 0.05,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : Text(
                              S.of(context).login,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        const CreateAccount(),
                      ],
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
}
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tawqalnajah/Feature/Buyer/SignUpBuyer/presentation/view_model/views/widgets/phone_field.dart';

import '../../../../../../Core/Widgets/alreadyHaveAccount.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../Core/utiles/Images.dart';
import '../../../../../../generated/l10n.dart';
import '../buyer_register_cubit.dart';


class SignUpBuyer extends StatefulWidget {
  const SignUpBuyer({Key? key}) : super(key: key);

  @override
  State<SignUpBuyer> createState() => _SignUpBuyerState();
}

class _SignUpBuyerState extends State<SignUpBuyer> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _referralCodeController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedCountryCode = '+20';
  bool _isCountryCodeSelected = true;

  @override
  void initState() {
    super.initState();
    _selectedCountryCode = '+20';
    _isCountryCodeSelected = true;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) => BuyerRegisterCubit(dio: Dio(), context: context),
      child: Scaffold(
        backgroundColor: SecoundColor,
        body: BlocConsumer<BuyerRegisterCubit, BuyerRegisterState>(
          listener: (context, state) {
            if (state.serverError != null && !state.isLoading) {
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Padding(
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
                            SizedBox(height: screenHeight * 0.05),

                            // Name Field
                            Text(
                              S.of(context).FullName,
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
                                  controller: _nameController,
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
                                    hintText: S.of(context).FullName,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: screenWidth * 0.035,
                                      horizontal: screenWidth * 0.035,
                                    ),
                                  ),
                                  keyboardType: TextInputType.name,
                                ),
                              ),
                            ),
                            if (state.errors['name'] != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  state.errors['name']!,
                                  style: TextStyle(
                                    color: Color(0xffDD0C0C),
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                              ),
                            SizedBox(height: screenHeight * 0.02),
                            PhoneFieldWidget(
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              phoneController: _phoneController,
                              selectedCountryCode: _selectedCountryCode,
                              isCountryCodeSelected: _isCountryCodeSelected,
                              onCountryCodeChanged: (code) {
                                setState(() {
                                  _selectedCountryCode = code;
                                  _isCountryCodeSelected = true;
                                });
                              },
                              errors: state.errors,
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // Email Field
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
                              height: screenWidth * 0.12,
                              decoration: BoxDecoration(
                                color: const Color(0xffFAFAFA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xffE9E9E9)),
                              ),
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
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
                            SizedBox(height: screenHeight * 0.02),

                            // Password Field
                            Text(
                              S.of(context).password,
                              style: TextStyle(
                                color: KprimaryText,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Container(
                              height: screenWidth * 0.12,
                              decoration: BoxDecoration(
                                color: const Color(0xffFAFAFA),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xffE9E9E9)),
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.03,
                                  color: KprimaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: S.of(context).password,
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
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey.shade600,
                                      size: screenWidth * 0.05,
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
                            if (state.errors['password'] != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  state.errors['password']!,
                                  style: TextStyle(
                                    color: Color(0xffDD0C0C),
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                              ),
                            SizedBox(height: screenHeight * 0.02),

                            // Referral Code Field
                            Text(
                              S.of(context).ReferralCode,
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
                                  controller: _referralCodeController,
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
                                    hintText: "#######",
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
                            SizedBox(height: screenHeight * 0.02),

                            // Country & City Fields
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        S.of(context).Country,
                                        style: TextStyle(
                                          color: Colors.black,
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
                                            controller: _countryController,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.03,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: InputDecoration(
                                              hintStyle: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade600,
                                              ),
                                              hintText: S.of(context).Country,
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(
                                                vertical: screenWidth * 0.035,
                                                horizontal: screenWidth * 0.035,
                                              ),
                                            ),
                                            keyboardType: TextInputType.name,
                                          ),
                                        ),
                                      ),
                                      if (state.errors['country'] != null)
                                        Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            state.errors['country']!,
                                            style: TextStyle(
                                              color: Color(0xffDD0C0C),
                                              fontSize: screenWidth * 0.03,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        S.of(context).City,
                                        style: TextStyle(
                                          color: Colors.black,
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
                                            controller: _cityController,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.03,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: InputDecoration(
                                              hintStyle: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade600,
                                              ),
                                              hintText: S.of(context).City,
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(
                                                vertical: screenWidth * 0.035,
                                                horizontal: screenWidth * 0.035,
                                              ),
                                            ),
                                            keyboardType: TextInputType.name,
                                          ),
                                        ),
                                      ),
                                      if (state.errors['governorate'] != null)
                                        Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            state.errors['governorate']!,
                                            style: TextStyle(
                                              color:Color(0xffDD0C0C),
                                              fontSize: screenWidth * 0.03,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),

                            // Address Field
                            Text(
                              S.of(context).location,
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
                                  controller: _addressController,
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
                                    hintText: S.of(context).location,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: screenWidth * 0.035,
                                      horizontal: screenWidth * 0.035,
                                    ),
                                  ),
                                  keyboardType: TextInputType.name,
                                ),
                              ),
                            ),
                            if (state.errors['address'] != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  state.errors['address']!,
                                  style: TextStyle(
                                    color: Color(0xffDD0C0C),
                                    fontSize: screenWidth * 0.03,
                                  ),
                                ),
                              ),
                            SizedBox(height: screenHeight * 0.02),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: screenWidth * 0.12,
                              child: ElevatedButton(
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                  final formData = {
                                    'name': _nameController.text.trim(),
                                    'email': _emailController.text.trim(),
                                    'password': _passwordController.text,
                                    'code_phone': _selectedCountryCode,
                                    'phone': _phoneController.text.trim(),
                                    'country': _countryController.text.trim(),
                                    'governorate': _cityController.text.trim(),
                                    'address': _addressController.text.trim(),
                                    'referral_code': _referralCodeController.text.trim(),
                                    'type': 'customer',
                                  };
                                  context.read<BuyerRegisterCubit>().registerBuyer(formData);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: state.isLoading
                                      ? Colors.grey[400]
                                      : KprimaryColor,
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
                                  S.of(context).SignUp,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            const AlreadyHaveAccount(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Back Button
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
            );
          },
        ),
      ),
    );
  }
}
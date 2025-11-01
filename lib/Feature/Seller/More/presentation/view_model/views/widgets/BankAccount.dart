import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tawqalnajah/Core/Widgets/AppBar.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../Core/Widgets/Button.dart';
import '../../../../../../../generated/l10n.dart';

class BankAccountPage extends StatefulWidget {
  const BankAccountPage({super.key});

  @override
  State<BankAccountPage> createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _proofImage;
  bool _isSubmitted = false;

  Future<void> _pickProofImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _proofImage = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final s = S.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: s.bankAccount),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: h * 0.02),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                title: s.bankName,
                hint: s.enterBankName,
                controller: _bankNameController,
                w: w,
                h: h,
              ),
              SizedBox(height: h * 0.02),
              _buildField(
                title: s.ibanNumber,
                hint: "SA123456789",
                controller: _ibanController,
                w: w,
                h: h,
              ),
              SizedBox(height: h * 0.02),
              _buildField(
                title: s.accountHolderName,
                hint: s.enterFullBankName,
                controller: _accountNameController,
                w: w,
                h: h,
              ),
              SizedBox(height: h * 0.02),
              _buildField(
                title: s.linkedPhoneNumber,
                hint: s.enterRegisteredPhone,
                controller: _phoneController,
                w: w,
                h: h,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: h * 0.03),
              Text(
                s.proofOfOwnership,
                style: TextStyle(
                  color: KprimaryText,
                  fontSize: w * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h * 0.01),
              InkWell(
                onTap: _pickProofImage,
                child: Container(
                  height: w * 0.3,
                  width: w,
                  decoration: BoxDecoration(
                    color: const Color(0xffFAFAFA),
                    borderRadius: BorderRadius.circular(w * 0.02),
                    border: Border.all(color: const Color(0xffE9E9E9), width: w * 0.002),
                  ),
                  child: _proofImage == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: w * 0.05, color: Colors.grey.shade600),
                      SizedBox(height: h * 0.01),
                      Text(
                        s.tapToUpload,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: w * 0.03,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(w * 0.02),
                    child: Image.file(
                      _proofImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
              SizedBox(height: h * 0.02),

              _isSubmitted
                  ? Container(
                width: double.infinity,
                height: w * 0.12,
                decoration: BoxDecoration(
                  color: const Color(0xffFF580E),
                  borderRadius: BorderRadius.circular(w * 0.02),
                ),
                child: Center(
                  child: Text(
                    s.underReview,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.035,
                    ),
                  ),
                ),
              )
                  : Button(
                text: s.submitForReview,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() => _isSubmitted = true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          s.bankSubmittedSuccessfully,
                          style: TextStyle(fontSize: w * 0.03),
                        ),
                        backgroundColor: KprimaryColor,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required double w,
    required double h,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: KprimaryText,
            fontSize: w * 0.035,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: h * 0.01),
        Container(
          height: w * 0.12,
          decoration: BoxDecoration(
            color: const Color(0xffFAFAFA),
            borderRadius: BorderRadius.circular(w * 0.02),
            border: Border.all(color: const Color(0xffE9E9E9), width: w * 0.002),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: title.contains("رقم") || title.contains("IBAN"),
            style: TextStyle(
              fontSize: w * 0.035,
              color: KprimaryText,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: w * 0.03,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: w * 0.03,
                horizontal: w * 0.035,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return null;
              return null;
            },
            onChanged: (value) => setState(() {}),
          ),
        ),
        if (controller.text.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: h * 0.005),
            child: Text(
              s.fieldRequired,
              style: TextStyle(
                color: const Color(0xffDD0C0C),
                fontSize: w * 0.03,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

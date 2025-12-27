import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tawqalnajah/Core/Widgets/AppBar.dart';

import '../../../../../../../Core/Widgets/Button.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';

enum BeneficiaryType { individual, company }

class CountryOption {
  final String code;
  final String nameAr;
  final bool usesIban;
  final bool isSaudi;

  const CountryOption({
    required this.code,
    required this.nameAr,
    required this.usesIban,
    required this.isSaudi,
  });
}

class BankAccountPage extends StatefulWidget {
  const BankAccountPage({super.key});

  @override
  State<BankAccountPage> createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _accountIdController = TextEditingController(); // IBAN or Account Number
  final TextEditingController _swiftController = TextEditingController();

  File? _proofImage;

  bool _isSubmitted = false;
  bool _autoValidate = false;

  BeneficiaryType _beneficiaryType = BeneficiaryType.individual;

  final List<CountryOption> _countries = const [
    CountryOption(code: "SA", nameAr: "السعودية", usesIban: true, isSaudi: true),
    CountryOption(code: "AE", nameAr: "الإمارات", usesIban: true, isSaudi: false),
    CountryOption(code: "EG", nameAr: "مصر", usesIban: true, isSaudi: false),
    CountryOption(code: "JO", nameAr: "الأردن", usesIban: true, isSaudi: false),
    CountryOption(code: "KW", nameAr: "الكويت", usesIban: true, isSaudi: false),
    CountryOption(code: "QA", nameAr: "قطر", usesIban: true, isSaudi: false),
    CountryOption(code: "BH", nameAr: "البحرين", usesIban: true, isSaudi: false),
    CountryOption(code: "OM", nameAr: "عُمان", usesIban: true, isSaudi: false),
    CountryOption(code: "MA", nameAr: "المغرب", usesIban: true, isSaudi: false),
    CountryOption(code: "TN", nameAr: "تونس", usesIban: true, isSaudi: false),
    CountryOption(code: "DZ", nameAr: "الجزائر", usesIban: false, isSaudi: false),
    CountryOption(code: "IQ", nameAr: "العراق", usesIban: false, isSaudi: false),
  ];

  late CountryOption _selectedCountry;

  bool _internationalTransfer = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.first; // default: Saudi
    _internationalTransfer = !_selectedCountry.isSaudi;

    _bankNameController.addListener(_rebuild);
    _accountNameController.addListener(_rebuild);
    _phoneController.addListener(_rebuild);
    _accountIdController.addListener(_rebuild);
    _swiftController.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _bankNameController.removeListener(_rebuild);
    _accountNameController.removeListener(_rebuild);
    _phoneController.removeListener(_rebuild);
    _accountIdController.removeListener(_rebuild);
    _swiftController.removeListener(_rebuild);

    _bankNameController.dispose();
    _accountNameController.dispose();
    _phoneController.dispose();
    _accountIdController.dispose();
    _swiftController.dispose();
    super.dispose();
  }

  Future<void> _pickProofImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _proofImage = File(pickedFile.path));
    }
  }

  String _normalizeIban(String input) =>
      input.replaceAll(' ', '').replaceAll('-', '').trim().toUpperCase();

  bool _looksLikeSwift(String input) {
    final swift = input.trim().toUpperCase();
    final reg = RegExp(r'^[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?$');
    return reg.hasMatch(swift);
  }

  bool _looksLikeSaudiPhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 && digits.startsWith('05')) return true;
    if (digits.length == 9 && digits.startsWith('5')) return true;
    return false;
  }

  String _accountIdTitle(S s) {
    if (_selectedCountry.usesIban) return s.ibanNumber;
    return "رقم الحساب البنكي";
  }

  String _accountIdHint() {
    if (_selectedCountry.isSaudi) return "SA1234 5678 9012 3456 7890 12";
    if (_selectedCountry.usesIban) return "IBAN";
    return "مثال: 1234567890";
  }

  bool _shouldShowSwift() {
    if (!_selectedCountry.isSaudi) return true;
    return _internationalTransfer;
  }

  void _onSubmit(S s, double w) {
    setState(() => _autoValidate = true);

    final valid = _formKey.currentState?.validate() ?? false;
    final hasProof = _proofImage != null;

    if (!hasProof) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "من فضلك ارفع إثبات ملكية الحساب.",
            style: TextStyle(fontSize: w * 0.03),
          ),
          backgroundColor: const Color(0xffDD0C0C),
        ),
      );
      return;
    }

    if (!valid) return;

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
          autovalidateMode: _autoValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الدولة
              _buildDropdownField(
                title: "الدولة",
                w: w,
                h: h,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.white, // خلفية قائمة الخيارات
                  ),
                  child: DropdownButtonFormField<CountryOption>(
                    value: _selectedCountry,
                    dropdownColor: Colors.white, // خلفية الدروب داون نفسها
                    decoration: _inputDecoration(hint: "اختر الدولة", w: w),
                    items: _countries
                        .map(
                          (c) => DropdownMenuItem(
                        value: c,
                        child: Text(
                          c.nameAr,
                          style: TextStyle(
                            fontSize: w * 0.035,
                            color: KprimaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCountry = value;
                        _internationalTransfer = !_selectedCountry.isSaudi;
                        _accountIdController.clear();
                        _swiftController.clear();
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: h * 0.02),

              // نوع المستفيد
              _buildDropdownField(
                title: "نوع المستفيد",
                w: w,
                h: h,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.white,
                  ),
                  child: DropdownButtonFormField<BeneficiaryType>(
                    value: _beneficiaryType,
                    dropdownColor: Colors.white,
                    decoration: _inputDecoration(hint: "اختر النوع", w: w),
                    items: const [
                      DropdownMenuItem(value: BeneficiaryType.individual, child: Text("فرد")),
                      DropdownMenuItem(value: BeneficiaryType.company, child: Text("شركة")),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _beneficiaryType = value);
                    },
                  ),
                ),
              ),
              SizedBox(height: h * 0.02),

              _buildField(
                title: s.bankName,
                hint: s.enterBankName,
                controller: _bankNameController,
                w: w,
                h: h,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "اسم البنك مطلوب";
                  if (value.trim().length < 2) return "اسم البنك غير صحيح";
                  return null;
                },
              ),
              SizedBox(height: h * 0.02),

              _buildField(
                title: s.accountHolderName,
                hint: s.enterFullBankName,
                controller: _accountNameController,
                w: w,
                h: h,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "اسم صاحب الحساب مطلوب";
                  final v = value.trim();
                  if (v.length < 6) return "اكتب الاسم بالكامل";
                  return null;
                },
              ),
              SizedBox(height: h * 0.02),

              // التحويل الدولي (لو السعودية)
              if (_selectedCountry.isSaudi) ...[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "تحويل دولي (يتطلب SWIFT)",
                    style: TextStyle(
                      color: KprimaryText,
                      fontSize: w * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: _internationalTransfer,
                  onChanged: (v) => setState(() {
                    _internationalTransfer = v;
                    _swiftController.clear();
                  }),
                ),
                SizedBox(height: h * 0.01),
              ],

              _buildField(
                title: _accountIdTitle(s),
                hint: _accountIdHint(),
                controller: _accountIdController,
                w: w,
                h: h,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return _selectedCountry.usesIban ? "رقم الآيبان مطلوب" : "رقم الحساب مطلوب";
                  }

                  if (_selectedCountry.usesIban) {
                    final iban = _normalizeIban(value);
                    if (iban.length < 15 || iban.length > 34) return "IBAN غير صحيح";
                    if (_selectedCountry.isSaudi) {
                      if (!iban.startsWith('SA') || iban.length != 24) return "IBAN سعودي غير صحيح";
                    } else {
                      if (!RegExp(r'^[A-Z]{2}[0-9A-Z]+$').hasMatch(iban)) return "IBAN غير صحيح";
                    }
                  } else {
                    final digits = value.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 8) return "رقم الحساب قصير";
                  }
                  return null;
                },
              ),
              SizedBox(height: h * 0.02),

              if (_shouldShowSwift()) ...[
                _buildField(
                  title: "SWIFT / BIC",
                  hint: "مثل: NCBKSAJE",
                  controller: _swiftController,
                  w: w,
                  h: h,
                  validator: (value) {
                    if (!_shouldShowSwift()) return null;
                    if (value == null || value.trim().isEmpty) return "SWIFT مطلوب للتحويل الدولي";
                    if (!_looksLikeSwift(value)) return "SWIFT غير صحيح";
                    return null;
                  },
                ),
                SizedBox(height: h * 0.02),
              ],

              _buildField(
                title: s.linkedPhoneNumber,
                hint: s.enterRegisteredPhone,
                controller: _phoneController,
                w: w,
                h: h,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "رقم الجوال مطلوب";
                  final digits = value.replaceAll(RegExp(r'\D'), '');

                  if (_selectedCountry.isSaudi) {
                    if (!_looksLikeSaudiPhone(value)) return "رقم جوال سعودي غير صحيح";
                  } else {
                    if (digits.length < 8 || digits.length > 15) return "رقم الجوال غير صحيح";
                  }
                  return null;
                },
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
                      Icon(Icons.cloud_upload_outlined, size: w * 0.05, color: Colors.grey.shade600),
                      SizedBox(height: h * 0.01),
                      Text(
                        "اضغط لرفع صورة إثبات ملكية الحساب (إجباري)",
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
                onPressed: () => _onSubmit(s, w),
              ),

              SizedBox(height: h * 0.02),
              Text(
                "ملاحظة: سيتم تفعيل السحب/المدفوعات بعد ربط بوابة الدفع. حاليًا يتم جمع البيانات للمراجعة فقط.",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: w * 0.03,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required double w}) {
    return InputDecoration(
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
    );
  }

  Widget _buildDropdownField({
    required String title,
    required Widget child,
    required double w,
    required double h,
  }) {
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
            color: Colors.white, // ✅ خلفية الدروب داون بيضاء
            borderRadius: BorderRadius.circular(w * 0.02),
            border: Border.all(color: const Color(0xffE9E9E9), width: w * 0.002),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ],
    );
  }

  Widget _buildField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required double w,
    required double h,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
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
            obscureText: false,
            style: TextStyle(
              fontSize: w * 0.035,
              color: KprimaryText,
              fontWeight: FontWeight.bold,
            ),
            decoration: _inputDecoration(hint: hint, w: w),
            validator: validator,
          ),
        ),
      ],
    );
  }
}
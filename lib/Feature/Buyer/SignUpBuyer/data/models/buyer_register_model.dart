import 'package:equatable/equatable.dart';

class BuyerRegisterModel extends Equatable {
  final String name;
  final String email;
  final String password;
  final String codePhone;
  final String phone;
  final String country;
  final String governorate;
  final String address;
  final String type;
  final String? referralCode;

  const BuyerRegisterModel({
    required this.name,
    required this.email,
    required this.password,
    required this.codePhone,
    required this.phone,
    required this.country,
    required this.governorate,
    required this.address,
    required this.type,
    this.referralCode,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'username': name.trim(),
      'email': email,
      'password': password,
      'password_confirmation': password,
      'code_phone': codePhone,
      'phone': phone,
      'country': country,
      'city': governorate,
      'location': address,
      'type': type,
    };

    if (referralCode?.isNotEmpty == true) {
      data['referral_code'] = referralCode;
    }

    return data;
  }

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    codePhone,
    phone,
    country,
    governorate,
    address,
    type,
    referralCode,
  ];
}
import 'package:equatable/equatable.dart';

class BuyerRegisterEntity extends Equatable {
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

  const BuyerRegisterEntity({
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
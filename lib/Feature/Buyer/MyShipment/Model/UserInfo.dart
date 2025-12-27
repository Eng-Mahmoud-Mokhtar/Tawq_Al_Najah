class UserInfo {
  final String name;
  final String email;
  final String country;
  final String phone;
  final String? image;

  UserInfo({
    required this.name,
    required this.email,
    required this.country,
    required this.phone,
    required this.image,
  });

  factory UserInfo.fromJson(Map<String, dynamic>? json) {
    final j = json ?? const <String, dynamic>{};
    return UserInfo(
      name: (j['name'] ?? '').toString(),
      email: (j['email'] ?? '').toString(),
      country: (j['country'] ?? '').toString(),
      phone: (j['phone'] ?? '').toString(),
      image: j['image']?.toString(),
    );
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tawqalnajah/Core/Widgets/buildLanguage.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';
import 'package:tawqalnajah/Feature/Seller/More/presentation/view_model/views/widgets/AccountInfoSeller.dart';
import 'package:tawqalnajah/Feature/Seller/More/presentation/view_model/views/widgets/BankAccount.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/widgets/ShimmerContainer.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/widgets/ImageHome.dart';

import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../Buyer/More/Data/Model/logout_view_model.dart';
import '../../../../../Buyer/More/presentation/view_model/views/AboutUs.dart';
import '../../../../../Buyer/More/presentation/view_model/views/EditProfile.dart';
import '../../../../../Buyer/More/presentation/view_model/views/Marketing.dart';
import '../../../../../Buyer/More/presentation/view_model/views/PrivacyPolicy.dart';
import '../../../../../Buyer/More/presentation/view_model/views/TypeSelection.dart';
import '../../../../../Buyer/More/presentation/view_model/views/TermsConditions.dart';
import '../../../../../Buyer/More/presentation/view_model/views/widgets/buildProfileOption.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});
  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  File? _profileImage;

  final LogoutViewModel _logoutVM = LogoutViewModel();
  bool _isLoggingOut = false;

  bool _isProfileLoading = true;
  String _userName = '';
  String _userImageUrl = ImageHome.getValidImageUrl(null);

  final _dio = Dio();
  final _storage = const FlutterSecureStorage();
  static const String _profileUrl =
      'https://toknagah.viking-iceland.online/api/user/show-profile';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isProfileLoading = true);
    try {
      final token = await _storage.read(key: 'user_token');

      if (token == null) {
        setState(() {
          _isProfileLoading = false;
          _userName = 'Name';
          _userImageUrl = ImageHome.getValidImageUrl(null);
        });
        return;
      }

      final response = await _dio.get(
        _profileUrl,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> root = _toMap(response.data);
        final Map<String, dynamic> userData = _extractUserData(root);

        final name = _extractName(userData);
        final imageUrl = _extractImage(userData);

        setState(() {
          _userName = name;
          _userImageUrl = imageUrl;
          _isProfileLoading = false;
        });
      } else {
        setState(() {
          _isProfileLoading = false;
          _userName = 'Name';
          _userImageUrl = ImageHome.getValidImageUrl(null);
        });
      }
    } catch (e) {
      setState(() {
        _isProfileLoading = false;
        _userName = 'Name';
        _userImageUrl = ImageHome.getValidImageUrl(null);
      });
    }
  }

  Map<String, dynamic> _toMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return {};
  }

  Map<String, dynamic> _extractUserData(Map<String, dynamic> root) {
    final candidates = <Map<String, dynamic>>[];

    void addIfMap(dynamic v) {
      if (v is Map<String, dynamic>) candidates.add(v);
    }

    addIfMap(root['user']);
    if (root['data'] is Map<String, dynamic>) {
      final data = root['data'] as Map<String, dynamic>;
      addIfMap(data['user']);
      addIfMap(data);
      if (data['data'] is Map<String, dynamic>) {
        final inner = data['data'] as Map<String, dynamic>;
        addIfMap(inner['user']);
        addIfMap(inner);
      }
    }

    for (final m in candidates) {
      if (_hasAnyKey(m, const [
        'name',
        'username',
        'full_name',
        'user_name',
        'image',
        'profile_image',
        'avatar',
        'photo'
      ])) {
        return m;
      }
    }
    return root;
  }

  bool _hasAnyKey(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      if (map.containsKey(k)) return true;
    }
    return false;
  }

  String _extractName(Map<String, dynamic> data) {
    final possibleKeys = [
      'name',
      'username',
      'full_name',
      'user_name',
      'Name',
      'fullName',
      'displayName',
    ];
    for (final key in possibleKeys) {
      final val = data[key];
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString().trim();
      }
    }
    return 'خطأ';
  }

  String _extractImage(Map<String, dynamic> data) {
    final possibleKeys = [
      'image',
      'profile_image',
      'avatar',
      'photo',
      'Image',
      'profileImage',
      'avatar_url',
      'picture',
      'profile_picture',
    ];
    for (final key in possibleKeys) {
      final val = data[key];
      if (val != null && val.toString().trim().isNotEmpty) {
        return ImageHome.getValidImageUrl(val.toString());
      }
    }
    return ImageHome.getValidImageUrl(null);
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final s = S.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'Assets/log-out.png',
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                  color: const Color(0xffDD0C0C),
                  fit: BoxFit.contain,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  s.areYouSureLogout,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: screenWidth * 0.12,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _performLogout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffDD0C0C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            s.yes,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: SizedBox(
                        height: screenWidth * 0.12,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFAFAFA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            s.cancel,
                            style: TextStyle(
                              color: KprimaryText,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performLogout() {
    _logoutVM.performLogout(
      context,
      onStateChanged: (isLoading) {
        if (mounted) setState(() => _isLoggingOut = isLoading);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final locale = Localizations.localeOf(context);

    List<Widget> profileItems(BuildContext context) => [
      buildProfileOption(
        context,
        label: S.of(context).AccountInfo,
        imagePath: 'Assets/ثيهف.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const AccountInfoSeller(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).bankAccount,
        imagePath: 'Assets/credit-card.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const BankAccountPage(),
      ),
      buildLanguageSwapOption(
        context,
        locale: locale,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      ),
      buildProfileOption(
        context,
        label: S.of(context).support,
        imagePath: 'Assets/fluent_people-community-32-regular.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const TypeSelection(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).Marketing,
        imagePath: 'Assets/hand.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const Marketing(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).AboutUs,
        imagePath: 'Assets/icons8-about-48.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const AboutUs(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).PrivacyPolicy,
        imagePath: 'Assets/ic_sharp-security.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const PrivacyPolicy(),
      ),
      buildProfileOption(
        context,
        label: S.of(context).TermsandConditions,
        imagePath: 'Assets/icons8-terms-and-conditions-48.png',
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        page: const TermsConditions(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBarWithBottomS(title: S.of(context).more),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            decoration: BoxDecoration(
              color: const Color(0xfffafafa),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfile()),
                    );
                    if (updated == true) {
                      await _fetchUserProfile();
                    }
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xfffafafa),
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.005),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: KprimaryColor.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: _isProfileLoading
                                  ? ShimmerContainer(
                                height: screenWidth * 0.12,
                                width: screenWidth * 0.12,
                                radius: screenWidth * 0.12,
                              )
                                  : ClipOval(
                                child: Container(
                                  width: screenWidth * 0.12,
                                  height: screenWidth * 0.12,
                                  color: Colors.white,
                                  child: (_userImageUrl.isEmpty && _profileImage == null)
                                      ? Icon(
                                    Icons.person,
                                    color: KprimaryText,
                                    size: screenWidth * 0.05,
                                  )
                                      : (_userImageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                    imageUrl: _userImageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: SizedBox(
                                        width: screenWidth * 0.04,
                                        height: screenWidth * 0.04,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      color: KprimaryText,
                                      size: screenWidth * 0.05,
                                    ),
                                  )
                                      : Image(
                                    image: FileImage(_profileImage!),
                                    fit: BoxFit.cover,
                                  )),
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_isProfileLoading) ...[
                                    ShimmerContainer(
                                      height: screenWidth * 0.035,
                                      width: screenWidth * 0.35,
                                      radius: 6,
                                    ),
                                    SizedBox(height: screenWidth * 0.015),
                                    ShimmerContainer(
                                      height: screenWidth * 0.028,
                                      width: screenWidth * 0.25,
                                      radius: 6,
                                    ),
                                  ] else ...[
                                    SizedBox(
                                      width: screenWidth * 0.6,
                                      child: Text(
                                        _userName.isNotEmpty ? _userName : S.of(context).unknown,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.mode_edit_outlined,
                              color: KprimaryColor,
                              size: screenWidth * 0.06,
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.008),
                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
              decoration: BoxDecoration(
                color: SecoundColor,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: ListView.separated(
                itemCount: profileItems(context).length,
                separatorBuilder: (_, __) => Divider(
                  color: Colors.grey.shade100,
                  thickness: 1,
                  height: screenHeight * 0.01,
                ),
                itemBuilder: (context, index) => profileItems(context)[index],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02, horizontal: screenWidth * 0.04),
            child: GestureDetector(
              onTap: _isLoggingOut ? null : () => _showLogoutConfirmationDialog(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.012),
                decoration: BoxDecoration(
                  color: _isLoggingOut ? Colors.grey : const Color(0xffDD0C0C),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoggingOut)
                      SizedBox(
                        width: screenWidth * 0.05,
                        height: screenWidth * 0.05,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      Image.asset(
                        'Assets/log-out.png',
                        color: Colors.white,
                        width: screenWidth * 0.05,
                        fit: BoxFit.contain,
                      ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      _isLoggingOut ? S.of(context).loggingOut : S.of(context).logout,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
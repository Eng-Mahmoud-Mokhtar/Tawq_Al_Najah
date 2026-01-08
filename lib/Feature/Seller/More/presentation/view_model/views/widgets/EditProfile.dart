import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../Core/Widgets/Country&city.dart';
import '../../../../../../../Core/Widgets/Location.dart';
import '../../../../../../../Core/Widgets/phoneNumber.dart';
import '../../../../../../../generated/l10n.dart';

class EditProfileSeller extends StatefulWidget {
  const EditProfileSeller({Key? key}) : super(key: key);

  @override
  State<EditProfileSeller> createState() => _EditProfileSellerState();
}

class _EditProfileSellerState extends State<EditProfileSeller> {
  File? _profileImage;

  final TextEditingController socialLinkController = TextEditingController();
  final List<Map<String, dynamic>> socialLinks = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _openFullImage() {
    if (_profileImage == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImage(imageFile: _profileImage!),
      ),
    );
  }

  Map<String, dynamic>? detectPlatform(String url) {
    if (url.contains('facebook.com')) {
      return {'icon': FontAwesomeIcons.facebook, 'color': Colors.blue};
    } else if (url.contains('instagram.com')) {
      return {'icon': FontAwesomeIcons.instagram, 'color': Colors.purple};
    } else if (url.contains('whatsapp.com') || url.contains('wa.me')) {
      return {'icon': FontAwesomeIcons.whatsapp, 'color': Colors.green};
    } else if (url.contains('snapchat.com')) {
      return {'icon': FontAwesomeIcons.snapchat, 'color': Colors.yellow.shade700};
    } else if (url.contains('tiktok.com')) {
      return {'icon': FontAwesomeIcons.tiktok, 'color': Colors.black};
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: SecoundColor,
      appBar: CustomAppBar(title: S.of(context).editProfile),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.05),

                  /// صورة البروفايل + الكاميرا
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _openFullImage,
                          child: CircleAvatar(
                            radius: screenWidth * 0.15,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? Icon(
                              Icons.person,
                              size: screenWidth * 0.15,
                              color: ThirdColor,
                            )
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: screenWidth * 0.04,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: screenWidth * 0.07,
                              height: screenWidth * 0.07,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: KprimaryColor,
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.white,
                                size: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),
                  const PhoneNumber(),
                  SizedBox(height: screenHeight * 0.02),
                  CountryCity(),
                  SizedBox(height: screenHeight * 0.02),
                  Location(),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                      S.of(context).socialLinks,
                      style: TextStyle(
                        color: KprimaryText,
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(height: screenHeight * 0.01),
                  Column(
                    children: socialLinks
                        .map(
                          (link) => Container(
                        margin:
                        EdgeInsets.only(bottom: screenHeight * 0.01),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        height: screenWidth * 0.12,
                        decoration: BoxDecoration(
                          color: const Color(0xffFAFAFA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xffE9E9E9)),
                        ),
                        child: Row(
                          children: [
                            Icon(link['icon'], color: link['color']),
                            SizedBox(width: screenWidth * 0.03),
                            Expanded(
                              child: Text(
                                link['url'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.03,
                                  color: KprimaryText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  socialLinks.remove(link);
                                });
                              },
                              icon: const Icon(Icons.close,
                                  color: Color(0xffDD0C0C)),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                  if (socialLinks.length < 3)
                    SizedBox(
                      height: screenWidth * 0.12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xffFAFAFA),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xffE9E9E9)),
                        ),
                        child: TextField(
                          controller: socialLinkController,
                          onSubmitted: (value) {
                            final platform = detectPlatform(value);
                            if (platform != null) {
                              setState(() {
                                socialLinks.add({
                                  'url': value,
                                  'icon': platform['icon'],
                                  'color': platform['color'],
                                });
                                socialLinkController.clear();
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    S.of(context).unsupportedPlatform,
                                  ),
                                  backgroundColor: const Color(0xffDD0C0C),
                                ),
                              );
                            }
                          },
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: KprimaryText,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: S.of(context).enterSocialLink,
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
                    ),

                  SizedBox(height: screenHeight * 0.03),

                  /// أزرار الحفظ والإلغاء
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KprimaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              S.of(context).save,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        child: SizedBox(
                          height: screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SecoundColor,
                              side:
                              const BorderSide(color: Color(0xffE72929)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              S.of(context).cancel,
                              style: TextStyle(
                                color: const Color(0xffE72929),
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
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final File imageFile;

  const FullScreenImage({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            child: Image.file(imageFile),
          ),
        ),
      ),
    );
  }
}

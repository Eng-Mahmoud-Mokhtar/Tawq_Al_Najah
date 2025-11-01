import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../Core/Widgets/Country&city.dart';
import '../../../../../../Core/Widgets/Location.dart';
import '../../../../SignUpBuyer/presentation/view_model/views/widgets/Name.dart';
import '../../../../../../Core/Widgets/phoneNumber.dart';
import '../../../../../../generated/l10n.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? _profileImage;
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
                children: [
                  SizedBox(height: screenHeight * 0.05),
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
                  const Name(),
                  SizedBox(height: screenHeight * 0.02),
                  const PhoneNumber(),
                  SizedBox(height: screenHeight * 0.02),
                  CountryCity(),
                  SizedBox(height: screenHeight * 0.02),
                  Location(),
                  SizedBox(height: screenHeight * 0.02),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

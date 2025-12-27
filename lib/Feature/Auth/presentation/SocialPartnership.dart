import 'package:flutter/material.dart';
import 'package:tawqalnajah/core/utiles/colors.dart';
import 'package:tawqalnajah/core/utiles/images.dart';
import 'package:tawqalnajah/core/widgets/button.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../Core/Widgets/Country&city.dart';
import '../../../Core/Widgets/Location.dart';
import '../../../Core/Widgets/phoneNumber.dart';

class CommunityPartnerships extends StatefulWidget {
  const CommunityPartnerships({Key? key}) : super(key: key);

  @override
  State<CommunityPartnerships> createState() => _CommunityPartnershipsState();
}

class _CommunityPartnershipsState extends State<CommunityPartnerships> {
  final TextEditingController _entityController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _representativeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: SecoundColor,
      body: Stack(
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
                              Text(
                                S.of(context).ParticipatingEntity,
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
                                    controller: _entityController,
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
                                      hintText: S.of(context).ParticipatingEntity,
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
                              Text(
                                S.of(context).RepresentativeName, // Ensure this string exists in your localization
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
                                    controller: _representativeController,
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
                                      hintText: S.of(context).RepresentativeName,
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
                          SizedBox(height: screenHeight * 0.02),
                       const PhoneNumber(),
                          SizedBox(height: screenHeight * 0.02),
                          CountryCity(),
                          SizedBox(height: screenHeight * 0.02),
                          Location(),
                          SizedBox(height: screenHeight * 0.02),
                          // Submit Button
                          Button(
                            text: S.of(context).submitRequest,
                            onPressed: () {},
                          ),
                        ],
                  ),
                ),
              ],
            ),
          ),
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
      ),
    );
  }

  @override
  void dispose() {
    _entityController.dispose();
    _nameController.dispose();
    _representativeController.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:tawqalnajah/generated/l10n.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../MyStore/presentation/view_model/views/AddPostPage.dart';

Future<void> handleAddPost(BuildContext context) async {
  bool seenSheet = false;
  final screenWidth = MediaQuery.of(context).size.width;

  if (seenSheet == true) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPostPage()),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.03),
        ),
      ),
      builder: (context) {
        bool isChecked = false;
        bool showWarning = false;
        return StatefulBuilder(
          builder: (context, setState) {
            final screenHeight = MediaQuery.of(context).size.height;
            final screenWidth = MediaQuery.of(context).size.width;
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          S.of(context).adTermsTitle,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: KprimaryColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: KprimaryText,
                            size: screenWidth * 0.05,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      S.of(context).adTermsContent,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        height: 1.6,
                      ),
                    ),
                    Row(
                      children: [
                        Transform.scale(
                          scale: screenWidth / 400,
                          child: Checkbox(
                            value: isChecked,
                            activeColor: KprimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (val) {
                              setState(() {
                                isChecked = val ?? false;
                                if (isChecked) showWarning = false;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            S.of(context).agreeToTerms,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.bold,
                              color: KprimaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (showWarning)
                      Padding(
                        padding: EdgeInsets.only(
                          left: screenWidth * 0.02,
                          top: screenHeight * 0.005,
                        ),
                        child: Text(
                          S.of(context).mustAcceptTerms,
                          style: TextStyle(
                            color: const Color(0xffDD0C0C),
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(height: screenHeight * 0.02),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isChecked) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddPostPage(),
                              ),
                            );
                          } else {
                            setState(() {
                              showWarning = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KprimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(screenWidth * 0.02),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                          ),
                        ),
                        child: Text(
                          S.of(context).addAd,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

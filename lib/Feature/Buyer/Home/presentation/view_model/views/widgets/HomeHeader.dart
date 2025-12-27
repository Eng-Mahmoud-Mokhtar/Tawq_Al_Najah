import 'package:flutter/material.dart';
import 'package:tawqalnajah/Feature/Buyer/Home/presentation/view_model/views/widgets/ShimmerContainer.dart';
import '../../../../../../../generated/l10n.dart';
import 'ImageHome.dart';
import 'package:tawqalnajah/Core/utiles/Colors.dart';

class HomeHeader extends StatelessWidget {
  final bool isLoading;
  final String userName;
  final String userImage;
  final double screenWidth;
  final VoidCallback onNotificationPressed;
  final VoidCallback? onProfileTap;

  const HomeHeader({
    super.key,
    required this.isLoading,
    required this.userName,
    required this.userImage,
    required this.screenWidth,
    required this.onNotificationPressed,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              isLoading
                  ? ShimmerContainer(
                      height: screenWidth * 0.13,
                      width: screenWidth * 0.13,
                      radius: screenWidth * 0.13,
                    )
                  : GestureDetector(
                      onTap: onProfileTap,
                      child: ClipOval(
                        child: Container(
                          width: screenWidth * 0.13,
                          height: screenWidth * 0.13,
                          color: Colors.white,
                          child: userImage.isEmpty ||
                                  userImage == ImageHome.getValidImageUrl(null)
                              ? Icon(
                                  Icons.person,
                                  color: KprimaryText,
                                  size: screenWidth * 0.06,
                                )
                              : Image.network(
                                  userImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      color: KprimaryText,
                                      size: screenWidth * 0.06,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
              SizedBox(width: screenWidth * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoading
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                          ],
                        )
                      : Text(
                          userName,
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                  if (!isLoading)
                    Text(
                      S.of(context).happyShopping,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.grey[700],
                      ),
                    ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: KprimaryColor,
              size: screenWidth * 0.07,
            ),
            onPressed: onNotificationPressed,
          ),
        ],
      ),
    );
  }
}


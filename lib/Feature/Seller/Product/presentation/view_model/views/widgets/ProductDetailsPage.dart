import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../cart/presentation/view_model/cart_cubit.dart';
import '../../../../../cart/presentation/view_model/views/widgets/AdCard.dart';
import '../SuggestionsPage.dart';
import 'FullScreenGallery.dart';
import 'getAdsData.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic> ad;
  const ProductDetailsPage({super.key, required this.ad});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int currentPage = 0;
  int selectedRating = 0;
  bool _isAddingToCart = false;
  bool _showAddedText = false;

  void _handleAddToCart() async {
    setState(() {
      _isAddingToCart = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    context.read<CartCubit>().addToCart(widget.ad);
    setState(() {
      _isAddingToCart = false;
      _showAddedText = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _showAddedText = false;
      });
    }
  }

  Future<void> _launchSocialLink(String rawLink) async {
    try {
      String link = rawLink.trim();
      if (!link.startsWith('http://') && !link.startsWith('https://')) {
        link = 'https://$link';
      }
      final Uri uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar(context);
      }
    } catch (e) {
      _showErrorSnackBar(context);
    }
  }

  void _showErrorSnackBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: screenWidth * 0.05,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                S.of(context).errorOpeningLink,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: screenWidth * 0.03,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildCircleIcon(
      String path,
      double screenWidth, {
        VoidCallback? onTap,
        Color backgroundColor = Colors.white,
      }) {
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.015),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: screenWidth * 0.08,
          height: screenWidth * 0.08,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: EdgeInsets.all(screenWidth * 0.012),
          child: Image.asset(path, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget suggestions(double screenWidth, double screenHeight) {
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';
    final List<Map<String, dynamic>> suggestionAds = DataProvider.getAdsData();

    return Directionality(
      textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).suggestions,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SuggestionsPage(ads: suggestionAds),
                    ),
                  );
                },
                child: Text(
                  S.of(context).seeMore,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: KprimaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          SizedBox(
            height: screenHeight * 0.37,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestionAds.length,
              separatorBuilder: (_, __) => SizedBox(width: screenWidth * 0.04),
              itemBuilder: (_, index) {
                return AdCard(
                  ad: suggestionAds[index],
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsPage(ad: suggestionAds[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final images = widget.ad['images'] as List<String>? ?? [];

    return  BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) {
          final isInCart = cartState.cartItems.any(
                (item) => item['ad']['name'] == widget.ad['name'],
          );
          return Scaffold(
            backgroundColor: const Color(0xfffafafa),
            appBar: CustomAppBar(
              title: widget.ad['name'] ?? S.of(context).unknown,
            ),
            body: Directionality(
          textDirection: TextDirection.rtl, // كل الصفحة من اليمين لليسار
          child:Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ====== الصور ======
                      GestureDetector(
                        onTap: () {
                          if (images.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenGallery(
                                  images: images,
                                  initialIndex: currentPage,
                                ),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            SizedBox(
                              height: screenHeight * 0.25,
                              width: double.infinity,
                              child: images.isNotEmpty
                                  ? PageView.builder(
                                itemCount: images.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    currentPage = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Image.asset(
                                    images[index],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                        'Assets/fallback_image.png',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  );
                                },
                              )
                                  : Image.asset(
                                'Assets/fallback_image.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (images.isNotEmpty)
                              Positioned(
                                bottom: screenHeight * 0.02,
                                child: Row(
                                  children: List.generate(images.length,
                                          (dotIndex) {
                                        bool isActive = currentPage == dotIndex;
                                        return AnimatedContainer(
                                          duration:
                                          const Duration(milliseconds: 300),
                                          margin: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.01,
                                          ),
                                          width: isActive
                                              ? screenWidth * 0.02
                                              : screenWidth * 0.02,
                                          height: screenWidth * 0.02,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? Color(0xffFF580E)
                                                : Colors.grey,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                          ],
                        ),
                      ),

                      /// ====== المحتوى ======
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔹 بادينج علوي فوق الاسم والوصف والسعر فقط
                            Padding(
                              padding: EdgeInsets.only(top: screenHeight * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.ad['name'] ?? S.of(context).unknown,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.04,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        "${widget.ad['rating']?.toStringAsFixed(1) ?? '0.0'}",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.01),
                                      Icon(
                                        Icons.star,
                                        color: const Color(0xffFF580E),
                                        size: screenWidth * 0.06,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    widget.ad['description'] ?? S.of(context).noDescription,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    "${widget.ad['price']?.toStringAsFixed(2) ?? '0.00'} ${widget.ad['currency'] ?? ''}",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xffFF580E),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// ====== معلومات البائع ======
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2,
                                ),
                              ),
                              margin: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.01,
                              ),
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: screenHeight * 0.02),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.grey.shade300,
                                          radius: screenWidth * 0.07,
                                          backgroundImage: widget.ad['seller']?['image'] != null
                                              ? AssetImage(widget.ad['seller']['image'])
                                              : const AssetImage('Assets/fallback_image.png'),
                                        ),
                                      ),
                                      SizedBox(width: screenHeight * 0.01),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(top: screenHeight * 0.02),
                                                    child: Text(
                                                      widget.ad['seller']?['name'] ??
                                                          S.of(context).unknown,
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.035,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    if (widget.ad['seller']?['whatsapp'] != null)
                                                      _buildCircleIcon(
                                                        'Assets/whatsapp.png',
                                                        screenWidth,
                                                        onTap: () => _launchSocialLink(
                                                          "https://wa.me/${widget.ad['seller']['whatsapp']}",
                                                        ),
                                                      ),
                                                    if (widget.ad['seller']?['facebook'] != null)
                                                      _buildCircleIcon(
                                                        'Assets/Facebook.png',
                                                        screenWidth,
                                                        onTap: () => _launchSocialLink(
                                                          widget.ad['seller']['facebook'],
                                                        ),
                                                      ),
                                                    if (widget.ad['seller']?['instagram'] != null)
                                                      _buildCircleIcon(
                                                        'Assets/instagram.png',
                                                        screenWidth,
                                                        onTap: () => _launchSocialLink(
                                                          widget.ad['seller']['instagram'],
                                                        ),
                                                      ),
                                                    if (widget.ad['seller']?['snapchat'] != null)
                                                      _buildCircleIcon(
                                                        'Assets/logo.png',
                                                        screenWidth,
                                                        backgroundColor: Colors.yellow,
                                                        onTap: () => _launchSocialLink(
                                                          widget.ad['seller']['snapchat'],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(height:screenWidth * 0.01),
                                            Text(
                                              widget.ad['seller']?['address'] ??
                                                  S.of(context).unknown,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.03,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: screenHeight * 0.02),
                                  Divider(color: Colors.grey.shade200, thickness: 2),
                                  SizedBox(height: screenHeight * 0.01),

                                  /// ====== تقييم المنتج ======
                                  Directionality(
                                    textDirection:
                                    isEnglish ? TextDirection.ltr : TextDirection.rtl,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:  EdgeInsets.symmetric(horizontal:screenHeight * 0.01),
                                          child: Text(
                                            S.of(context).yourProductRating,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(5, (index) {
                                            final isFilled = index < selectedRating;
                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedRating = index + 1;
                                                });
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: screenWidth * 0.015,
                                                ),
                                                child: Icon(
                                                  Icons.star,
                                                  color: isFilled
                                                      ? const Color(0xffFF580E)
                                                      : Colors.grey.shade400,
                                                  size: screenWidth * 0.07,
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                ],
                              ),
                            ),

                            suggestions(screenWidth, screenHeight),
                            SizedBox(height: screenHeight * 0.08),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                Positioned(
                  left: screenWidth * 0.04,
                  right: screenWidth * 0.04,
                  bottom: screenHeight * 0.02,
                  child: ElevatedButton(
                    onPressed:
                    _isAddingToCart || isInCart ? null : _handleAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffFF580E),
                      minimumSize: Size(double.infinity, screenHeight * 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(screenWidth * 0.03),
                      ),
                      elevation: 0,
                    ),
                    child: _isAddingToCart
                        ? SizedBox(
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      _showAddedText
                          ? S.of(context).addedToCart
                          : S.of(context).addToCart,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
          );
        },
    );
  }
}

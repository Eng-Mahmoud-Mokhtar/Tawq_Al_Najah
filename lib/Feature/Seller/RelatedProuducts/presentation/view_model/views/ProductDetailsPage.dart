import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../Buyer/Product/presentation/view_model/views/widgets/FullScreenGallery.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> ad;
  const ProductDetails({super.key, required this.ad});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int currentPage = 0;
  int selectedRating = 0;


  Future<void> _launchSocialLink(String rawLink) async {
    if (rawLink.isEmpty) return;

    try {
      String link = rawLink.trim();

      // تحويل الروابط التابعة
      if (link.startsWith('www.')) {
        link = 'https://$link';
      }

      // معالجة روابط الواتساب بشكل خاص
      if (link.contains('whatsapp') || link.contains('wa.me') ||
          RegExp(r'^\+?[\d\s\-]+$').hasMatch(link)) {
        if (!link.startsWith('https://')) {
          link = 'https://$link';
        }
      }

      final uri = Uri.parse(link);

      // محاولة فتح الرابط بطرق متعددة
      bool canLaunch = false;

      // التحقق من إمكانية فتح الرابط
      try {
        canLaunch = await canLaunchUrl(uri);
      } catch (e) {
        print('Error checking launch capability: $e');
      }

      if (canLaunch) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
          webOnlyWindowName: '_blank',
        );
      } else {
        // طريقة بديلة إذا فشلت الطريقة الأولى
        await _launchUrlFallback(link);
      }
    } catch (e) {
      print('Error launching social link: $e');
      // عرض رسالة للمستخدم
      _showErrorSnackBar(context);
    }
  }

  // طريقة بديلة لفتح الروابط
  Future<void> _launchUrlFallback(String url) async {
    try {
      // محاولة باستخدام launch مباشرة
      if (await canLaunch(url)) {
        await launch(
          url,
          forceSafariVC: false,
          forceWebView: false,
          enableJavaScript: true,
        );
      } else {
        // فتح في متصفح النظام
        if (url.startsWith('http')) {
          await launch(
            url,
            forceSafariVC: false,
            forceWebView: false,
          );
        }
      }
    } catch (e) {
      print('Fallback launch failed: $e');
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
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: screenWidth * 0.05),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                S.of(context).errorOpeningLink,
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: screenWidth * 0.03),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildCircleIcon(String path, double screenWidth, {VoidCallback? onTap, Color backgroundColor = Colors.white}) {
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
              BoxShadow(color: Colors.black12, blurRadius: 3, offset: const Offset(0, 1)),
            ],
          ),
          padding: EdgeInsets.all(screenWidth * 0.012),
          child: Image.asset(path, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final images = (widget.ad['images'] as List<dynamic>?)?.cast<String>() ?? [];
    final shippingOption = widget.ad['shippingOption'] ?? 'no';
    final discount = widget.ad['discount'] ?? 0.0;
    final price = widget.ad['price'] ?? 0.0;
    final originalPrice = discount > 0 ? price / (1 - discount / 100) : price;
    final bool hasInstallment = widget.ad['installment'] == true;
    bool shippingAvailable = shippingOption != 'no';
    String shippingText = shippingAvailable
        ? (shippingOption == 'local' ? S.of(context).localShipping : S.of(context).bothShipping)
        : S.of(context).noShipping;
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: widget.ad['name'] ?? S.of(context).unknown),
      body: Directionality(
        textDirection: isEnglish ? TextDirection.rtl : TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenHeight * 0.25,
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    if (images.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenGallery(images: images, initialIndex: currentPage),
                        ),
                      );
                    }
                  },
                  child: Stack(
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
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('Assets/fallback_image.png', fit: BoxFit.cover);
                              },
                            );
                          },
                        )
                            : Image.asset('Assets/fallback_image.png', fit: BoxFit.cover),
                      ),
                      if (images.isNotEmpty)
                        Positioned(
                          bottom: screenHeight * 0.02,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                                  (dotIndex) {
                                bool isActive = currentPage == dotIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                                  width: isActive ? screenWidth * 0.02 : screenWidth * 0.015,
                                  height: screenWidth * 0.015,
                                  decoration: BoxDecoration(
                                    color: isActive ? const Color(0xffFF580E) : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                  style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "${widget.ad['rating']?.toStringAsFixed(1) ?? '0.0'}",
                                style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Icon(Icons.star, color: const Color(0xffFFD900), size: screenWidth * 0.07),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            widget.ad['description'] ?? S.of(context).noDescription,
                            style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[700]),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "${price.toStringAsFixed(2)} ${widget.ad['currency'] ?? ''}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold, color: const Color(0xffFF580E)),
                                ),
                              ),
                              if (discount > 0) ...[
                                const SizedBox(width: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "${originalPrice.toStringAsFixed(2)} ${widget.ad['currency'] ?? ''}",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[600], decoration: TextDecoration.lineThrough),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "${discount.toStringAsFixed(0)}%",
                                  style: TextStyle(fontSize: screenWidth * 0.035, color: KprimaryColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
                      height: screenWidth * 0.12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: shippingAvailable ? const Color(0xffFF580E) : Colors.grey.shade400,
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(50), bottomRight: Radius.circular(50)),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('Assets/material-symbols_delivery-truck-speed-rounded.png', width: screenWidth * 0.05, height: screenWidth * 0.05, color: Colors.white, fit: BoxFit.contain),
                                    Text(shippingText, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: hasInstallment ? const Color(0xff1D3A77) : Colors.grey.shade400,
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), bottomLeft: Radius.circular(50)),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('Assets/iconoir_cash-solid.png', color: Colors.white, width: screenWidth * 0.05, height: screenWidth * 0.05, fit: BoxFit.contain),
                                    Text(
                                      hasInstallment ? S.of(context).installment : S.of(context).installmentNotAvailable,
                                      style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                radius: screenWidth * 0.07,
                                backgroundImage: widget.ad['seller']?['image'] != null
                                    ? AssetImage(widget.ad['seller']['image'])
                                    : const AssetImage('Assets/fallback_image.png'),
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
                                          child: Text(
                                            widget.ad['seller']?['name'] ?? S.of(context).unknown,
                                            style: TextStyle(fontSize: screenWidth * 0.03, fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            if (widget.ad['seller']?['whatsapp'] != null)
                                              _buildCircleIcon('Assets/whatsapp.png', screenWidth, onTap: () => _launchSocialLink("https://wa.me/${widget.ad['seller']['whatsapp']}")),
                                            if (widget.ad['seller']?['facebook'] != null)
                                              _buildCircleIcon('Assets/Facebook.png', screenWidth, onTap: () => _launchSocialLink(widget.ad['seller']['facebook'])),
                                            if (widget.ad['seller']?['instagram'] != null)
                                              _buildCircleIcon('Assets/instagram.png', screenWidth, onTap: () => _launchSocialLink(widget.ad['seller']['instagram'])),
                                            if (widget.ad['seller']?['snapchat'] != null)
                                              _buildCircleIcon('Assets/logo.png', screenWidth, backgroundColor: Colors.yellow, onTap: () => _launchSocialLink(widget.ad['seller']['snapchat'])),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: screenWidth * 0.01),
                                    Text(
                                      widget.ad['seller']?['address'] ?? S.of(context).unknown,
                                      style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Divider(color: Colors.grey.shade200, thickness: 2),
                          SizedBox(height: screenHeight * 0.01),
                          Column(
                            crossAxisAlignment:
                            isEnglish ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.01),
                                child: Text(
                                  S.of(context).yourProductRating,
                                  style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
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
                                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                                      child: Icon(
                                        Icons.star,
                                        color: isFilled ? const Color(0xffFFD900) : Colors.grey.shade400,
                                        size: screenWidth * 0.07,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
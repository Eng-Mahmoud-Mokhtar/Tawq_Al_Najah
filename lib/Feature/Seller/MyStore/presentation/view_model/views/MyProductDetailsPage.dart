import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../Buyer/Product/presentation/view_model/views/widgets/FullScreenGallery.dart';
import 'widgets/AddPostPage.dart';
import '../../../../MyStore/presentation/view_model/my_store_cubit.dart';
import '../my_store_state.dart';

class MyProductDetailsPage extends StatefulWidget {
  final int adIndex;
  const MyProductDetailsPage({super.key, required this.adIndex});

  @override
  State<MyProductDetailsPage> createState() => _MyProductDetailsPageState();
}

class _MyProductDetailsPageState extends State<MyProductDetailsPage> {
  int currentPage = 0;

  void _showActionDialog({
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    String? cancelText,
  }) {
    final w = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xfffafafa),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(w * 0.03),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: w * 0.035, fontWeight: FontWeight.bold),
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: w * 0.03, color: Colors.grey[700]),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KprimaryColor,
                    minimumSize: Size(0, w * 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    onConfirm();
                  },
                  child: Text(
                    confirmText,
                    style: TextStyle(color: Colors.white, fontSize: w * 0.035),
                  ),
                ),
              ),
              SizedBox(width: w * 0.04),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    minimumSize: Size(0, w * 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    cancelText ?? S.of(context).no,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: w * 0.035,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
        if (kDebugMode) {
          print('Error checking launch capability: $e');
        }
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
      if (kDebugMode) {
        print('Error launching social link: $e');
      }
      // عرض رسالة للمستخدم
      _showLaunchError();
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
      if (kDebugMode) {
        print('Fallback launch failed: $e');
      }
    }
  }

  void _showLaunchError() {
    _showActionDialog(
      title: S.of(context).linkErrorTitle,
      content: S.of(context).errorOpeningLink,
      confirmText: S.of(context).ok,
      onConfirm: () {},
    );
  }

  Widget _buildCircleIcon(
      String path,
      double w, {
        VoidCallback? onTap,
        Color backgroundColor = Colors.white,
      }) {
    return Padding(
      padding: EdgeInsets.only(left: w * 0.015),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: w * 0.08,
          height: w * 0.08,
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
          padding: EdgeInsets.all(w * 0.012),
          child: Image.asset(path, fit: BoxFit.contain),
        ),
      ),
    );
  }

  void _deleteAd() {
    _showActionDialog(
      title: S.of(context).deleteAdTitle,
      content: S.of(context).deleteAdContent,
      confirmText: S.of(context).delete,
      onConfirm: () {
        context.read<MyStoreCubit>().deleteAd(widget.adIndex);
        Navigator.pop(context);
      },
    );
  }

  void _editAd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPostPage(
          adToEdit: context.read<MyStoreCubit>().state.ads[widget.adIndex],
          adIndex: widget.adIndex,
        ),
      ),
    );

    if (result == true) {
      context.read<MyStoreCubit>().refreshAd(widget.adIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final locale = Localizations.localeOf(context);
    final isEnglish = locale.languageCode == 'en';

    return BlocBuilder<MyStoreCubit, MyStoreState>(
      builder: (context, state) {
        if (state.ads.isEmpty || widget.adIndex >= state.ads.length) {
          return Scaffold(
              body: Center(
                  child: Text(S.of(context).adNotFound)));
        }

        final ad = state.ads[widget.adIndex];
        final List<dynamic> imagesRaw = ad['images'] as List;
        final List<dynamic> images = imagesRaw.map((img) {
          if (kIsWeb) return img as Uint8List;
          return File(img as String);
        }).toList();

        final price = (ad['price'] as num).toDouble();
        final discount = (ad['discount'] as num?)?.toDouble() ?? 0.0;
        final originalPrice = discount > 0
            ? price / (1 - discount / 100)
            : price;
        final shippingOption = ad['shippingOption'] ?? 'no';
        final hasInstallment = ad['installment'] == true;
        final shippingAvailable = shippingOption != 'no';
        final shippingText = shippingAvailable
            ? (shippingOption == 'local'
            ? S.of(context).localShipping
            : S.of(context).bothShipping)
            : S.of(context).noShipping;

        final int maxDots = images.length > 3 ? 3 : images.length;
        final int displayIndex = currentPage % maxDots;

        return Directionality(
          textDirection: isEnglish ? TextDirection.rtl : TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xfffafafa),
            appBar: CustomAppBar(title: ad['name'] ?? S.of(context).unknown),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: h * 0.25,
                    child: GestureDetector(
                      onTap: images.isNotEmpty
                          ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenGallery(
                            images: imagesRaw
                                .map((e) => e.toString())
                                .toList(),
                            initialIndex: currentPage,
                          ),
                        ),
                      )
                          : null,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemCount: images.length,
                            onPageChanged: (i) =>
                                setState(() => currentPage = i),
                            itemBuilder: (_, i) {
                              final img = images[i];
                              return kIsWeb
                                  ? Image.memory(
                                img as Uint8List,
                                fit: BoxFit.cover,
                              )
                                  : Image.file(img as File, fit: BoxFit.cover);
                            },
                          ),
                          if (images.isNotEmpty)
                            Positioned(
                              bottom: h * 0.02,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(maxDots, (i) {
                                  final isActive = displayIndex == i;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: EdgeInsets.symmetric(
                                      horizontal: w * 0.01,
                                    ),
                                    width: isActive ? w * 0.02 : w * 0.015,
                                    height: w * 0.015,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xffFF580E)
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
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                ad['name'] ?? S.of(context).unknown,
                                style: TextStyle(
                                  fontSize: w * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "${ad['rating']?.toStringAsFixed(1) ?? '0.0'}",
                              style: TextStyle(
                                fontSize: w * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              color: const Color(0xffFFD900),
                              size: w * 0.07,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ad['description'] ?? S.of(context).noDescription,
                          style: TextStyle(
                            fontSize: w * 0.035,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              "${price.toStringAsFixed(2)} ${ad['currency'] ?? ''}",
                              style: TextStyle(
                                fontSize: w * 0.04,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xffFF580E),
                              ),
                            ),
                            if (discount > 0) ...[
                              const SizedBox(width: 16),
                              Text(
                                "${originalPrice.toStringAsFixed(2)} ${ad['currency'] ?? ''}",
                                style: TextStyle(
                                  fontSize: w * 0.035,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "${discount.toStringAsFixed(0)}%",
                                style: TextStyle(
                                  fontSize: w * 0.035,
                                  color: KprimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: w * 0.015),
                          height: w * 0.12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: shippingAvailable
                                        ? const Color(0xffFF580E)
                                        : Colors.grey.shade400,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(50),
                                      bottomRight: Radius.circular(50),
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                            'Assets/material-symbols_delivery-truck-speed-rounded.png',
                                            width: w * 0.05, height: w * 0.05, color: Colors.white, fit: BoxFit.contain
                                        ),
                                        Text(
                                          shippingText,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: w * 0.03,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: hasInstallment
                                        ? const Color(0xff1D3A77)
                                        : Colors.grey.shade400,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(50),
                                      bottomLeft: Radius.circular(50),
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                            'Assets/iconoir_cash-solid.png',
                                            width: w * 0.05, height: w * 0.05, color: Colors.white, fit: BoxFit.contain
                                        ),
                                        Text(
                                          hasInstallment
                                              ? S.of(context).installment
                                              : S.of(context).installmentNotAvailable,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: w * 0.03,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          margin: EdgeInsets.symmetric(vertical: h * 0.01),
                          padding: EdgeInsets.all(w * 0.02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey.shade300,
                                    radius: w * 0.07,
                                    child: Icon(
                                      Icons.store,
                                      color: Colors.white,
                                      size: w * 0.07,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "محمود استور", // يمكن أيضًا تحويله للترجمة حسب الاسم
                                                style: TextStyle(
                                                  fontSize: w * 0.03,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                _buildCircleIcon(
                                                  'Assets/whatsapp.png',
                                                  w,
                                                  onTap: () => _launchSocialLink(
                                                    "https://wa.me/1234567890",
                                                  ),
                                                ),
                                                _buildCircleIcon(
                                                  'Assets/Facebook.png',
                                                  w,
                                                  onTap: () => _launchSocialLink(
                                                    "facebook.com/yourstore",
                                                  ),
                                                ),
                                                _buildCircleIcon(
                                                  'Assets/instagram.png',
                                                  w,
                                                  onTap: () => _launchSocialLink(
                                                    "instagram.com/yourstore",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "مصر - مصر الجديدة - شيراتون - المطار", // يمكن تحويله أيضًا للترجمة
                                          style: TextStyle(
                                            fontSize: w * 0.03,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(
                                color: Color(0xffE0E0E0),
                                thickness: 2,
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment:
                                isEnglish ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: h * 0.01,
                                    ),
                                    child: Text(
                                      S.of(context).yourProductRating,
                                      style: TextStyle(
                                        fontSize: w * 0.035,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: isEnglish ? TextAlign.left : TextAlign.right,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (i) {
                                      return GestureDetector(
                                        onTap: () => setState(() {}),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: w * 0.015,
                                          ),
                                          child: Icon(
                                            Icons.star,
                                            color: i < 0
                                                ? const Color(0xffFFD900)
                                                : Colors.grey.shade400,
                                            size: w * 0.07,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: w * 0.02),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _editAd,
                                label: Text(
                                  S.of(context).edit,
                                  style: TextStyle(
                                    fontSize: w * 0.035,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KprimaryColor,
                                  padding: EdgeInsets.symmetric(
                                    vertical: w * 0.05,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _deleteAd,
                                label: Text(
                                  S.of(context).delete,
                                  style: TextStyle(
                                    fontSize: w * 0.035,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffDD0C0C),
                                  padding: EdgeInsets.symmetric(
                                    vertical: w * 0.05,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
          ),
        );
      },
    );
  }
}
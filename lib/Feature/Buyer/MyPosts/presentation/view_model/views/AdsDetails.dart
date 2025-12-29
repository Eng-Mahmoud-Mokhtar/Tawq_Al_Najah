import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../Product/Data/repository/ProductDetailsRepository.dart';
import '../../../../Product/Data/repository/RatingRepository.dart';
import '../../../../Product/presentation/view_model/views/widgets/FullScreenGallery.dart';
import 'CreatPost.dart';

class AdsDetails extends StatefulWidget {
  final int productId;
  final Map<String, dynamic> initialProductData;

  const AdsDetails({
    super.key,
    required this.productId,
    required this.initialProductData,
  });

  @override
  State<AdsDetails> createState() => _AdsDetailsState();
}

class _AdsDetailsState extends State<AdsDetails> {
  late Map<String, dynamic> _productData;
  Map<String, dynamic> _sellerData = {};
  bool _isLoading = true;
  int _currentPage = 0;
  int _selectedRating = 0;
  bool _ratingSubmitted = false;

  final ProductDetailsRepository _repository = ProductDetailsRepository();
  final RatingRepository _ratingRepository = RatingRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isDeleting = false;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _productData = Map<String, dynamic>.from(widget.initialProductData);
    _loadSavedRating();
    _loadProductDetails();
  }

  List<String> _getProductImages() {
    final raw = _productData['images'] ?? _productData['image'] ?? [];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return [raw.trim()];
    }
    return <String>[];
  }

  Future<void> _loadSavedRating() async {
    final savedRating = await _storage.read(key: 'rating_${widget.productId}');
    if (savedRating != null) {
      setState(() {
        _selectedRating = int.parse(savedRating);
        _ratingSubmitted = true;
      });
    }
  }

  Future<void> _saveRating(int rating) async {
    await _storage.write(key: 'rating_${widget.productId}', value: rating.toString());
  }

  Future<void> _loadProductDetails() async {
    try {
      final token = await _storage.read(key: 'user_token');
      _repository.token = token;
      final data = await _repository.fetchProductDetails(widget.productId);

      setState(() {
        _productData = data['productDetails'] ?? {};
        _sellerData = (data['sallerDetails'] is Map)
            ? Map<String, dynamic>.from(data['sallerDetails'])
            : {};
        _isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _sellerData = {};
        });
      }
    }
  }

  Future<void> _submitRating(int rating) async {
    if (_ratingSubmitted) return;
    try {
      final token = await _storage.read(key: 'user_token');
      if (token != null) {
        await _ratingRepository.submitRating(
          productId: widget.productId,
          rating: rating,
          token: token,
        );
      }
      await _saveRating(rating);
      setState(() {
        _selectedRating = rating;
        _ratingSubmitted = true;
      });
      _loadProductDetails();
    } catch (_) {}
  }

  String _normalizeLink(String? rawLink) {
    if (rawLink == null || rawLink.trim().isEmpty) return '';
    final link = rawLink.trim();

    // معالجة روابط الواتساب بشكل خاص
    if (link.startsWith('+') || RegExp(r'^[\d\s\-]+$').hasMatch(link)) {
      // إذا كان الرقم يبدأ بـ + أو أرقام فقط
      final cleanedNumber = link.replaceAll(RegExp(r'[^\d+]'), '');
      if (cleanedNumber.startsWith('+')) {
        return 'https://wa.me/$cleanedNumber';
      } else {
        return 'https://wa.me/+$cleanedNumber';
      }
    }

    if (link.startsWith('http://') || link.startsWith('https://')) return link;
    return 'https://$link';
  }

  Future<void> _launchSocialLink(String? rawLink) async {
    if (rawLink == null || rawLink.trim().isEmpty) return;

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
      _showLaunchError(context);
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

  void _showLaunchError(BuildContext context) {
    final snackBar = SnackBar(
      content: Text(S.of(context).error),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: screenWidth * 0.1,
                    color: Colors.orange.shade700,
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),
                Text(
                  S.of(context).delete,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  S.of(context).deleteAdContent,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: screenWidth * 0.01),
                        child: TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext, rootNavigator: true).pop(false),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            ),
                          ),
                          child: Text(
                            S.of(context).cancel,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: screenWidth * 0.01),
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext, rootNavigator: true).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffDD0C0C),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.02),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            S.of(context).delete,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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

  Future<void> _showSuccessDialog(String message, {bool isDelete = false}) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.05),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.05),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: screenWidth * 0.1,
                    color: Colors.green.shade700,
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),
                Text(
                  S.of(context).successTitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext, rootNavigator: true).pop();
                      Navigator.of(context, rootNavigator: true).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KprimaryColor,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      S.of(context).ok,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToEditPage() async {
    if (_productData.isEmpty) return;

    List<Map<String, dynamic>> socialLinks = [];

    void addLinksFromSource(Map<String, dynamic> source) {
      if (source['linkInsta'] != null && source['linkInsta'].toString().isNotEmpty) {
        String instaUrl = _normalizeLink(source['linkInsta'].toString());
        if (instaUrl.isNotEmpty) socialLinks.add({'url': instaUrl});
      }
      if (source['linkWhatsapp'] != null && source['linkWhatsapp'].toString().isNotEmpty) {
        String whatsappUrl = _normalizeLink(source['linkWhatsapp'].toString());
        if (whatsappUrl.isNotEmpty) socialLinks.add({'url': whatsappUrl});
      }
      if (source['linkSnab'] != null && source['linkSnab'].toString().isNotEmpty) {
        String snapUrl = _normalizeLink(source['linkSnab'].toString());
        if (snapUrl.isNotEmpty) socialLinks.add({'url': snapUrl});
      }
      if (source['linkFacebook'] != null && source['linkFacebook'].toString().isNotEmpty) {
        String fbUrl = _normalizeLink(source['linkFacebook'].toString());
        if (fbUrl.isNotEmpty) socialLinks.add({'url': fbUrl});
      }
    }

    addLinksFromSource(_productData);
    if (socialLinks.isEmpty && _sellerData.isNotEmpty) addLinksFromSource(_sellerData);

    List<dynamic> imageList = [];
    final imagesRaw = _productData['images'] ?? _productData['image'] ?? [];
    if (imagesRaw is List) imageList = List.from(imagesRaw);

    final Map<String, dynamic> editData = {
      'id': _productData['id'] ?? widget.productId,
      'name': _productData['name'] ?? '',
      'description': _productData['description'] ?? '',
      'price': _productData['price']?.toString() ?? '0',
      'discount': _productData['discount']?.toString() ?? '0',
      'images': imageList,
      'social_links': socialLinks,
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePost(
          adToEdit: editData,
          adId: widget.productId,
          isEditing: true,
        ),
      ),
    );

    if (result == true) {
      await _loadProductDetails();
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteProduct() async {
    final confirmed = await _showDeleteConfirmationDialog();
    if (confirmed == true) {
      setState(() => _isDeleting = true);

      try {
        final token = await _storage.read(key: 'user_token');
        final headers = {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        };

        final response = await _dio.delete(
          'https://toknagah.viking-iceland.online/api/user/products/delete-ad/${widget.productId}',
          options: Options(headers: headers),
        );

        if (response.statusCode == 200) {
          await _showSuccessDialog(S.of(context).adDeletedSuccess, isDelete: true);
        } else {
          throw Exception('${S.of(context).failedToDeleteAd}: ${response.statusCode}');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${S.of(context).errorDeletingAd}: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isDeleting = false);
      }
    }
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
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
          padding: EdgeInsets.all(screenWidth * 0.012),
          child: Image.asset(path, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Widget _buildSellerInfo(double screenWidth, double screenHeight) {
    final bool hasSeller = _sellerData.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: Column(
        crossAxisAlignment: Localizations.localeOf(context).languageCode == 'ar'
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if (!hasSeller) ...[
            Text(
              S.of(context).yourProductRating,
              style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
              textAlign: Localizations.localeOf(context).languageCode == 'ar'
                  ? TextAlign.right
                  : TextAlign.left,
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _selectedRating;
                return GestureDetector(
                  onTap: _ratingSubmitted ? null : () => _submitRating(i + 1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                    child: Icon(
                      Icons.star,
                      color: filled ? const Color(0xffFFD900) : Colors.grey.shade400,
                      size: screenWidth * 0.07,
                    ),
                  ),
                );
              }),
            ),
          ] else ...[
            Row(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.07,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: (_sellerData['image'] != null &&
                      _sellerData['image'].toString().isNotEmpty)
                      ? NetworkImage(_sellerData['image'])
                      : const AssetImage('Assets/fallback_image.png') as ImageProvider,
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sellerData['name'] ?? S.of(context).unknown,
                        style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
                      ),
                      if (_sellerData['address'] != null &&
                          _sellerData['address'].toString().isNotEmpty)
                        Text(
                          _sellerData['address'],
                          style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (_sellerData['linkWhatsapp'] != null &&
                        _sellerData['linkWhatsapp'].toString().isNotEmpty)
                      _buildCircleIcon(
                        'Assets/whatsapp.png',
                        screenWidth,
                        onTap: () => _launchSocialLink(_sellerData['linkWhatsapp']),
                      ),
                    if (_sellerData['linkFacebook'] != null &&
                        _sellerData['linkFacebook'].toString().isNotEmpty)
                      _buildCircleIcon(
                        'Assets/Facebook.png',
                        screenWidth,
                        onTap: () => _launchSocialLink(_sellerData['linkFacebook']),
                      ),
                    if (_sellerData['linkInsta'] != null &&
                        _sellerData['linkInsta'].toString().isNotEmpty)
                      _buildCircleIcon(
                        'Assets/instagram.png',
                        screenWidth,
                        onTap: () => _launchSocialLink(_sellerData['linkInsta']),
                      ),
                    if (_sellerData['linkSnab'] != null &&
                        _sellerData['linkSnab'].toString().isNotEmpty)
                      _buildCircleIcon(
                        'Assets/logo.png',
                        screenWidth,
                        backgroundColor: Colors.yellow,
                        onTap: () => _launchSocialLink(_sellerData['linkSnab']),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Divider(color: Colors.grey.shade200, thickness: 2),
            SizedBox(height: screenHeight * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.01),
              child: Text(
                S.of(context).yourProductRating,
                style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
                textAlign: Directionality.of(context) == TextDirection.rtl
                    ? TextAlign.right
                    : TextAlign.left,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _selectedRating;
                return GestureDetector(
                  onTap: _ratingSubmitted ? null : () => _submitRating(i + 1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                    child: Icon(
                      Icons.star,
                      color: filled ? const Color(0xffFFD900) : Colors.grey.shade400,
                      size: screenWidth * 0.07,
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildShippingCard(double screenWidth, double screenHeight) {
    final isDeliverable = _productData['is_deliverd'] == 1;
    final hasInstallment = _productData['is_installment'] == 1;

    String shippingText = isDeliverable ? S.of(context).localShipping : S.of(context).noShipping;
    String installmentText = hasInstallment ? S.of(context).installment : S.of(context).installmentNotAvailable;

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
      height: screenWidth * 0.12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDeliverable ? const Color(0xffFF580E) : Colors.grey.shade400,
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
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      shippingText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
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
                color: hasInstallment ? const Color(0xff1D3A77) : Colors.grey.shade400,
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
                      color: Colors.white,
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      installmentText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03,
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
    );
  }

  Widget _buildImageSection(double screenWidth, double screenHeight) {
    final images = _getProductImages();

    return SizedBox(
      height: screenHeight * 0.25,
      width: double.infinity,
      child: Stack(
        children: [
          SizedBox(
            height: screenHeight * 0.25,
            width: double.infinity,
            child: images.isNotEmpty
                ? PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, i) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenGallery(
                        images: images,
                        initialIndex: i,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  images[i],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildMainImageErrorPlaceholder(screenWidth, screenHeight);
                  },
                ),
              ),
            )
                : _buildMainImageErrorPlaceholder(screenWidth, screenHeight),
          ),
          if (images.length > 1)
            Positioned(
              bottom: screenHeight * 0.02,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (dotIndex) {
                  bool isActive = _currentPage == dotIndex;
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
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainImageErrorPlaceholder(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade400,
          size: screenWidth * 0.1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xfffafafa),
        body: Center(child: CircularProgressIndicator(color: Color(0xffFF580E))),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final price = _productData['price'] ?? 0;
    final priceAfter = _productData['priceAfterDiscount'] ?? price;
    final discount = _productData['discount'] ?? 0;
    final currency = _productData['currency_type'] ?? S.of(context).SYP;
    final avgRate = _productData['avg_rate']?.toStringAsFixed(1) ?? '0.0';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(title: _productData['name'] ?? S.of(context).unknown),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildImageSection(screenWidth, screenHeight),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                (_productData['name'] ?? '').toString(),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              avgRate,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.01),
                            Icon(Icons.star, color: const Color(0xffFFD900), size: screenWidth * 0.07),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Row(
                          children: [
                            Text(
                              "$priceAfter $currency",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xffFF580E),
                              ),
                            ),
                            if (discount > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                "$price $currency",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.grey[600],
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${discount.toStringAsFixed(0)}%",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: KprimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        buildShippingCard(screenWidth, screenHeight),
                        SizedBox(height: screenHeight * 0.02),
                        _buildSellerInfo(screenWidth, screenHeight),
                        SizedBox(height: screenWidth * 0.15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: screenWidth * 0.04,
              right: screenWidth * 0.04,
              bottom: screenHeight * 0.02,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: screenWidth * 0.12,
                      child: ElevatedButton(
                        onPressed: _isDeleting ? null : _deleteProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffDD0C0C),
                          minimumSize: Size(double.infinity, screenWidth * 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                          ),
                          elevation: 3,
                        ),
                        child: _isDeleting
                            ? SizedBox(
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outlined, color: Colors.white, size: screenWidth * 0.05),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              S.of(context).delete,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: SizedBox(
                      height: screenWidth * 0.12,
                      child: ElevatedButton(
                        onPressed: _navigateToEditPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KprimaryColor,
                          minimumSize: Size(double.infinity, screenWidth * 0.12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                          ),
                          elevation: 3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: screenWidth * 0.05),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              S.of(context).edit,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.white,
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
            ),
          ],
        ),
      ),
    );
  }
}
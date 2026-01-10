import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../../../../Buyer/MyPosts/presentation/view_model/MyPosts_Cubit.dart';
import 'MyStorePage.dart';

class AddPostPage extends StatefulWidget {
  final Map<String, dynamic>? adToEdit;
  final int? adId;
  final bool isEditing;

  const AddPostPage({
    super.key,
    this.adToEdit,
    this.adId,
    this.isEditing = false,
  });

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  // UI state
  late String deliveryType;
  late bool installment;
  bool showQuantityWarning = true;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController socialLinkController = TextEditingController();
  final TextEditingController feesInternalController = TextEditingController();
  final TextEditingController feesExternalController = TextEditingController();

  // Images and social links
  List<dynamic> selectedImages = [];
  final List<Map<String, dynamic>> socialLinks = [];
  final ImagePicker _picker = ImagePicker();

  // API and auth
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late Dio _dio;
  bool _isSubmitting = false;
  String? _token;

  // Validation errors
  String? _nameError;
  String? _stockError;
  String? _priceError;
  String? _discountError;
  String? _imagesError;
  bool _socialLinkError = false;
  String? _feesInternalError;
  String? _feesExternalError;

  // Social link fields
  String? _linkInsta;
  String? _linkWhatsapp;

  // Currency type
  final String currencyType = 'ريال';

  // New state variables for error handling
  bool _hasConnectionError = false;
  String? _globalErrorMessage;
  bool _isLoadingAdData = false;

  @override
  void initState() {
    super.initState();

    // Defaults
    deliveryType = "noDeliver";
    installment = false;

    // Setup Dio
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://toknagah.viking-iceland.online/api',
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 45),
      ),
    );

    // Add auth header interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _token ??= await _getToken();
          if (_token != null && _token!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          options.headers.remove('Content-Type');
          return handler.next(options);
        },
      ),
    );

    // Logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );

    _loadToken();
    if (widget.adToEdit != null && widget.isEditing) {
      _loadAdForEdit();
    } else {
      _isLoadingAdData = false;
    }
  }

  // ==================== تصميم فشل الاتصال الموحد ====================
  Widget _buildErrorState(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: screenHeight * 0.8,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.04),
                    Icon(
                      Icons.network_check,
                      color: Colors.grey,
                      size: screenWidth * 0.15,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      S.of(context).connectionTimeout,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
            SizedBox(height: screenHeight * 0.04),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasConnectionError = false;
                    _globalErrorMessage = null;
                  });
                  if (widget.isEditing && widget.adToEdit != null) {
                    _loadAdForEdit();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF580E),
                  minimumSize: Size(screenWidth * 0.6, screenHeight * 0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  S.of(context).tryAgain,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    )
    );
  }

  String _getUserFriendlyErrorMessage(String technicalMessage) {
    final lowerMessage = technicalMessage.toLowerCase();

    if (lowerMessage.contains('timeout') || lowerMessage.contains('timed out')) {
      return S.current.connectionTimeout;
    } else if (lowerMessage.contains('no internet') || lowerMessage.contains('network')) {
      return S.current.connectionError;
    } else if (lowerMessage.contains('server') || lowerMessage.contains('500') || lowerMessage.contains('502')) {
      return S.current.serverError;
    } else if (lowerMessage.contains('unauthorized') || lowerMessage.contains('401')) {
      return S.current.sessionExpired;
    } else if (lowerMessage.contains('token') || lowerMessage.contains('login')) {
      return S.current.pleaseLoginFirst;
    }

    return S.current.somethingWentWrong;
  }

  Future<String?> _getToken() async {
    try {
      final secureToken = await _secureStorage.read(key: 'user_token');
      if (secureToken != null && secureToken.isNotEmpty) {
        if (secureToken.startsWith('Bearer ')) {
          return secureToken.substring(7);
        }
        return secureToken;
      }
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ??
          prefs.getString('auth_token') ??
          prefs.getString('access_token');
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadToken() async {
    _token = await _getToken();
  }

  dynamic _apiNullableLink(String? v) {
    if (v == null || v.trim().isEmpty) return "";
    return v.trim();
  }

  void _loadAdForEdit() {
    if (widget.adToEdit == null) {
      setState(() {
        _hasConnectionError = true;
        _globalErrorMessage = S.of(context).failedToLoadData;
        _isLoadingAdData = false;
      });
      return;
    }

    setState(() {
      _isLoadingAdData = true;
      _hasConnectionError = false;
      _globalErrorMessage = null;
    });

    try {
      final ad = widget.adToEdit!;
      final rawName = ad['name']?.toString() ?? '';
      nameController.text = rawName.length > 30 ? rawName.substring(0, 30) : rawName;

      stockController.text = ad['stock']?.toString() ?? ad['quantity']?.toString() ?? '1';

      final rawPriceStr = ad['price']?.toString() ?? '0';
      final priceVal = double.tryParse(rawPriceStr) ?? 0;
      priceController.text = priceVal > 1000000 ? '1000000' : rawPriceStr;

      discountController.text = ad['discount']?.toString() ?? '0';
      descriptionController.text = ad['description']?.toString() ?? '';
      final adDeliveryType = ad['delivery_type']?.toString() ?? ad['shippingOption']?.toString();
      deliveryType = ['internal', 'internalAndexternal', 'noDeliver'].contains(adDeliveryType)
          ? adDeliveryType!
          : (ad['is_deliverd'] == 1 ? 'internal' : 'noDeliver');
      installment = (ad['is_installment'] == 1 || ad['installment'] == true);

      feesInternalController.text = ad['fees_internal']?.toString() ?? '';
      feesExternalController.text = ad['fees_external']?.toString() ?? '';

      socialLinks.clear();
      _linkInsta = null;
      _linkWhatsapp = null;

      void addLinkIfValid(String? raw) {
        if (raw == null || raw.trim().isEmpty) return;
        final normalized = normalizeLink(raw);
        final platform = detectPlatform(normalized);
        if (platform != null) {
          _setLinkFieldByUrl(normalized);
          final platformName = (platform['name']?.toString().toLowerCase() ?? '');
          socialLinks.removeWhere((old) {
            final oldUrl = old['url']?.toString() ?? '';
            final oldPlatform = detectPlatform(oldUrl);
            final oldName = (oldPlatform?['name']?.toString().toLowerCase() ?? '');
            return oldName == platformName;
          });
          socialLinks.add({
            'url': normalized,
            'icon': platform['icon'] ?? Icons.link,
            'color': platform['color'] ?? Colors.grey,
          });
        }
      }

      addLinkIfValid(ad['linkInsta']?.toString());
      addLinkIfValid(ad['linkWhatsapp']?.toString());

      if (ad['social_links'] is List) {
        for (var link in (ad['social_links'] as List)) {
          final url = link is Map ? (link['url']?.toString() ?? '') : (link is String ? link : '');
          if (url.isNotEmpty) addLinkIfValid(url);
        }
      }

      selectedImages.clear();
      if (ad['images'] is List) {
        selectedImages.addAll(ad['images']);
      } else if (ad['image'] is List) {
        selectedImages.addAll(ad['image']);
      }

      setState(() {
        _isLoadingAdData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAdData = false;
        _hasConnectionError = true;
        _globalErrorMessage = _getUserFriendlyErrorMessage(e.toString());
      });
    }
  }

  void _setLinkFieldByUrl(String url) {
    final platform = detectPlatform(url);
    if (platform != null) {
      final platformName = platform['name']?.toString().toLowerCase() ?? '';
      if (platformName.contains('instagram')) {
        _linkInsta = url;
      } else if (platformName.contains('whatsapp')) {
        _linkWhatsapp = url;
      }
    }
  }

  String normalizeLink(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  Map<String, dynamic>? detectPlatform(String url) {
    final urlStr = url.toLowerCase();
    if (urlStr.contains('facebook') || urlStr.contains('fb.me') || urlStr.contains('fb.com')) {
      return {'name': 'Facebook', 'icon': FontAwesomeIcons.facebook, 'color': Colors.blue};
    } else if (urlStr.contains('instagram') || urlStr.contains('instagr.am')) {
      return {'name': 'Instagram', 'icon': FontAwesomeIcons.instagram, 'color': Colors.purple};
    } else if (urlStr.contains('whatsapp') || urlStr.contains('wa.me')) {
      return {'name': 'WhatsApp', 'icon': FontAwesomeIcons.whatsapp, 'color': Colors.green};
    } else if (urlStr.contains('snapchat') || urlStr.contains('snap')) {
      return {'name': 'Snapchat', 'icon': FontAwesomeIcons.snapchat, 'color': Colors.amber[700]};
    }
    return null;
  }

  void _removeSocialLink(int index) {
    final removedLink = socialLinks[index];
    final url = removedLink['url']?.toString() ?? '';
    final platform = detectPlatform(url);
    if (platform != null) {
      final platformName = platform['name']?.toString().toLowerCase() ?? '';
      if (platformName.contains('instagram')) {
        _linkInsta = null;
      } else if (platformName.contains('whatsapp')) {
        _linkWhatsapp = null;
      }
    }
    socialLinks.removeAt(index);
    setState(() {});
  }

  Future<Uint8List> _compressImageForWeb(Uint8List bytes) async {
    final originalImage = img.decodeImage(bytes);
    if (originalImage == null) return bytes;
    final compressedImage = img.copyResize(originalImage, width: 1200);
    final compressedBytes = img.encodeJpg(compressedImage, quality: 80);
    return Uint8List.fromList(compressedBytes);
  }

  Future<MultipartFile> _createMultipartFile(dynamic image, String fieldName) async {
    if (image is Uint8List) {
      Uint8List bytes = image;
      if (bytes.length > 1024 * 1024) {
        bytes = await _compressImageForWeb(bytes);
      }
      return MultipartFile.fromBytes(
        bytes,
        filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    } else if (image is File) {
      return await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
      );
    } else if (image is String) {
      throw Exception('Network image URLs are handled as existing_images, not MultipartFile.');
    } else {
      throw Exception('Unsupported image type');
    }
  }

  void _updateLinkFieldsFromSocialLinks() {
    _linkInsta = null;
    _linkWhatsapp = null;
    for (var link in socialLinks) {
      final url = link['url']?.toString() ?? '';
      if (url.isNotEmpty) _setLinkFieldByUrl(url);
    }
  }

  void _debugPrintFormData(FormData formData, String endpoint) {
    debugPrint('==========================');
    debugPrint('REQUEST: POST $endpoint');
    debugPrint('Headers: Authorization=${_token != null ? "Bearer ****" : "none"}, Accept=application/json');
    debugPrint('Fields:');
    for (final f in formData.fields) {
      debugPrint('  ${f.key}: ${f.value}');
    }
    debugPrint('Files:');
    for (final f in formData.files) {
      final file = f.value;
      debugPrint('  ${f.key}: filename=${file.filename} contentType=${file.contentType}');
    }
    debugPrint('==========================');
  }

  void _showResultDialog({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required String confirmText,
    VoidCallback? onConfirm,
    bool isNetworkError = false,
  }) {
    final s = S.of(context);
    final w = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xfffafafa),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(w * 0.03),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        title: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: w * 0.035, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: w * 0.02),
            Icon(icon, color: iconColor, size: w * 0.12),
          ],
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
                    backgroundColor: isNetworkError ? const Color(0xffFF580E) : KprimaryColor,
                    minimumSize: Size(0, w * 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (isNetworkError) {
                      _submitAd();
                    } else {
                      onConfirm?.call();
                    }
                  },
                  child: Text(
                    isNetworkError ? S.of(context).tryAgain : confirmText,
                    style: TextStyle(color: Colors.white, fontSize: w * 0.035),
                  ),
                ),
              ),
              if (!isNetworkError && onConfirm == null) ...[
                SizedBox(width: w * 0.04),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      minimumSize: Size(0, w * 0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      s.close,
                      style: TextStyle(color: Colors.black87, fontSize: w * 0.035),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final s = S.of(context);
    if (selectedImages.length >= 10) {
      _showResultDialog(
        title: s.imageLimit,
        content: s.max10Images,
        icon: Icons.warning_amber_rounded,
        iconColor: Colors.orange,
        confirmText: s.ok,
      );
      return;
    }
    final List<XFile>? picked = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked != null && picked.isNotEmpty) {
      final newImages = <dynamic>[];
      for (var xfile in picked) {
        if (kIsWeb) {
          final bytes = await xfile.readAsBytes();
          newImages.add(bytes);
        } else {
          newImages.add(File(xfile.path));
        }
      }

      setState(() {
        _imagesError = null;
        if (selectedImages.length + newImages.length > 10) {
          final remaining = 10 - selectedImages.length;
          selectedImages.addAll(newImages.take(remaining));
          _showResultDialog(
            title: s.added,
            content: s.maxImagesReached,
            icon: Icons.check_circle,
            iconColor: Colors.green,
            confirmText: s.ok,
          );
        } else {
          selectedImages.addAll(newImages);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
      _validateImages();
    });
  }

  void _validateImages() {
    if (selectedImages.isEmpty) {
      setState(() => _imagesError = S.of(context).imageRequired);
    } else {
      setState(() => _imagesError = null);
    }
  }

  String _cleanNumberInput(String input, {bool integerOnly = false}) {
    String cleaned = input.replaceAll(RegExp(integerOnly ? r'[^0-9]' : r'[^0-9.]'), '');
    if (!integerOnly) {
      final dotCount = cleaned.split('.').length - 1;
      if (dotCount > 1) {
        final parts = cleaned.split('.');
        cleaned = '${parts[0]}.${parts.sublist(1).join('')}';
      }
    }
    return cleaned;
  }

  bool _validateForm() {
    final s = S.of(context);
    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      setState(() => _nameError = s.nameRequired);
      isValid = false;
    } else {
      setState(() => _nameError = null);
    }

    if (stockController.text.trim().isEmpty) {
      setState(() => _stockError = s.quantity);
      isValid = false;
    } else {
      final stockValue = int.tryParse(stockController.text);
      if (stockValue == null || stockValue <= 0) {
        setState(() => _stockError = s.quantity);
        isValid = false;
      } else {
        setState(() => _stockError = null);
      }
    }

    if (priceController.text.trim().isEmpty) {
      setState(() => _priceError = s.priceRequired);
      isValid = false;
    } else {
      final priceValue = double.tryParse(priceController.text);
      if (priceValue == null || priceValue <= 0) {
        setState(() => _priceError = s.enterValidPrice);
        isValid = false;
      } else {
        setState(() => _priceError = null);
      }
    }

    if (discountController.text.trim().isNotEmpty) {
      final discountValue = double.tryParse(discountController.text);
      if (discountValue == null || discountValue < 0 || discountValue > 100) {
        setState(() => _discountError = s.enterValidDiscount);
        isValid = false;
      } else {
        setState(() => _discountError = null);
      }
    } else {
      setState(() => _discountError = null);
    }

    // Delivery fees validation
    if (deliveryType == 'internal') {
      if (feesInternalController.text.trim().isEmpty) {
        setState(() => _feesInternalError = s.priceRequired);
        isValid = false;
      } else {
        setState(() => _feesInternalError = null);
      }
      _feesExternalError = null;
    } else if (deliveryType == 'internalAndexternal') {
      if (feesInternalController.text.trim().isEmpty) {
        setState(() => _feesInternalError = s.priceRequired);
        isValid = false;
      } else {
        setState(() => _feesInternalError = null);
      }
      if (feesExternalController.text.trim().isEmpty) {
        setState(() => _feesExternalError = s.priceRequired);
        isValid = false;
      } else {
        setState(() => _feesExternalError = null);
      }
    } else {
      _feesInternalError = null;
      _feesExternalError = null;
    }

    if (selectedImages.isEmpty) {
      setState(() => _imagesError = s.imageRequired);
      isValid = false;
    } else {
      setState(() => _imagesError = null);
    }

    if (!isValid) {
      _showResultDialog(
        title: s.incompleteData,
        content: s.fillRequiredFields,
        icon: Icons.error_outline,
        iconColor: Colors.red,
        confirmText: s.ok,
      );
    }

    return isValid;
  }

  Future<void> _createNewAd() async {
    final s = S.of(context);
    try {
      final formData = FormData();

      formData.fields.add(MapEntry('name', nameController.text.trim()));
      formData.fields.add(MapEntry('stock', stockController.text.trim()));
      formData.fields.add(MapEntry('price', priceController.text.trim()));
      formData.fields.add(MapEntry('discount', discountController.text.trim().isNotEmpty ? discountController.text.trim() : '0'));
      formData.fields.add(MapEntry('currency_type', currencyType));
      formData.fields.add(MapEntry('description', descriptionController.text.trim()));

      final isDelivered = deliveryType == 'noDeliver' ? '0' : '1';
      formData.fields.add(MapEntry('is_deliverd', isDelivered));
      formData.fields.add(MapEntry('delivery_type', deliveryType));

      final String feesInternal = (deliveryType != 'noDeliver' && feesInternalController.text.trim().isNotEmpty)
          ? feesInternalController.text.trim()
          : '0';
      final String feesExternal = (deliveryType == 'internalAndexternal' && feesExternalController.text.trim().isNotEmpty)
          ? feesExternalController.text.trim()
          : '0';

      formData.fields.add(MapEntry('fees_internal', feesInternal));
      formData.fields.add(MapEntry('fees_external', feesExternal));

      formData.fields.add(MapEntry('is_installment', installment ? '1' : '0'));

      _updateLinkFieldsFromSocialLinks();
      if ((_linkInsta ?? '').isNotEmpty) formData.fields.add(MapEntry('linkInsta', _linkInsta!));
      if ((_linkWhatsapp ?? '').isNotEmpty) formData.fields.add(MapEntry('linkWhatsapp', _linkWhatsapp!));

      for (int i = 0; i < selectedImages.length; i++) {
        final image = selectedImages[i];
        if (image is String) continue;
        try {
          final multipartFile = await _createMultipartFile(image, 'images[$i]');
          formData.files.add(MapEntry('images[$i]', multipartFile));
        } catch (e) {
          debugPrint('Skip image[$i] due to error: $e');
        }
      }

      _debugPrintFormData(formData, '/saller/products/create-product-ad');

      setState(() {
        _isSubmitting = true;
        _hasConnectionError = false;
      });

      final response = await _dio.post(
        '/saller/products/create-product-ad',
        data: formData,
        options: Options(
          headers: {'Accept': 'application/json'},
          receiveTimeout: const Duration(seconds: 90),
        ),
      ).timeout(const Duration(seconds: 60));

      debugPrint('RESPONSE [${response.statusCode}] /saller/products/create-product-ad');
      debugPrint('DATA: ${response.data}');

      setState(() {
        _isSubmitting = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map &&
            (responseData['status'] == 200 ||
                responseData['status'] == 201 ||
                responseData['success'] == true)) {
          final newAd = {
            'name': nameController.text.trim(),
            'stock': int.tryParse(stockController.text.trim()) ?? 0,
            'price': double.tryParse(priceController.text) ?? 0.0,
            'discount': discountController.text.trim().isNotEmpty
                ? double.tryParse(discountController.text) ?? 0.0 : 0.0,
            'currency_type': currencyType,
            'description': descriptionController.text.trim(),
            'is_deliverd': isDelivered == '1' ? 1 : 0,
            'delivery_type': deliveryType,
            'is_installment': installment ? 1 : 0,
            'linkInsta': _linkInsta,
            'linkWhatsapp': _linkWhatsapp,
            'fees_internal': double.tryParse(feesInternal),
            'fees_external': double.tryParse(feesExternal),
            'images': selectedImages.map((imgItem) {
              if (kIsWeb && imgItem is Uint8List) return imgItem;
              if (imgItem is File) return imgItem.path;
              return imgItem;
            }).toList(),
          };
          try {
            context.read<MyPostsCubit>().addAd(newAd);
          } catch (_) {}

          _showResultDialog(
            title: s.postedSuccessfully,
            content: s.adPosted,
            icon: Icons.add_task_sharp,
            iconColor: KprimaryColor,
            confirmText: s.ok,
            onConfirm: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyStore(fromBottomNav: false)),
              );
            },
          );
        } else {
          final errorMsg = (responseData is Map)
              ? (responseData['message'] ?? responseData['error'] ?? s.somethingWentWrong)
              : s.somethingWentWrong;
          _showResultDialog(
            title: s.error,
            content: errorMsg,
            icon: Icons.error_outline,
            iconColor: const Color(0xffDD0C0C),
            confirmText: s.ok,
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      setState(() {
        _isSubmitting = false;
        _hasConnectionError = true;
      });

      final errorData = e.response?.data;
      final errorMsg = errorData is Map
          ? (errorData['message'] ?? errorData['error'] ?? e.message)
          : e.message;

      final isNetworkError = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError;

      _showResultDialog(
        title: S.of(context).error,
        content: isNetworkError
            ? S.of(context).connectionTimeout
            : (errorMsg ?? S.of(context).somethingWentWrong),
        icon: Icons.error_outline,
        iconColor: const Color(0xffDD0C0C),
        confirmText: S.of(context).ok,
        isNetworkError: isNetworkError,
      );
    } on TimeoutException catch (_) {
      setState(() {
        _isSubmitting = false;
        _hasConnectionError = true;
      });

      _showResultDialog(
        title: S.of(context).error,
        content: S.of(context).connectionTimeout,
        icon: Icons.error_outline,
        iconColor: const Color(0xffDD0C0C),
        confirmText: S.of(context).ok,
        isNetworkError: true,
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      debugPrint('Unhandled error during create: $e');
      _showResultDialog(
        title: S.of(context).error,
        content: S.of(context).somethingWentWrong,
        icon: Icons.error_outline,
        iconColor: const Color(0xffDD0C0C),
        confirmText: S.of(context).ok,
      );
    }
  }

  Future<void> _updateAd() async {
    final s = S.of(context);
    if (widget.adId == null) {
      _showResultDialog(
        title: s.error,
        content: 'Ad ID is missing',
        icon: Icons.error_outline,
        iconColor: const Color(0xffDD0C0C),
        confirmText: s.ok,
      );
      return;
    }
    if (!_validateForm()) return;

    try {
      _updateLinkFieldsFromSocialLinks();
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('name', nameController.text.trim()),
        MapEntry('stock', stockController.text.trim()),
        MapEntry('price', priceController.text.trim()),
        MapEntry('discount', discountController.text.trim().isNotEmpty ? discountController.text.trim() : '0'),
        MapEntry('currency_type', currencyType),
        MapEntry('description', descriptionController.text.trim()),
      ]);

      final isDelivered = deliveryType == 'noDeliver' ? '0' : '1';
      formData.fields.add(MapEntry('is_deliverd', isDelivered));
      formData.fields.add(MapEntry('delivery_type', deliveryType));

      final String feesInternal = (deliveryType != 'noDeliver' && feesInternalController.text.trim().isNotEmpty)
          ? feesInternalController.text.trim()
          : '0';
      final String feesExternal = (deliveryType == 'internalAndexternal' && feesExternalController.text.trim().isNotEmpty)
          ? feesExternalController.text.trim()
          : '0';

      formData.fields.add(MapEntry('fees_internal', feesInternal));
      formData.fields.add(MapEntry('fees_external', feesExternal));

      formData.fields.add(MapEntry('is_installment', installment ? '1' : '0'));

      formData.fields.add(MapEntry('linkInsta', _apiNullableLink(_linkInsta).toString()));
      formData.fields.add(MapEntry('linkWhatsapp', _apiNullableLink(_linkWhatsapp).toString()));

      for (int i = 0; i < selectedImages.length; i++) {
        final image = selectedImages[i];
        if (image is String) {
          formData.fields.add(MapEntry('existing_images[$i]', image));
          continue;
        }
        try {
          final multipartFile = await _createMultipartFile(image, 'images[$i]');
          formData.files.add(MapEntry('images[$i]', multipartFile));
        } catch (e) {
          debugPrint('Skip image[$i] due to error: $e');
        }
      }

      _debugPrintFormData(formData, '/user/products/update-ad/${widget.adId}');

      setState(() {
        _isSubmitting = true;
        _hasConnectionError = false;
      });

      final response = await _dio.post(
        '/user/products/update-ad/${widget.adId}',
        data: formData,
        options: Options(
          headers: {'Accept': 'application/json'},
          receiveTimeout: const Duration(seconds: 90),
        ),
      ).timeout(const Duration(seconds: 60));

      debugPrint('RESPONSE [${response.statusCode}] /user/products/update-ad/${widget.adId}');
      debugPrint('DATA: ${response.data}');

      setState(() {
        _isSubmitting = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map &&
            (responseData['status'] == 200 ||
                responseData['status'] == 201 ||
                responseData['success'] == true)) {
          final updatedAd = {
            'id': widget.adId,
            'name': nameController.text.trim(),
            'stock': int.tryParse(stockController.text.trim()) ?? 0,
            'price': double.tryParse(priceController.text) ?? 0.0,
            'discount': discountController.text.trim().isNotEmpty
                ? double.tryParse(discountController.text) ?? 0.0
                : 0.0,
            'currency_type': currencyType,
            'description': descriptionController.text.trim(),
            'is_deliverd': isDelivered == '1' ? 1 : 0,
            'delivery_type': deliveryType,
            'is_installment': installment ? 1 : 0,
            'linkInsta': (_linkInsta == null || _linkInsta!.isEmpty) ? null : _linkInsta,
            'linkWhatsapp': (_linkWhatsapp == null || _linkWhatsapp!.isEmpty) ? null : _linkWhatsapp,
            'fees_internal': double.tryParse(feesInternal),
            'fees_external': double.tryParse(feesExternal),
            'images': selectedImages.map((imgItem) {
              if (kIsWeb && imgItem is Uint8List) return imgItem;
              if (imgItem is File) return imgItem.path;
              return imgItem;
            }).toList(),
          };
          try {
            context.read<MyPostsCubit>().updateAd(widget.adId!, updatedAd);
          } catch (_) {}

          _showResultDialog(
            title: s.editedSuccessfully,
            content: s.adUpdated,
            icon: Icons.gpp_good_outlined,
            iconColor: KprimaryColor,
            confirmText: s.ok,
            onConfirm: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyStore(fromBottomNav: false)),
              );
            },
          );
        } else {
          final errorMsg = (responseData is Map)
              ? (responseData['message'] ?? responseData['error'] ?? s.somethingWentWrong)
              : s.somethingWentWrong;
          _showResultDialog(
            title: s.error,
            content: errorMsg,
            icon: Icons.error_outline,
            iconColor: const Color(0xffDD0C0C),
            confirmText: s.ok,
          );
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      setState(() {
        _isSubmitting = false;
        _hasConnectionError = true;
      });

      final errorData = e.response?.data;
      final errorMsg = errorData is Map
          ? (errorData['message'] ?? errorData['error'] ?? e.message)
          : e.message;

      final isNetworkError = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError;

      debugPrint('ERROR RESPONSE [${e.response?.statusCode}] /user/products/update-ad/${widget.adId}');
      debugPrint('ERROR DATA: ${e.response?.data}');

      _showResultDialog(
        title: s.error,
        content: isNetworkError ? S.of(context).connectionTimeout : (errorMsg ?? s.somethingWentWrong),
        icon: Icons.error_outline,
        iconColor: const Color(0xffDD0C0C),
        confirmText: s.ok,
        isNetworkError: isNetworkError,
      );
    } on TimeoutException catch (_) {
      setState(() {
        _isSubmitting = false;
        _hasConnectionError = true;
      });

      _showResultDialog(
        title: S.of(context).error,
        content: S.of(context).connectionTimeout,
        icon: Icons.error_outline,
        iconColor: const Color(0xffDD0C0C),
        confirmText: S.of(context).ok,
        isNetworkError: true,
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      debugPrint('Unhandled error during update: $e');
      _showResultDialog(
        title: s.error,
        content: s.somethingWentWrong,
        icon: Icons.error_outline,
        iconColor: const Color(0xffDD0C0C),
        confirmText: s.ok,
      );
    }
  }

  Future<void> _submitAd() async {
    final s = S.of(context);
    if (_token == null || _token!.isEmpty) {
      _showResultDialog(
        title: s.error,
        content: S.of(context).errorLoadingCategories,
        icon: Icons.error_outline,
        iconColor: const Color(0xffDD0C0C),
        confirmText: s.ok,
      );
      return;
    }
    if (!_validateForm()) return;

    if (mounted) setState(() => _isSubmitting = true);
    try {
      if (widget.isEditing && widget.adId != null) {
        await _updateAd();
      } else {
        await _createNewAd();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  ImageProvider _imageProviderForItem(dynamic imgItem) {
    if (kIsWeb && imgItem is Uint8List) return MemoryImage(imgItem);
    if (imgItem is File) return FileImage(imgItem);
    if (imgItem is String) return NetworkImage(imgItem);
    return const AssetImage('Assets/fallback_image.png');
  }

  InputDecoration fieldDecoration(String hint, {Widget? suffix}) {
    final w = MediaQuery.of(context).size.width;
    return InputDecoration(
      hintText: hint,
      suffix: suffix,
      hintStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: w * 0.03,
          fontWeight: FontWeight.bold),
      border: InputBorder.none,
      contentPadding:
      EdgeInsets.symmetric(vertical: w * 0.035, horizontal: w * 0.035),
    );
  }

  List<TextInputFormatter> decimalFormatters() =>
      [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];

  List<TextInputFormatter> integerFormatters() =>
      [FilteringTextInputFormatter.digitsOnly];

  Widget customField(
      String label,
      TextEditingController controller, {
        TextInputType type = TextInputType.text,
        String? hint,
        Widget? suffix,
        String? errorText,
        bool isDiscount = false,
        bool integerOnly = false,
      }) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final s = S.of(context);

    TextInputType keyboardType = type;
    List<TextInputFormatter>? formatters;

    if (label == s.productName) {
      keyboardType = TextInputType.text;
      formatters = [LengthLimitingTextInputFormatter(30)];
    } else if (label == s.price ||
        label == s.discount ||
        label == s.quantity ||
        label == s.internalShipping ||
        label == s.internationalShipping) {
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
      formatters = integerOnly ? integerFormatters() : decimalFormatters();
    } else {
      keyboardType = TextInputType.text;
      formatters = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: KprimaryText,
                fontSize: w * 0.035,
                fontWeight: FontWeight.bold)),
        SizedBox(height: h * 0.01),
        SizedBox(
          height: w * 0.12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xffFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText != null ? const Color(0xffDD0C0C) : const Color(0xffE9E9E9),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: formatters,
              maxLength: label == s.productName ? 30 : null,
              buildCounter: label == s.productName
                  ? (context, {required int currentLength, required bool isFocused, required int? maxLength}) => const SizedBox.shrink()
                  : null,
              style: TextStyle(
                  fontSize: w * 0.03,
                  color: KprimaryText,
                  fontWeight: FontWeight.bold),
              decoration: fieldDecoration(hint ?? label, suffix: suffix),
              onChanged: (value) {
                if (isDiscount) {
                  final cleaned = _cleanNumberInput(value);
                  if (cleaned != value) {
                    controller.text = cleaned;
                    controller.selection = TextSelection.collapsed(offset: cleaned.length);
                  }
                  if (value.isNotEmpty) {
                    final discountValue = double.tryParse(value);
                    if (discountValue != null && discountValue > 100) {
                      const newValue = '100';
                      controller.text = newValue;
                      controller.selection = TextSelection.collapsed(offset: newValue.length);
                      setState(() => _discountError = s.enterValidDiscount);
                    }
                  }
                }
                if (label == s.productName) {
                  setState(() => _nameError = null);
                } else if (label == s.price) {
                  final cleaned = _cleanNumberInput(value);
                  if (cleaned != value) {
                    controller.text = cleaned;
                    controller.selection = TextSelection.collapsed(offset: cleaned.length);
                  }
                  if (cleaned.isNotEmpty) {
                    final priceValue = double.tryParse(cleaned);
                    if (priceValue != null && priceValue > 1000000) {
                      const maxPriceText = '1000000';
                      controller.text = maxPriceText;
                      controller.selection = TextSelection.collapsed(offset: maxPriceText.length);
                    }
                  }
                  setState(() => _priceError = null);
                } else if (label == s.discount) {
                  setState(() => _discountError = null);
                } else if (label == s.quantity) {
                  setState(() => _stockError = null);
                } else if (label == s.internalShipping) {
                  setState(() => _feesInternalError = null);
                } else if (label == s.internationalShipping) {
                  setState(() => _feesExternalError = null);
                }
              },
            ),
          ),
        ),
        SizedBox(height: h * 0.005),
        if (errorText != null)
          SizedBox(
            height: h * 0.02,
            child: Text(
              errorText,
              style: TextStyle(color: const Color(0xffDD0C0C), fontSize: w * 0.03),
            ),
          ),
      ],
    );
  }

  Widget descriptionField(String label, TextEditingController controller) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: KprimaryText,
                fontSize: w * 0.035,
                fontWeight: FontWeight.bold)),
        SizedBox(height: h * 0.01),
        Container(
          height: h * 0.15,
          decoration: BoxDecoration(
              color: const Color(0xffFAFAFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xffE9E9E9))),
          child: TextField(
            controller: controller,
            maxLines: 5,
            keyboardType: TextInputType.text,
            style: TextStyle(
                fontSize: w * 0.03,
                color: KprimaryText,
                fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: s.writeDescription,
              hintStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: w * 0.03,
                  fontWeight: FontWeight.bold),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                  vertical: w * 0.035, horizontal: w * 0.035),
            ),
          ),
        ),
      ],
    );
  }

  Widget optionButton(
      String text, String value, String selectedValue, VoidCallback onTap) {
    final w = MediaQuery.of(context).size.width;
    final bool isSelected = selectedValue == value;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: w * 0.01),
          padding: EdgeInsets.symmetric(vertical: w * 0.03),
          decoration: BoxDecoration(
            color: isSelected ? KprimaryColor : const Color(0xffFAFAFA),
            border: Border.all(
                color: isSelected ? KprimaryColor : const Color(0xffE9E9E9)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(text,
                style: TextStyle(
                    color: isSelected ? Colors.white : KprimaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: w * 0.03)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    if (_hasConnectionError && _isLoadingAdData) {
      return Scaffold(
        backgroundColor: const Color(0xfffafafa),
        appBar: CustomAppBar(
          title: widget.isEditing ? s.editAd : s.addAd,
        ),
        body: _buildErrorState(context),
      );
    }

    if (_isLoadingAdData) {
      return Scaffold(
        backgroundColor: const Color(0xfffafafa),
        appBar: CustomAppBar(
          title: widget.isEditing ? s.editAd : s.addAd,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: KprimaryColor),
              SizedBox(height: h * 0.02),
              Text(
                s.loading,
                style: TextStyle(
                  fontSize: w * 0.035,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final String localShippingLabel = s.internalShipping;
    final String internationalShippingLabel = s.internationalShipping;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(
        title: widget.isEditing ? s.editAd : s.addAd,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customField(s.productName, nameController, hint: s.productName, errorText: _nameError),
                Row(
                  children: [
                    Expanded(
                      child: customField(s.quantity, stockController,
                          type: TextInputType.number, hint: s.quantity, errorText: _stockError, integerOnly: true),
                    ),
                  ],
                ),
                if (showQuantityWarning)
                  Text(s.afterSellingQuantity,
                      style:
                      TextStyle(color: KprimaryColor, fontSize: w * 0.03)),
                SizedBox(height: h * 0.02),
                Row(
                  children: [
                    Expanded(
                        child: customField(s.price, priceController,
                            type: const TextInputType.numberWithOptions(decimal: true),
                            hint: s.enterPrice,
                            errorText: _priceError)),
                    SizedBox(width: w * 0.04),
                    Expanded(
                      child: customField(
                        s.discount,
                        discountController,
                        type: const TextInputType.numberWithOptions(decimal: true),
                        hint: s.enterDiscount,
                        suffix: Text("%",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: w * 0.03)),
                        errorText: _discountError,
                        isDiscount: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.02),
                descriptionField(s.productDescription, descriptionController),
                SizedBox(height: h * 0.02),

                Text(
                  s.socialLinks,
                  style: TextStyle(
                      color: KprimaryText,
                      fontSize: w * 0.035,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: h * 0.01),
                Column(
                  children: socialLinks
                      .map(
                        (link) => Container(
                      margin: EdgeInsets.only(bottom: h * 0.01),
                      padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                      height: w * 0.12,
                      decoration: BoxDecoration(
                        color: const Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xffE9E9E9)),
                      ),
                      child: Row(
                        children: [
                          Icon(link['icon'], color: link['color']),
                          SizedBox(width: w * 0.03),
                          Expanded(
                            child: Text(
                              link['url'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: w * 0.03,
                                color: KprimaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              final index = socialLinks.indexOf(link);
                              _removeSocialLink(index);
                            },
                            icon: const Icon(Icons.close, color: Color(0xffDD0C0C)),
                          ),
                        ],
                      ),
                    ),
                  )
                      .toList(),
                ),
                if (socialLinks.length < 3)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: w * 0.12,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xffFAFAFA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _socialLinkError ? const Color(0xffDD0C0C) : const Color(0xffE9E9E9),
                              width: 1.5,
                            ),
                          ),
                          child: TextField(
                            controller: socialLinkController,
                            keyboardType: TextInputType.text,
                            onSubmitted: (value) {
                              final trimmedValue = normalizeLink(value);

                              if (trimmedValue.isEmpty) {
                                setState(() => _socialLinkError = false);
                                return;
                              }

                              final platform = detectPlatform(trimmedValue);

                              if (platform == null) {
                                setState(() => _socialLinkError = true);
                                socialLinkController.clear();
                                return;
                              }

                              final platformName = platform['name']?.toString().toLowerCase() ?? '';
                              socialLinks.removeWhere((link) {
                                final oldUrl = link['url']?.toString() ?? '';
                                final oldPlatform = detectPlatform(oldUrl);
                                final oldName = oldPlatform?['name']?.toString().toLowerCase() ?? '';
                                return oldName == platformName;
                              });

                              if (platformName.contains('instagram')) {
                                _linkInsta = trimmedValue;
                              } else if (platformName.contains('whatsapp')) {
                                _linkWhatsapp = trimmedValue;
                              }

                              setState(() {
                                socialLinks.add({
                                  'url': trimmedValue,
                                  'icon': platform['icon'] ?? Icons.link,
                                  'color': platform['color'] ?? Colors.grey,
                                });
                                socialLinkController.clear();
                                _socialLinkError = false;
                              });
                            },
                            style: TextStyle(
                                fontSize: w * 0.03,
                                color: KprimaryText,
                                fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: s.enterSocialLink,
                              hintStyle: TextStyle(
                                fontSize: w * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade600,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: w * 0.035, horizontal: w * 0.035),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.005),
                      if (_socialLinkError)
                        SizedBox(
                          height: h * 0.02,
                          child: Text(
                            S.of(context).notSupportedLink,
                            style: TextStyle(color: const Color(0xffDD0C0C), fontSize: w * 0.03),
                          ),
                        ),
                    ],
                  ),

                SizedBox(height: h * 0.02),
                Text(s.imagesMax10,
                    style: TextStyle(
                        color: KprimaryText,
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: h * 0.01),
                Container(
                  width: double.infinity,
                  height: w * 0.36,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _imagesError != null ? const Color(0xffDD0C0C) : Colors.grey.shade200,
                        width: 1.5,
                      )),
                  child: selectedImages.isEmpty
                      ? GestureDetector(
                    onTap: _pickImages,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              size: w * 0.05, color: Colors.grey),
                          SizedBox(height: h * 0.01),
                          Text(s.addImages,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: w * 0.03,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                      : GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: w * 0.02,
                      mainAxisSpacing: w * 0.02,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: selectedImages.length +
                        (selectedImages.length < 10 ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == selectedImages.length &&
                          selectedImages.length < 10) {
                        return GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.grey.shade300)),
                            child: Center(
                                child: Icon(Icons.add,
                                    color: Colors.grey,
                                    size: w * 0.05)),
                          ),
                        );
                      }
                      final imgItem = selectedImages[index];
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: _imageProviderForItem(imgItem),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xffDD0C0C)),
                                child: Icon(Icons.close,
                                    color: Colors.white, size: w * 0.04),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (_imagesError != null) ...[
                  SizedBox(height: h * 0.005),
                  SizedBox(
                    height: h * 0.02,
                    child: Text(
                      _imagesError!,
                      style: TextStyle(color: const Color(0xffDD0C0C), fontSize: w * 0.03),
                    ),
                  ),
                ],

                SizedBox(height: h * 0.03),
                Text(s.shippingOptions,
                    style: TextStyle(
                        color: KprimaryText,
                        fontSize: w * 0.035,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: h * 0.01),
                Row(
                  children: [
                    optionButton(s.none, "noDeliver", deliveryType,
                            () => setState(() => deliveryType = "noDeliver")),
                    optionButton(s.local, "internal", deliveryType,
                            () => setState(() => deliveryType = "internal")),
                    optionButton(s.localAndInternational, "internalAndexternal", deliveryType,
                            () => setState(() => deliveryType = "internalAndexternal")),
                  ],
                ),
                SizedBox(height: h * 0.02),

                if (deliveryType == 'internal') ...[
                  Row(
                    children: [
                      Expanded(
                        child: customField(
                          localShippingLabel,
                          feesInternalController,
                          type: const TextInputType.numberWithOptions(decimal: true),
                          hint: s.price,
                          errorText: _feesInternalError,
                          integerOnly: false,
                        ),
                      ),
                    ],
                  ),
                ] else if (deliveryType == 'internalAndexternal') ...[
                  Row(
                    children: [
                      Expanded(
                        child: customField(
                          localShippingLabel,
                          feesInternalController,
                          type: const TextInputType.numberWithOptions(decimal: true),
                          hint: s.price,
                          errorText: _feesInternalError,
                          integerOnly: false,
                        ),
                      ),
                      SizedBox(width: w * 0.04),
                      Expanded(
                        child: customField(
                          internationalShippingLabel,
                          feesExternalController,
                          type: const TextInputType.numberWithOptions(decimal: true),
                          hint: s.price,
                          errorText: _feesExternalError,
                          integerOnly: false,
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: h * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(s.installmentAvailable,
                        style: TextStyle(
                            color: KprimaryText,
                            fontSize: w * 0.035,
                            fontWeight: FontWeight.bold)),
                    Transform.scale(
                      scale: MediaQuery.of(context).size.width / 400,
                      child: Checkbox(
                        activeColor: KprimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        value: installment,
                        onChanged: (val) {
                          setState(() => installment = val ?? false);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: h * 0.02),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSubmitting ? Colors.grey : KprimaryColor,
                      padding: EdgeInsets.symmetric(vertical: h * 0.012),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(w * 0.02)),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                      width: w * 0.05,
                      height: w * 0.05,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      widget.isEditing ? s.saveChanges : s.postAd,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: w * 0.035,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSubmitting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(color: KprimaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
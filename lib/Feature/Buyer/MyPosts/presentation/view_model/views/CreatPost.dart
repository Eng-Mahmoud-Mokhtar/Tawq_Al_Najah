import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../MyPosts_Cubit.dart';

class CreatePost extends StatefulWidget {
  final Map<String, dynamic>? adToEdit;
  final int? adId;
  final bool isEditing;

  const CreatePost({
    super.key,
    this.adToEdit,
    this.adId,
    this.isEditing = false,
  });
  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController socialLinkController = TextEditingController();
  List<dynamic> selectedImages = [];
  final List<Map<String, dynamic>> socialLinks = [];
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late Dio _dio;
  bool _isSubmitting = false;
  String? _token;
  String? _nameError;
  String? _priceError;
  String? _discountError;
  String? _imagesError;
  bool _socialLinkError = false;
  String? _linkInsta;
  String? _linkWhatsapp;
  String? _linkSnab;
  String? _linkFacebook;

  @override
  void initState() {
    super.initState();
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://toknagah.viking-iceland.online/api',
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 45),
      ),
    );

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

    _loadToken();
    if (widget.adToEdit != null && widget.isEditing) {
      _loadAdForEdit();
    }
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
    if (v == null || v.trim().isEmpty) return "null";
    return v.trim();
  }

  void _loadAdForEdit() {
    final ad = widget.adToEdit!;
    nameController.text = ad['name'] ?? '';
    priceController.text = ad['price']?.toString() ?? '0';
    discountController.text = ad['discount']?.toString() ?? '0';
    descriptionController.text = ad['description'] ?? '';
    socialLinks.clear();
    _linkInsta = null;
    _linkWhatsapp = null;
    _linkSnab = null;
    _linkFacebook = null;
    final insta = ad['linkInsta']?.toString();
    final wa = ad['linkWhatsapp']?.toString();
    final sn = ad['linkSnab']?.toString();
    final fb = ad['linkFacebook']?.toString();

    if (insta != null && insta.trim().isNotEmpty) {
      final normalized = normalizeLink(insta);
      _setLinkFieldByUrl(normalized);
      final platform = detectPlatform(normalized);
      if (platform != null) {
        socialLinks.add({'url': normalized, 'icon': platform['icon'], 'color': platform['color']});
      }
    }
    if (wa != null && wa.trim().isNotEmpty) {
      final normalized = normalizeLink(wa);
      _setLinkFieldByUrl(normalized);
      final platform = detectPlatform(normalized);
      if (platform != null) {
        socialLinks.add({'url': normalized, 'icon': platform['icon'], 'color': platform['color']});
      }
    }
    if (sn != null && sn.trim().isNotEmpty) {
      final normalized = normalizeLink(sn);
      _setLinkFieldByUrl(normalized);
      final platform = detectPlatform(normalized);
      if (platform != null) {
        socialLinks.add({'url': normalized, 'icon': platform['icon'], 'color': platform['color']});
      }
    }
    if (fb != null && fb.trim().isNotEmpty) {
      final normalized = normalizeLink(fb);
      _setLinkFieldByUrl(normalized);
      final platform = detectPlatform(normalized);
      if (platform != null) {
        socialLinks.add({'url': normalized, 'icon': platform['icon'], 'color': platform['color']});
      }
    }

    if (ad['social_links'] != null && ad['social_links'] is List) {
      final links = ad['social_links'] as List;
      for (var link in links) {
        if (link is Map<String, dynamic>) {
          final url = link['url']?.toString() ?? '';
          if (url.isNotEmpty) {
            final normalized = normalizeLink(url);
            final platform = detectPlatform(normalized);
            if (platform != null) {
              // replace any old link for same platform in UI
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
              _setLinkFieldByUrl(normalized);
            }
          }
        } else if (link is String && link.isNotEmpty) {
          final normalized = normalizeLink(link);
          final platform = detectPlatform(normalized);
          if (platform != null) {
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
            _setLinkFieldByUrl(normalized);
          }
        }
      }
    }

    selectedImages.clear();
    if (ad['images'] != null && ad['images'] is List) {
      selectedImages.addAll(ad['images']);
    } else if (ad['image'] != null && ad['image'] is List) {
      selectedImages.addAll(ad['image']);
    }

    setState(() {});
  }

  void _setLinkFieldByUrl(String url) {
    final platform = detectPlatform(url);
    if (platform != null) {
      final platformName = platform['name']?.toString().toLowerCase() ?? '';
      if (platformName.contains('instagram')) {
        _linkInsta = url;
      } else if (platformName.contains('whatsapp')) {
        _linkWhatsapp = url;
      } else if (platformName.contains('snapchat')) {
        _linkSnab = url;
      } else if (platformName.contains('facebook')) {
        _linkFacebook = url;
      }
    }
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
    } else {
      throw Exception('Unsupported image type');
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
      if (platformName.contains('instagram')) _linkInsta = null;
      else if (platformName.contains('whatsapp')) _linkWhatsapp = null;
      else if (platformName.contains('snapchat')) _linkSnab = null;
      else if (platformName.contains('facebook')) _linkFacebook = null;
    }

    socialLinks.removeAt(index);
    setState(() {});
  }

  void _showResultDialog({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required String confirmText,
    VoidCallback? onConfirm,
  }) {
    final w = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xfffafafa),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(w * 0.03),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        title: Column(
          children: [
            Icon(icon, color: iconColor, size: w * 0.12),
            SizedBox(height: w * 0.02),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: w * 0.035, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: w * 0.03, color: Colors.grey[700]),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: KprimaryColor,
                minimumSize: Size(0, w * 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                onConfirm?.call();
              },
              child: Text(
                confirmText,
                style: TextStyle(color: Colors.white, fontSize: w * 0.035),
              ),
            ),
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

  bool _validateForm() {
    final s = S.of(context);
    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      setState(() => _nameError = s.nameRequired);
      isValid = false;
    } else {
      setState(() => _nameError = null);
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

    if (selectedImages.isEmpty) {
      setState(() => _imagesError = s.imageRequired);
      isValid = false;
    } else {
      setState(() => _imagesError = null);
    }

    return isValid;
  }

  void _updateLinkFieldsFromSocialLinks() {
    _linkInsta = null;
    _linkWhatsapp = null;
    _linkSnab = null;
    _linkFacebook = null;

    for (var link in socialLinks) {
      final url = link['url']?.toString() ?? '';
      if (url.isNotEmpty) _setLinkFieldByUrl(url);
    }
  }

  Future<void> _createNewAd() async {
    final s = S.of(context);
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('name', nameController.text.trim()));
      formData.fields.add(MapEntry('description', descriptionController.text.trim()));
      formData.fields.add(MapEntry('price', priceController.text));

      if (discountController.text.trim().isNotEmpty) {
        final discountValue = double.tryParse(discountController.text);
        formData.fields.add(MapEntry('discount', (discountValue ?? 0).toString()));
      } else {
        formData.fields.add(MapEntry('discount', '0'));
      }

      _updateLinkFieldsFromSocialLinks();
      if ((_linkInsta ?? '').isNotEmpty) formData.fields.add(MapEntry('linkInsta', _linkInsta!));
      if ((_linkWhatsapp ?? '').isNotEmpty) formData.fields.add(MapEntry('linkWhatsapp', _linkWhatsapp!));
      if ((_linkSnab ?? '').isNotEmpty) formData.fields.add(MapEntry('linkSnab', _linkSnab!));
      if ((_linkFacebook ?? '').isNotEmpty) formData.fields.add(MapEntry('linkFacebook', _linkFacebook!));

      for (int i = 0; i < selectedImages.length; i++) {
        final image = selectedImages[i];
        if (image is String) continue;
        try {
          final multipartFile = await _createMultipartFile(image, 'images[$i]');
          formData.files.add(MapEntry('images[$i]', multipartFile));
        } catch (_) {}
      }

      final response = await _dio.post(
        '/user/products/create-ad',
        data: formData,
        options: Options(
          headers: {'Accept': 'application/json'},
          receiveTimeout: const Duration(seconds: 90),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map &&
            (responseData['status'] == 200 ||
                responseData['status'] == 201 ||
                responseData['success'] == true)) {
          final newAd = {
            'name': nameController.text.trim(),
            'description': descriptionController.text.trim(),
            'price': double.tryParse(priceController.text) ?? 0.0,
            'discount': discountController.text.trim().isNotEmpty
                ? double.tryParse(discountController.text) ?? 0.0
                : 0.0,
            'linkInsta': _linkInsta,
            'linkWhatsapp': _linkWhatsapp,
            'linkSnab': _linkSnab,
            'linkFacebook': _linkFacebook,
          };
          try {
            context.read<MyPostsCubit>().addAd(newAd);
          } catch (_) {}

          _showResultDialog(
            title: s.postedSuccessfully,
            content: s.adPosted,
            icon: Icons.check_circle,
            iconColor: Colors.green,
            confirmText: s.ok,
            onConfirm: () => Navigator.pop(context, true),
          );
        } else {
          final errorMsg = responseData['message'] ?? responseData['error'] ?? s.somethingWentWrong;
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
      final errorData = e.response?.data;
      final errorMsg = errorData is Map
          ? (errorData['message'] ?? errorData['error'] ?? e.message)
          : e.message;
      _showResultDialog(
        title: s.error,
        content: errorMsg ?? s.somethingWentWrong,
        icon: Icons.error_outline,
        iconColor: const Color(0xffDD0C0C),
        confirmText: s.ok,
      );
    } catch (_) {
      _showResultDialog(
        title: s.error,
        content: s.somethingWentWrong,
        icon: Icons.error_outline,
        iconColor: const Color(0xffDD0C0C),
        confirmText: s.ok,
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
        MapEntry('description', descriptionController.text.trim()),
        MapEntry('price', priceController.text),
        MapEntry('discount', discountController.text.trim().isNotEmpty ? discountController.text : '0'),
        MapEntry('linkInsta', _apiNullableLink(_linkInsta).toString()),
        MapEntry('linkWhatsapp', _apiNullableLink(_linkWhatsapp).toString()),
        MapEntry('linkSnab', _apiNullableLink(_linkSnab).toString()),
        MapEntry('linkFacebook', _apiNullableLink(_linkFacebook).toString()),
      ]);

      for (int i = 0; i < selectedImages.length; i++) {
        final image = selectedImages[i];
        if (image is String) {
          formData.fields.add(MapEntry('existing_images[$i]', image));
          continue;
        }
        try {
          final multipartFile = await _createMultipartFile(image, 'images[$i]');
          formData.files.add(MapEntry('images[$i]', multipartFile));
        } catch (_) {}
      }

      final response = await _dio.post(
        '/user/products/update-ad/${widget.adId}',
        data: formData,
        options: Options(
          headers: {'Accept': 'application/json'},
          receiveTimeout: const Duration(seconds: 90),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map &&
            (responseData['status'] == 200 ||
                responseData['status'] == 201 ||
                responseData['success'] == true)) {
          final updatedAd = {
            'id': widget.adId,
            'name': nameController.text.trim(),
            'description': descriptionController.text.trim(),
            'price': double.tryParse(priceController.text) ?? 0.0,
            'discount': discountController.text.trim().isNotEmpty
                ? double.tryParse(discountController.text) ?? 0.0
                : 0.0,
            'linkInsta': (_linkInsta == null || _linkInsta!.isEmpty) ? null : _linkInsta,
            'linkWhatsapp': (_linkWhatsapp == null || _linkWhatsapp!.isEmpty) ? null : _linkWhatsapp,
            'linkSnab': (_linkSnab == null || _linkSnab!.isEmpty) ? null : _linkSnab,
            'linkFacebook': (_linkFacebook == null || _linkFacebook!.isEmpty) ? null : _linkFacebook,
          };
          try {
            context.read<MyPostsCubit>().updateAd(widget.adId!, updatedAd);
          } catch (_) {}

          _showResultDialog(
            title: s.editedSuccessfully,
            content: s.adUpdated,
            icon: Icons.gpp_good_outlined,
            iconColor: Colors.green,
            confirmText: s.ok,
            onConfirm: () => Navigator.pop(context, true),
          );
        } else {
          final errorMsg = responseData['message'] ?? responseData['error'] ?? s.somethingWentWrong;
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
      final errorData = e.response?.data;
      final errorMsg = errorData is Map
          ? (errorData['message'] ?? errorData['error'] ?? e.message)
          : e.message;
      _showResultDialog(
        title: s.error,
        content: errorMsg ?? s.somethingWentWrong,
        icon: Icons.error_outline,
        iconColor: const Color(0xffDD0C0C),
        confirmText: s.ok,
      );
    } catch (_) {
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
    if (_token == null || _token!.isEmpty) {
      final s = S.of(context);
      _showResultDialog(
        title: s.error,
        content:S.of(context).errorLoadingCategories,
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

  String _cleanNumberInput(String input) {
    String cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    final dotCount = cleaned.split('.').length - 1;
    if (dotCount > 1) {
      final parts = cleaned.split('.');
      cleaned = '${parts[0]}.${parts.sublist(1).join('')}';
    }
    return cleaned;
  }

  Widget customField(
      String label,
      TextEditingController controller, {
        String? hint,
        Widget? suffix,
        String? errorText,
        bool isDiscount = false,
      }) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final s = S.of(context);

    // تحديد نوع لوحة المفاتيح بناءً على نوع الحقل
    TextInputType keyboardType;
    if (isDiscount || label == s.price) {
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
    } else {
      keyboardType = TextInputType.text; // لحقل الاسم وغيره
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: w * 0.04,
          child: Text(
            label,
            style: TextStyle(
              color: KprimaryText,
              fontSize: w * 0.035,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: h * 0.01),
        Container(
          height: w * 0.12,
          decoration: BoxDecoration(
            color: const Color(0xffFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: errorText != null ? const Color(0xffDD0C0C) : const Color(0xffE9E9E9),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType, // استخدام نوع لوحة المفاتيح المحدد
              style: TextStyle(
                fontSize: w * 0.03,
                color: KprimaryText,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: hint ?? label,
                hintStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: w * 0.03,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                suffix: suffix,
                contentPadding: EdgeInsets.symmetric(vertical: w * 0.035, horizontal: 0),
              ),
              onChanged: (value) {
                if (isDiscount) {
                  final cleaned = _cleanNumberInput(value);
                  if (cleaned != value) {
                    controller.text = cleaned;
                    controller.selection = TextSelection.collapsed(offset: cleaned.length);
                  }
                }
                if (label == s.productName) {
                  setState(() => _nameError = null);
                } else if (label == s.price) {
                  setState(() => _priceError = null);
                } else if (label == s.discount) {
                  setState(() => _discountError = null);
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
              },
            ),
          ),
        ),
        Container(
          height: h * 0.02,
          margin: EdgeInsets.only(top: h * 0.005),
          child: errorText != null
              ? Text(
            errorText,
            style: TextStyle(color: const Color(0xffDD0C0C), fontSize: w * 0.03),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget descriptionField(String label, TextEditingController controller) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: w * 0.04,
          child: Text(
            label,
            style: TextStyle(
              color: KprimaryText,
              fontSize: w * 0.035,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: h * 0.01),
        Container(
          height: h * 0.15,
          decoration: BoxDecoration(
            color: const Color(0xffFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffE9E9E9), width: 1.5),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.03),
            child: TextField(
              controller: controller,
              maxLines: 5,
              keyboardType: TextInputType.text, // نص عادي مثل حقل الاسم
              style: TextStyle(
                fontSize: w * 0.03,
                color: KprimaryText,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: S.of(context).writeDescription,
                hintStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: w * 0.03,
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ImageProvider _imageProviderForItem(dynamic imgItem) {
    if (kIsWeb && imgItem is Uint8List) return MemoryImage(imgItem);
    if (imgItem is File) return FileImage(imgItem);
    if (imgItem is String) return NetworkImage(imgItem);
    return const AssetImage('Assets/fallback_image.png');
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: widget.isEditing ? s.editAd : s.addAd),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customField(s.productName, nameController, hint: s.productName, errorText: _nameError),
            SizedBox(height: h * 0.02),
            Row(
              children: [
                Expanded(
                  child: customField(s.price, priceController, hint: s.enterPrice, errorText: _priceError),
                ),
                SizedBox(width: w * 0.04),
                Expanded(
                  child: customField(
                    s.discount,
                    discountController,
                    hint: s.enterDiscount,
                    suffix: Text(
                      "%",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: w * 0.03),
                    ),
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
              style: TextStyle(color: KprimaryText, fontSize: w * 0.035, fontWeight: FontWeight.bold),
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

            if (socialLinks.length < 4)
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
                        keyboardType: TextInputType.text, // نص للروابط
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

                          // Update local api fields
                          if (platformName.contains('instagram')) {
                            _linkInsta = trimmedValue;
                          } else if (platformName.contains('whatsapp')) {
                            _linkWhatsapp = trimmedValue;
                          } else if (platformName.contains('snapchat')) {
                            _linkSnab = trimmedValue;
                          } else if (platformName.contains('facebook')) {
                            _linkFacebook = trimmedValue;
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
                        style: TextStyle(fontSize: w * 0.03, color: KprimaryText, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: s.enterSocialLink,
                          hintStyle: TextStyle(
                            fontSize: w * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: w * 0.035, horizontal: w * 0.035),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: h * 0.02,
                    margin: EdgeInsets.only(top: h * 0.005),
                    child: _socialLinkError
                        ? Text(
                      'Facebook, Instagram, WhatsApp, Snapchat',
                      style: TextStyle(color: const Color(0xffDD0C0C), fontSize: w * 0.03),
                    )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),

            SizedBox(height: h * 0.02),
            SizedBox(
              height: w * 0.04,
              child: Text(
                s.imagesMax10,
                style: TextStyle(color: KprimaryText, fontSize: w * 0.035, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: h * 0.01),

            Container(
              width: double.infinity,
              height: w * 0.36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _imagesError != null ? const Color(0xffDD0C0C) : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: selectedImages.isEmpty
                  ? GestureDetector(
                onTap: _pickImages,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: w * 0.05, color: Colors.grey),
                      SizedBox(height: h * 0.01),
                      Text(
                        s.addImages,
                        style: TextStyle(color: Colors.grey, fontSize: w * 0.03, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
                  : Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: w * 0.02,
                        mainAxisSpacing: w * 0.02,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: selectedImages.length + (selectedImages.length < 10 ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == selectedImages.length && selectedImages.length < 10) {
                          return GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Icon(Icons.add, color: Colors.grey, size: w * 0.05),
                              ),
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
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffDD0C0C)),
                                  child: Icon(Icons.close, color: Colors.white, size: w * 0.04),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: h * 0.02,
              margin: EdgeInsets.only(top: h * 0.005),
              child: _imagesError != null
                  ? Text(_imagesError!, style: TextStyle(color: const Color(0xffDD0C0C), fontSize: w * 0.03))
                  : const SizedBox.shrink(),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubmitting ? Colors.grey : KprimaryColor,
                  padding: EdgeInsets.symmetric(vertical: h * 0.012),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(w * 0.02)),
                ),
                child: _isSubmitting
                    ? SizedBox(
                  width: w * 0.05,
                  height: w * 0.05,
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : Text(
                  widget.isEditing ? s.saveChanges : s.postAd,
                  style: TextStyle(color: Colors.white, fontSize: w * 0.035, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: h * 0.03),

          ],
        ),
      ),
    );
  }
}
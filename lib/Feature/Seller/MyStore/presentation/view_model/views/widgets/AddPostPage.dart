import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../my_store_cubit.dart';

class AddPostPage extends StatefulWidget {
  final Map<String, dynamic>? adToEdit;
  final int? adIndex;
  const AddPostPage({super.key, this.adToEdit, this.adIndex});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  late String? selectedCurrency;
  late String? shippingOption;
  late bool installment;
  bool showQuantityWarning = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<dynamic> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.adToEdit != null) {
      _loadAdForEdit();
    } else {
      selectedCurrency = "EGP";
      shippingOption = "no";
      installment = false;
    }
  }

  void _loadAdForEdit() {
    final ad = widget.adToEdit!;
    nameController.text = ad['name'] ?? '';
    priceController.text = ad['price'].toString();
    discountController.text = ad['discount'].toString();
    quantityController.text = ad['quantity'].toString();
    descriptionController.text = ad['description'] ?? '';
    selectedCurrency = ad['currency'] ?? "EGP";
    shippingOption = ad['shippingOption'] ?? "no";
    installment = ad['installment'] == true;

    final imagesRaw = ad['images'] as List;
    selectedImages = imagesRaw.map((img) {
      if (kIsWeb) return img as Uint8List;
      return File(img as String);
    }).toList();

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
                    backgroundColor: KprimaryColor,
                    minimumSize: Size(0, w * 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    onConfirm?.call();
                  },
                  child: Text(confirmText,
                      style:
                      TextStyle(color: Colors.white, fontSize: w * 0.035)),
                ),
              ),
              if (onConfirm == null) ...[
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
                      style:
                      TextStyle(color: Colors.black87, fontSize: w * 0.035),
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

    final List<XFile>? picked = await _picker.pickMultiImage();
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
    setState(() => selectedImages.removeAt(index));
  }

  void _submitAd() {
    final s = S.of(context);
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        selectedImages.isEmpty ||
        quantityController.text.trim().isEmpty) {
      _showResultDialog(
        title: s.incompleteData,
        content: s.fillRequiredFields,
        icon: Icons.error_outline,
        iconColor: Colors.red,
        confirmText: s.ok,
      );
      return;
    }

    final newAd = {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'price': double.tryParse(priceController.text) ?? 0.0,
      'discount': double.tryParse(discountController.text) ?? 0.0,
      'currency': selectedCurrency,
      'images': selectedImages.map((img) {
        if (kIsWeb) return img as Uint8List;
        return (img as File).path;
      }).toList(),
      'shippingOption': shippingOption,
      'installment': installment,
      'quantity': int.tryParse(quantityController.text) ?? 1,
      'rating': widget.adToEdit?['rating'] ?? 0.0,
    };

    if (widget.adToEdit != null) {
      context.read<MyStoreCubit>().updateAd(widget.adIndex!, newAd);
      _showResultDialog(
        title: s.editedSuccessfully,
        content: s.adUpdated,
        icon: Icons.gpp_good_outlined,
        iconColor: KprimaryColor,
        confirmText: s.ok,
        onConfirm: () => Navigator.pop(context, true),
      );
    } else {
      context.read<MyStoreCubit>().addAd(newAd);
      _showResultDialog(
        title: s.postedSuccessfully,
        content: s.adPosted,
        icon: Icons.add_task_sharp,
        iconColor: KprimaryColor,
        confirmText: s.ok,
        onConfirm: () => Navigator.pop(context, true),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    InputDecoration fieldDecoration(String hint, {Widget? suffix}) {
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

    Widget customField(String label, TextEditingController controller,
        {TextInputType type = TextInputType.text,
          String? hint,
          Widget? suffix}) {
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
                border: Border.all(color: const Color(0xffE9E9E9)),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(
                    fontSize: w * 0.03,
                    color: KprimaryText,
                    fontWeight: FontWeight.bold),
                decoration: fieldDecoration(hint ?? label, suffix: suffix),
                keyboardType: type,
              ),
            ),
          ),
          SizedBox(height: h * 0.01),
        ],
      );
    }

    Widget optionButton(
        String text, String value, String selectedValue, VoidCallback onTap) {
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

    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(
        title: widget.adToEdit != null ? s.editAd : s.addAd,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: w * 0.05, vertical: h * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customField(s.productName, nameController),
            Row(
              children: [
                Expanded(
                    child: customField(s.quantity, quantityController,
                        type: TextInputType.number)),
                SizedBox(width: w * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.currency,
                          style: TextStyle(
                              color: KprimaryText,
                              fontSize: w * 0.035,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: h * 0.01),
                      Container(
                        width: double.infinity,
                        height: w * 0.12,
                        padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                        decoration: BoxDecoration(
                          color: const Color(0xffFAFAFA),
                          borderRadius: BorderRadius.circular(8),
                          border:
                          Border.all(color: const Color(0xffE9E9E9)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCurrency,
                            hint: Text(
                              s.chooseCurrency,
                              style: TextStyle(
                                  fontSize: w * 0.03,
                                  fontWeight: FontWeight.bold),
                            ),
                            dropdownColor: Colors.white,
                            items: ["EGP", "USD", "SAR", "AED"]
                                .map(
                                  (c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  c,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: w * 0.03),
                                ),
                              ),
                            )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedCurrency = val),
                          ),
                        ),
                      )
                    ],
                  ),
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
                        type: TextInputType.number)),
                SizedBox(width: w * 0.04),
                Expanded(
                  child: customField(
                    s.discount,
                    discountController,
                    type: TextInputType.number,
                    suffix: Text("%",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: w * 0.03)),
                  ),
                ),
              ],
            ),
            SizedBox(height: h * 0.02),
            Text(s.productDescription,
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
                controller: descriptionController,
                maxLines: 5,
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
                  border:
                  Border.all(color: Colors.grey.shade200, width: 1.5)),
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
                  final img = selectedImages[index];
                  return Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: kIsWeb
                                ? MemoryImage(img as Uint8List)
                                : FileImage(img as File)
                            as ImageProvider,
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
            SizedBox(height: h * 0.03),
            Text(s.shippingOptions,
                style: TextStyle(
                    color: KprimaryText,
                    fontSize: w * 0.035,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: h * 0.01),
            Row(
              children: [
                optionButton(s.none, "no", shippingOption!,
                        () => setState(() => shippingOption = "no")),
                optionButton(s.local, "local", shippingOption!,
                        () => setState(() => shippingOption = "local")),
                optionButton(s.localAndInternational, "both", shippingOption!,
                        () => setState(() => shippingOption = "both")),
              ],
            ),
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
                onPressed: _submitAd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KprimaryColor,
                  padding: EdgeInsets.symmetric(vertical: h * 0.024),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(w * 0.02)),
                ),
                child: Text(
                  widget.adToEdit != null ? s.saveChanges : s.postAd,
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
    );
  }
}

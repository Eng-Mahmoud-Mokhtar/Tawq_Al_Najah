import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tawqalnajah/Feature/Buyer/Product/presentation/view_model/cart_cubit.dart';
import 'package:tawqalnajah/Feature/Buyer/Product/presentation/view_model/favorite_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../Data/repository/ProductDetailsRepository.dart';
import '../../../Data/repository/RatingRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetails extends StatefulWidget {
  final int productId;
  final Map<String, dynamic> initialProductData;
  const ProductDetails({
    super.key,
    required this.productId,
    required this.initialProductData,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}
class _ProductDetailsState extends State<ProductDetails> {
  late Map<String, dynamic> _productData;
  Map<String, dynamic> _sellerData = {};
  bool _isLoading = true;
  int _currentPage = 0;
  int _selectedRating = 0;
  bool _ratingSubmitted = false;
  List<dynamic> _relatedProducts = [];
  final ProductDetailsRepository _repository = ProductDetailsRepository();
  final RatingRepository _ratingRepository = RatingRepository();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _isAddingToCart = false;
  final Map<int, bool> _relatedCartLoading = {};
  final Map<int, bool> _relatedFavoriteLoading = {};
  @override
  void initState() {
    super.initState();
    _productData = Map<String, dynamic>.from(widget.initialProductData);
    _loadSavedRating();
    _loadProductDetails();
  }

  Future<void> _loadSavedRating() async {
    try {
      final savedRating = await _storage.read(key: 'rating_${widget.productId}');
      if (savedRating != null) {
        setState(() {
          _selectedRating = int.parse(savedRating);
          _ratingSubmitted = true;
        });
      }
    } catch (e) {
      print('Error loading saved rating: $e');
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
        _sellerData = (data['sallerDetails'] is Map) ? Map<String, dynamic>.from(data['sallerDetails']) : {};
        _relatedProducts = data['products'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading product details: $e');
      setState(() {
        _isLoading = false;
        _sellerData = {};
        _relatedProducts = [];
      });
    }
  }
  Future<void> _handleAddToCart() async {
    if (_isAddingToCart) return;
    final cartCubit = context.read<CartCubit>();
    final currentProductSellerId = _sellerData['id'] ?? _productData['saller_id'];
    if (cartCubit.state.currentSellerId != null &&
        cartCubit.state.currentSellerId != currentProductSellerId) {
      print('❌ Cannot add product: Different seller');
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      await cartCubit.toggleCartWithApi(widget.productId, _productData);
    } catch (e) {
      print('❌ Cart Operation ERROR: $e');
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }
  Future<void> _toggleFavorite() async {
    final favoriteCubit = context.read<FavoriteCubit>();
    await favoriteCubit.toggleFavoriteWithApi(widget.productId);
  }
  Future<void> _toggleRelatedFavorite(int productId) async {
    if (_relatedFavoriteLoading[productId] == true) return;

    setState(() {
      _relatedFavoriteLoading[productId] = true;
    });

    try {
      final favoriteCubit = context.read<FavoriteCubit>();
      await favoriteCubit.toggleFavoriteWithApi(productId);
    } catch (e) {
      print('❌ Related Favorite Operation ERROR: $e');
    } finally {
      setState(() {
        _relatedFavoriteLoading[productId] = false;
      });
    }
  }
  Future<void> _toggleRelatedCart(int productId) async {
    if (_relatedCartLoading[productId] == true) return;
    final relatedProduct = _relatedProducts.firstWhere(
          (product) => product['id'] == productId,
      orElse: () => {},
    );
    if (relatedProduct.isEmpty) {
      print('❌ Related product data not found for ID: $productId');
      return;
    }

    final cartCubit = context.read<CartCubit>();
    final relatedProductSellerId = relatedProduct['saller_id'];
    final isAdded = cartCubit.state.cartIds.contains(productId);
    if (!isAdded && cartCubit.state.currentSellerId != null && cartCubit.state.currentSellerId != relatedProductSellerId) {
      print('❌ Cannot add related product: Different seller');
      return;
    }

    setState(() {
      _relatedCartLoading[productId] = true;
    });

    try {
      await cartCubit.toggleCartWithApi(productId, relatedProduct);
    } catch (e) {
      print('❌ Related Cart Operation ERROR: $e');
    } finally {
      setState(() {
        _relatedCartLoading[productId] = false;
      });
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
    } catch (e) {
      print('Error submitting rating: $e');
    }
  }

  Future<void> _launchSocialLink(String? rawLink) async {
    if (rawLink == null || rawLink.trim().isEmpty) return;
    try {
      String link = rawLink.trim();
      if (!link.startsWith('http://') && !link.startsWith('https://')) {
        link = 'https://$link';
      }
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching social link: $e');
    }
  }

  void _shareProduct() {
    final productName = _productData['name'] ?? '';
    final productDescription = _productData['description'] ?? '';
    final price = _productData['priceAfterDiscount'] ?? _productData['price'] ?? 0;
    final currency = _productData['currency_type'] ?? 'ريال';

    Share.share(
      '$productName\n$productDescription\nالسعر: $price $currency',
      subject: productName,
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
            Text(S.of(context).yourProductRating,
                style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
              textAlign: Localizations.localeOf(context).languageCode == 'ar'
                  ? TextAlign.right
                  : TextAlign.left,),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: _ratingSubmitted ? null : () => _submitRating(i + 1),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                    child: Icon(
                        Icons.star,
                        color: i < _selectedRating ? const Color(0xffFFD900) : Colors.grey.shade400,
                        size: screenWidth * 0.07
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
                  backgroundImage: (_sellerData['image'] != null && _sellerData['image'].toString().isNotEmpty)
                      ? NetworkImage(_sellerData['image'])
                      : const AssetImage('Assets/fallback_image.png') as ImageProvider,
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_sellerData['name'] ?? S.of(context).unknown,
                          style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold)),
                      if (_sellerData['address'] != null && _sellerData['address'].toString().isNotEmpty)
                        Text(_sellerData['address'],
                            style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (_sellerData['linkWhatsapp'] != null && _sellerData['linkWhatsapp'].toString().isNotEmpty)
                      _buildCircleIcon('Assets/whatsapp.png', screenWidth,
                          onTap: () => _launchSocialLink("https://wa.me/${_sellerData['linkWhatsapp']}")),
                    if (_sellerData['linkFacebook'] != null && _sellerData['linkFacebook'].toString().isNotEmpty)
                      _buildCircleIcon('Assets/Facebook.png', screenWidth,
                          onTap: () => _launchSocialLink(_sellerData['linkFacebook'])),
                    if (_sellerData['linkInsta'] != null && _sellerData['linkInsta'].toString().isNotEmpty)
                      _buildCircleIcon('Assets/instagram.png', screenWidth,
                          onTap: () => _launchSocialLink(_sellerData['linkInsta'])),
                    if (_sellerData['linkSnab'] != null && _sellerData['linkSnab'].toString().isNotEmpty)
                      _buildCircleIcon('Assets/logo.png', screenWidth,
                          backgroundColor: Colors.yellow,
                          onTap: () => _launchSocialLink(_sellerData['linkSnab'])),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Divider(color: Colors.grey.shade200, thickness: 2),
            SizedBox(height: screenHeight * 0.01),
            Column(
              crossAxisAlignment: Directionality.of(context) == TextDirection.rtl
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenHeight * 0.01),
                  child: Text(
                    S.of(context).yourProductRating,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: Directionality.of(context) == TextDirection.rtl
                        ? TextAlign.right
                        : TextAlign.left,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: _ratingSubmitted ? null : () => _submitRating(i + 1),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                        child: Icon(
                          Icons.star,
                          color: i < _selectedRating ? const Color(0xffFFD900) : Colors.grey.shade400,
                          size: screenWidth * 0.07,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            )
          ],
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts(double screenWidth, double screenHeight) {
    if (_relatedProducts.isEmpty) return const SizedBox();

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        return BlocBuilder<FavoriteCubit, Set<int>>(
          builder: (context, favoriteState) {
            return Column(
              crossAxisAlignment: Localizations.localeOf(context).languageCode == 'ar'
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                SizedBox(height: screenHeight * 0.01),
                Text(S.of(context).suggestions,
                    style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),),
                SizedBox(height: screenHeight * 0.01),
                SizedBox(
                  height: screenHeight * 0.37,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                    itemCount: _relatedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _relatedProducts[index];
                      final productId = product['id'];
                      final images = (product['image'] as List?)?.cast<String>() ?? [];
                      final price = product['priceAfterDiscount'] ?? product['price'] ?? 0;
                      final currency = product['currency_type'] ?? 'ريال';
                      final cardHeight = screenHeight * 0.35;
                      final cardWidth = cardHeight * 0.65;
                      final isFavorite = favoriteState.contains(productId);
                      final isInCart = cartState.cartIds.contains(productId);
                      final isCartLoading = _relatedCartLoading[productId] == true;
                      final isFavoriteLoading = _relatedFavoriteLoading[productId] == true;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetails(
                                productId: productId,
                                initialProductData: product,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: cardWidth,
                          margin: EdgeInsets.only(left: screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(cardWidth * 0.05),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(cardWidth * 0.05),
                                  ),
                                  child: Stack(
                                    children: [
                                      images.isNotEmpty
                                          ? Image.network(
                                        images.first,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (context, error, stackTrace) {
                                          return _buildImageErrorPlaceholder(cardWidth, cardHeight);
                                        },
                                      )
                                          : _buildImageErrorPlaceholder(cardWidth, cardHeight),
                                      Positioned(
                                        top: cardWidth * 0.04,
                                        left: cardWidth * 0.04,
                                        child: GestureDetector(
                                          onTap: () {
                                            _toggleRelatedFavorite(productId);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(cardWidth * 0.035),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black.withOpacity(0.6),
                                            ),
                                            child: isFavoriteLoading
                                                ? SizedBox(
                                              width: cardWidth * 0.06,
                                              height: cardWidth * 0.06,
                                              child: const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                                : Icon(
                                              isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: isFavorite ? const Color(0xffFF580E) : Colors.white,
                                              size: cardWidth * 0.08,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(cardWidth * 0.045),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                product['name'] ?? S.of(context).none,
                                                style: TextStyle(
                                                  fontSize: cardHeight * 0.04,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textDirection: TextDirection.rtl,
                                              ),
                                            ),
                                            SizedBox(height: cardHeight * 0.012),
                                            Container(
                                              width: double.infinity,
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                product['description']?.toString() ?? S.of(context).noData,
                                                style: TextStyle(
                                                  fontSize: cardHeight * 0.035,
                                                  color: Colors.grey[700],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textDirection: TextDirection.rtl,
                                              ),
                                            ),
                                            SizedBox(height: cardHeight * 0.012),
                                            Container(
                                              width: double.infinity,
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                "$price $currency",
                                                style: TextStyle(
                                                  fontSize: cardHeight * 0.04,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xffFF580E),
                                                ),
                                                textDirection: TextDirection.rtl,
                                              ),
                                            ),
                                            const Spacer(),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                onPressed: isCartLoading ? null : () => _toggleRelatedCart(productId),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isInCart ? Colors.grey : const Color(0xffFF580E),
                                                  minimumSize: Size(double.infinity, cardHeight * 0.13),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(cardWidth * 0.12),
                                                  ),
                                                ),
                                                child: isCartLoading
                                                    ? SizedBox(
                                                  width: cardHeight * 0.03,
                                                  height: cardHeight * 0.03,
                                                  child: const CircularProgressIndicator(
                                                    color: Colors.white,
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                                    : Text(
                                                  isInCart ? S.of(context).addedToCart : S.of(context).AddtoCart,
                                                  style: TextStyle(
                                                    fontSize: cardHeight * 0.04,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textDirection: TextDirection.rtl,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildImageErrorPlaceholder(double cardWidth, double cardHeight) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade400,
            size: cardWidth * 0.15,
          ),
        ],
      ),
    );
  }

  Widget buildShippingCard(double screenWidth, double screenHeight) {
    final isDeliverable = _productData['is_deliverd'] == 1;
    final hasInstallment = _productData['is_installment'] == 1;

    String shippingText = isDeliverable ? "توصيل محلي" : "لا يوجد توصيل";
    String installmentText = hasInstallment ? "تقسيط متاح" : "لا يوجد تقسيط";

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
      height: screenWidth * 0.12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
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
    final images = (_productData['image'] as List?)?.cast<String>() ?? [];

    return BlocBuilder<FavoriteCubit, Set<int>>(
      builder: (context, favoriteState) {
        final isFavorite = favoriteState.contains(widget.productId);

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
                  itemBuilder: (_, i) => Image.network(
                    images[i],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildMainImageErrorPlaceholder(screenWidth, screenHeight);
                    },
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
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _shareProduct,
                      child: Container(
                        width: screenWidth * 0.1,
                        height: screenWidth * 0.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Icon(
                          Icons.ios_share_outlined,
                          color: Colors.white,
                          size: screenWidth * 0.05,
                        ),
                      ),
                    ),
                    SizedBox(width:screenWidth * 0.02),
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        width: screenWidth * 0.1,
                        height: screenWidth * 0.1,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? const Color(0xffFF580E) : Colors.white,
                          size: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildMainImageErrorPlaceholder(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade400,
            size: screenWidth * 0.1,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xfffafafa),
        body: Center(child: CircularProgressIndicator(color: const Color(0xffFF580E))),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final price = _productData['price'] ?? 0;
    final priceAfter = _productData['priceAfterDiscount'] ?? price;
    final discount = _productData['discount'] ?? 0;
    final currency = _productData['currency_type'] ?? 'ريال';
    final avgRate = _productData['avg_rate']?.toStringAsFixed(1) ?? '0.0';

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final isInCart = cartState.cartIds.contains(widget.productId);

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
                                    _productData['name'] ?? '',
                                    style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  avgRate,
                                  style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: screenWidth * 0.01),
                                Icon(Icons.star, color: const Color(0xffFFD900), size: screenWidth * 0.07),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              _productData['description'] ?? S.of(context).noDescription,
                              style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.grey[700]),
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
                            _buildRelatedProducts(screenWidth, screenHeight),
                            SizedBox(height: screenHeight * 0.1),
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
                  child: ElevatedButton(
                    onPressed: _isAddingToCart ? null : _handleAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInCart ? Colors.grey : const Color(0xffFF580E),
                      minimumSize: Size(double.infinity, screenHeight * 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      elevation: 3,
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
                      isInCart ? S.of(context).addedToCart : S.of(context).AddtoCart,
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
          ),
        );
      },
    );
  }
}

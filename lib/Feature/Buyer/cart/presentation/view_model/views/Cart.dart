import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../../Core/Widgets/AppBar.dart';
import '../../../../../../Core/Widgets/buildImageError.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../Home/presentation/view_model/views/HomeStructure.dart';
import '../../../../Product/presentation/view_model/cart_cubit.dart';
import '../UserCartBloc.dart';
import '../UserCartState.dart';
import 'BuyOrder.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserCartBloc()),
        BlocProvider.value(value: context.read<CartCubit>()),
      ],
      child: const _CartPageContent(),
    );
  }
}

class _CartPageContent extends StatefulWidget {
  const _CartPageContent({super.key});

  @override
  State<_CartPageContent> createState() => __CartPageContentState();
}

class __CartPageContentState extends State<_CartPageContent> {
  Map<String, dynamic>? _apiCartData;
  bool _isInitialLoading = true;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late Dio _dio;
  final Map<String, int> _previousQuantities = {};
  bool _shouldAutoRefresh = false;
  late SharedPreferences _prefs;
  bool _isSyncingCartCubit = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://toknagah.viking-iceland.online',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => true,
      ),
    );

    _fetchCartDataFromAPI(showLoading: true);
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shouldAutoRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchCartDataFromAPI(showLoading: false);
        _shouldAutoRefresh = false;
      });
    }
  }

  Future<void> _fetchCartDataFromAPI({bool showLoading = true}) async {
    if (!mounted) return;

    final cartBloc = context.read<UserCartBloc>();

    if (showLoading) {
      setState(() => _isInitialLoading = true);
      cartBloc.setLoading(true);
    }

    try {
      final token = await _storage.read(key: 'user_token');
      if (token == null) {
        if (showLoading) setState(() => _isInitialLoading = false);
        cartBloc.setLoading(false);
        cartBloc.setErrorMessage(S.of(context).pleaseLoginFirst);
        return;
      }

      final response = await _dio.get(
        '/api/user/show-my-cart',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['status'] == 200) {
          setState(() {
            _apiCartData = responseData['data'];
            if (showLoading) _isInitialLoading = false;
          });

          _updateBlocWithApiData();
          await _syncCartCubit();
        } else {
          if (showLoading) setState(() => _isInitialLoading = false);
          cartBloc.setLoading(false);
        }
      } else {
        if (showLoading) setState(() => _isInitialLoading = false);
        cartBloc.setLoading(false);
      }
    } catch (e) {
      if (showLoading) setState(() => _isInitialLoading = false);
      cartBloc.setLoading(false);
    }
  }

  void _updateBlocWithApiData() {
    if (_apiCartData == null || !mounted) return;

    final cartBloc = context.read<UserCartBloc>();
    final List<Map<String, dynamic>> blocItems = [];

    if (_apiCartData!['items'] != null) {
      final items = _apiCartData!['items'] as List<dynamic>;

      for (var item in items) {
        try {
          final productPrice =
              double.tryParse(item['product_price']?.toString() ?? '0') ?? 0.0;
          final priceAfterDiscount =
          item['product_price_after_discount'] != null
              ? double.tryParse(item['product_price_after_discount'].toString())
              : null;

          blocItems.add({
            'api_data': item,
            'ad': {
              'id': item['product_id']?.toString() ?? '',
              'item_id': item['id_item']?.toString() ?? '',
              'name': item['product_name'] ?? S.of(context).unknown,
              'description':
              item['product_description'] ?? S.of(context).noDescription,
              'price': productPrice,
              'price_after_discount': priceAfterDiscount,
              'currency': item['product_currency'] ?? S.of(context).SYP, // استخدم SYP كافتراضي
              'images': item['image'] != null ? [item['image']] : [],
            },
            'quantity': item['quantity'] ?? 1,
          });
        } catch (e) {}
      }
    }

    double subtotal =
        double.tryParse(_apiCartData!['price']?.toString() ?? '0') ?? 0.0;
    double shipping =
        double.tryParse(_apiCartData!['fees']?.toString() ?? '0') ?? 0.0;
    double total =
        double.tryParse(_apiCartData!['total']?.toString() ?? '0') ?? 0.0;

    // استخراج العملة من البيانات أو استخدام SYP كافتراضي
    String currency;
    if (_apiCartData!['currency'] != null && _apiCartData!['currency'].toString().isNotEmpty) {
      currency = _apiCartData!['currency'].toString();
    } else if (_apiCartData!['items'] != null && (_apiCartData!['items'] as List).isNotEmpty) {
      // إذا لم توجد عملة في البيانات العامة، استخرج من أول منتج
      final firstItem = (_apiCartData!['items'] as List).first;
      currency = firstItem['product_currency']?.toString() ?? S.of(context).SYP;
    } else {
      currency = S.of(context).SYP;
    }

    int cartId = int.tryParse(_apiCartData!['cart_id']?.toString() ?? '0') ?? 0;

    if (shipping < 0) shipping = 0.0;

    cartBloc.updateCartData(
      items: blocItems,
      subtotal: subtotal,
      shipping: shipping,
      total: total,
      currency: currency, // استخدم العملة المستخرجة
      cartId: cartId,
    );
  }

  Future<void> _syncCartCubit() async {
    if (!mounted || _isSyncingCartCubit) return;

    _isSyncingCartCubit = true;

    try {
      final cartBloc = context.read<UserCartBloc>();
      final cartCubit = context.read<CartCubit>();

      final Set<int> currentProductIds = cartBloc.getProductIds();

      await _prefs.setStringList(
        'cart_added_ids',
        currentProductIds.map((e) => e.toString()).toList(),
      );

      if (cartCubit.isClosed) return;

      int? sellerId;
      if (cartBloc.state.cartItems.isNotEmpty) {
        final sellerIdStr = cartBloc
            .state
            .cartItems
            .first['api_data']?['saller_id']
            ?.toString();
        sellerId = int.tryParse(sellerIdStr ?? '');
      }

      await cartCubit.syncWithServerCart(currentProductIds, sellerId: sellerId);
    } catch (e) {
    } finally {
      _isSyncingCartCubit = false;
    }
  }

  Future<void> _removeFromCartCubit(int productId) async {
    final cartCubit = context.read<CartCubit>();

    if (cartCubit.isClosed) return;

    final newCartIds = Set<int>.from(cartCubit.state.cartIds);
    newCartIds.remove(productId);

    await _prefs.setStringList(
      'cart_added_ids',
      newCartIds.map((e) => e.toString()).toList(),
    );

    final newSellerId = newCartIds.isEmpty
        ? null
        : cartCubit.state.currentSellerId;

    await cartCubit.syncWithServerCart(newCartIds, sellerId: newSellerId);
  }

  Future<void> _updateCartItemQuantity(
      int itemId,
      int newQuantity, {
        bool isIncrement = true,
      }) async {
    if (!mounted) return;

    final cartBloc = context.read<UserCartBloc>();

    cartBloc.setUpdatingItemId(itemId.toString());

    int currentQuantity = 0;
    for (var item in cartBloc.state.cartItems) {
      if (item['api_data']?['id_item'].toString() == itemId.toString()) {
        currentQuantity = item['quantity'] as int;
        break;
      }
    }

    _previousQuantities[itemId.toString()] = currentQuantity;
    cartBloc.updateItemQuantity(itemId.toString(), newQuantity);

    try {
      final token = await _storage.read(key: 'user_token');
      if (token == null) {
        cartBloc.setUpdatingItemId(null);
        return;
      }

      final Map<String, dynamic> requestData = {
        'item_id': itemId.toString(),
        'quantity': isIncrement ? 1 : -1,
      };

      final response = await _dio.post(
        '/api/user/change-cart',
        data: FormData.fromMap(requestData),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      cartBloc.setUpdatingItemId(null);
      final responseData = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == 200) {
          _fetchCartDataFromAPI(showLoading: false);
        } else if (responseData['status'] == 400) {
          final errorMessage =
              responseData['data']?.toString() ??
                  responseData['message']?.toString() ??
                  '';

          if (errorMessage.contains('out of stock') ||
              errorMessage.contains('Stock')) {
            final previousQty = _previousQuantities[itemId.toString()];
            if (previousQty != null) {
              cartBloc.restoreItem(itemId.toString(), previousQty);
            }

            if (mounted) _showStockErrorMessage();
          } else {
            _fetchCartDataFromAPI(showLoading: false);
          }
        } else {
          _fetchCartDataFromAPI(showLoading: false);
        }
      } else if (response.statusCode == 422) {
        _fetchCartDataFromAPI(showLoading: false);
      } else {
        final previousQty = _previousQuantities[itemId.toString()];
        if (previousQty != null) {
          cartBloc.restoreItem(itemId.toString(), previousQty);
        }
        _fetchCartDataFromAPI(showLoading: false);
      }
    } on DioException catch (e) {
      cartBloc.setUpdatingItemId(null);
      final previousQty = _previousQuantities[itemId.toString()];
      if (previousQty != null) {
        cartBloc.restoreItem(itemId.toString(), previousQty);
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        _fetchCartDataFromAPI(showLoading: false);
      } else {
        _fetchCartDataFromAPI(showLoading: false);
      }
    } catch (e) {
      cartBloc.setUpdatingItemId(null);
      final previousQty = _previousQuantities[itemId.toString()];
      if (previousQty != null) {
        cartBloc.restoreItem(itemId.toString(), previousQty);
      }
      _fetchCartDataFromAPI(showLoading: false);
    }
  }

  Future<void> _removeCartItem(int itemId, int productId) async {
    if (!mounted) return;

    final cartBloc = context.read<UserCartBloc>();

    cartBloc.setDeletingItem(true);
    cartBloc.setUpdatingItemId(itemId.toString());

    try {
      final token = await _storage.read(key: 'user_token');
      if (token == null) {
        cartBloc.setDeletingItem(false);
        cartBloc.setUpdatingItemId(null);
        return;
      }

      final response = await _dio.delete(
        '/api/user/remove-from-cart/$itemId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      cartBloc.setDeletingItem(false);
      cartBloc.setUpdatingItemId(null);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['status'] == 200) {
          cartBloc.removeItem(itemId.toString(), cartBloc.state.shipping);
          await _removeFromCartCubit(productId);
          _fetchCartDataFromAPI(showLoading: false);
        }
      }
    } on DioException catch (e) {
      cartBloc.setDeletingItem(false);
      cartBloc.setUpdatingItemId(null);
    } catch (e) {
      cartBloc.setDeletingItem(false);
      cartBloc.setUpdatingItemId(null);
    }
  }

  void _showStockErrorMessage() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          S.of(context).attention,
          style: TextStyle(color: KprimaryText, fontWeight: FontWeight.bold),
        ),
        content: Text(
          S.of(context).outOfStock,
          style: TextStyle(color: KprimaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).ok,
              style: TextStyle(color: KprimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          S.of(context).error,
          style: TextStyle(color: KprimaryText, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: TextStyle(color: KprimaryText)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).ok,
              style: TextStyle(color: KprimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        return BlocBuilder<UserCartBloc, UserCartState>(
          builder: (context, state) {
            if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showErrorMessage(state.errorMessage!);
                context.read<UserCartBloc>().setErrorMessage(null);
              });
            }

            if (!_isInitialLoading &&
                cartState.cartIds.length > state.cartItems.length &&
                !_isSyncingCartCubit) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) _fetchCartDataFromAPI(showLoading: false);
                });
              });
            }

            if (_isInitialLoading || state.isLoading || cartState.isLoading) {
              return Scaffold(
                backgroundColor: const Color(0xfffafafa),
                appBar: AppBarWithBottomB(title: S.of(context).Cart),
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    children: [
                      ...List.generate(
                        3,
                            (index) =>
                            _buildShimmerCartItem(screenWidth, screenHeight),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildShimmerCartSummary(screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.02),
                      _buildShimmerCheckoutButton(screenWidth, screenHeight),
                    ],
                  ),
                ),
              );
            }

            if (state.cartItems.isEmpty) {
              return Scaffold(
                backgroundColor: const Color(0xfffafafa),
                appBar: AppBarWithBottomB(title: S.of(context).Cart),
                body: Center(
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "Assets/empty-cart 1.png",
                          width: screenWidth * 0.5,
                          height: screenWidth * 0.5,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Text(
                          S.of(context).emptyCart,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.bold,
                            color: KprimaryText,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          S.of(context).browseAndShopNow,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (mounted) {
                                context.read<BottomNavBCubit>().setIndex(0);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KprimaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: SizedBox(
                              height: screenWidth * 0.12,
                              child: Center(
                                child: Text(
                                  S.of(context).browseProducts,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.03,
                                    fontWeight: FontWeight.bold,
                                    color: SecoundColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Scaffold(
              backgroundColor: const Color(0xfffafafa),
              appBar: AppBarWithBottomB(title: S.of(context).Cart),
              body: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          _fetchCartDataFromAPI(showLoading: false),
                      color: KprimaryColor,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            ...state.cartItems.map((cartItem) {
                              final itemId = cartItem['api_data']?['id_item'];
                              final productId =
                              cartItem['api_data']?['product_id'];
                              final currentQuantity =
                              cartItem['quantity'] as int;
                              final isUpdating =
                                  state.updatingItemId == itemId.toString();

                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.005,
                                ),
                                child: Stack(
                                  children: [
                                    Slidable(
                                      key: ValueKey(
                                        '${itemId}_${currentQuantity}_$isUpdating',
                                      ),
                                      endActionPane: ActionPane(
                                        motion: const DrawerMotion(),
                                        extentRatio: 0.25,
                                        children: [
                                          SlidableAction(
                                            onPressed: (_) {
                                              if (itemId != null &&
                                                  productId != null &&
                                                  !state.isDeletingItem) {
                                                _showDeleteConfirmationDialog(
                                                  context,
                                                  itemId,
                                                  productId,
                                                );
                                              }
                                            },
                                            backgroundColor:
                                            state.isDeletingItem
                                                ? Colors.grey
                                                : Colors.red,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: S.of(context).delete,
                                            borderRadius: BorderRadius.circular(
                                              screenWidth * 0.03,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: _CartItemCard(
                                        cartItem: cartItem,
                                        screenWidth: screenWidth,
                                        screenHeight: screenHeight,
                                        currentQuantity: currentQuantity,
                                        isUpdating: isUpdating,
                                        onDecrement: () {
                                          if (itemId != null &&
                                              currentQuantity > 1 &&
                                              !isUpdating &&
                                              !state.isDeletingItem) {
                                            _updateCartItemQuantity(
                                              itemId,
                                              currentQuantity - 1,
                                              isIncrement: false,
                                            );
                                          }
                                        },
                                        onIncrement: () {
                                          if (itemId != null &&
                                              !isUpdating &&
                                              !state.isDeletingItem) {
                                            _updateCartItemQuantity(
                                              itemId,
                                              currentQuantity + 1,
                                              isIncrement: true,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    if (state.isDeletingItem &&
                                        state.updatingItemId ==
                                            itemId.toString())
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.white.withOpacity(0.8),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: KprimaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isDeletingItem
                            ? null
                            : () {
                          _navigateToCheckout(context, state.cartId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: state.isDeletingItem
                              ? Colors.grey
                              : KprimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.03,
                          ),
                        ),
                        child: Text(
                          S.of(context).Checkout,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                            color: SecoundColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.05),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerCartItem(double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: screenWidth * 0.25,
                      height: screenWidth * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: screenWidth * 0.4,
                            height: screenHeight * 0.025,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: screenWidth * 0.5,
                            height: screenHeight * 0.02,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: screenWidth * 0.3,
                            height: screenHeight * 0.02,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Row(
                            children: [
                              Container(
                                width: screenWidth * 0.25,
                                height: screenHeight * 0.02,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: screenWidth * 0.2,
                                height: screenWidth * 0.07,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.015,
                                  ),
                                  color: Colors.white,
                                ),
                              ),
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
        ),
      ),
    );
  }

  Widget _buildShimmerCartSummary(double screenWidth, double screenHeight) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.01),
            Container(
              width: double.infinity,
              height: screenHeight * 0.02,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Container(
              width: double.infinity,
              height: screenHeight * 0.02,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey[300],
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: double.infinity,
              height: screenHeight * 0.025,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCheckoutButton(double screenWidth, double screenHeight) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        color: Colors.white,
        child: Container(
          width: double.infinity,
          height: screenHeight * 0.06,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context,
      int itemId,
      int productId,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          S.of(context).deleteConfirmation,
          style: TextStyle(color: KprimaryText, fontWeight: FontWeight.bold),
        ),
        content: Text(
          S.of(context).deleteItemConfirmation,
          style: TextStyle(color: KprimaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: KprimaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeCartItem(itemId, productId);
            },
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCheckout(BuildContext context, int cartId) {
    final state = context.read<UserCartBloc>().state;

    if (state.cartItems.isEmpty) {
      _showErrorMessage(S.of(context).cartIsEmpty);
      return;
    }
    try {
      final checkoutData = {
        'items': state.cartItems,
        'subtotal': state.subtotal,
        'shippingCost': state.shipping,
        'total': state.total,
        'currency': state.currency,
        'cart_id': cartId,
        'api_data': _apiCartData,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuyOrder(productData: checkoutData),
        ),
      ).then((value) {
        _fetchCartDataFromAPI(showLoading: false);
      });
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              S.of(context).error,
              style: TextStyle(
                color: KprimaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              S.of(context).errorNavigatingToCheckout,
              style: TextStyle(color: KprimaryText),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  S.of(context).ok,
                  style: TextStyle(color: KprimaryColor),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}

class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> cartItem;
  final double screenWidth;
  final double screenHeight;
  final int currentQuantity;
  final bool isUpdating;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CartItemCard({
    required this.cartItem,
    required this.screenWidth,
    required this.screenHeight,
    required this.currentQuantity,
    required this.isUpdating,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final ad = cartItem['ad'] as Map<String, dynamic>;
    final currentPrice = ad['price_after_discount'] ?? ad['price'];
    final originalPrice = ad['price_after_discount'] != null
        ? ad['price']
        : null;
    final currency = ad['currency'] ?? S.of(context).SYP; // استخدام العملة من الـ API
    final hasImage =
        ad['images'] != null &&
            ad['images'].isNotEmpty &&
            ad['images'][0] != null &&
            ad['images'][0].isNotEmpty;

    return Stack(
      children: [
        if (isUpdating)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: CircularProgressIndicator(color: KprimaryColor),
              ),
            ),
          ),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: screenWidth * 0.25,
                        height: screenWidth * 0.25,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                          color: Colors.grey[200],
                        ),
                        child: hasImage
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.02,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: ad['images'][0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(color: Colors.white),
                                ),
                            errorWidget: (context, url, error) =>
                                buildImageErrorPlaceholder(
                                  context,
                                  screenWidth * 0.25,
                                  screenWidth * 0.25,
                                ),
                          ),
                        )
                            : Center(
                          child: Icon(
                            Icons.shopping_cart,
                            size: screenWidth * 0.1,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.04),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              ad['name'] ?? S.of(context).unknown,
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              ad['description'] ?? S.of(context).noDescription,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (originalPrice != null)
                                  Text(
                                    "${originalPrice.toStringAsFixed(2)} $currency", // استخدام العملة
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${currentPrice.toStringAsFixed(2)} $currency", // استخدام العملة
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xffFF580E),
                                      ),
                                    ),
                                    if (!isUpdating)
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: currentQuantity > 1
                                                ? onDecrement
                                                : null,
                                            child: Container(
                                              width: screenWidth * 0.07,
                                              height: screenWidth * 0.07,
                                              decoration: BoxDecoration(
                                                color: currentQuantity > 1
                                                    ? Colors.grey[200]
                                                    : Colors.grey[100],
                                                borderRadius:
                                                BorderRadius.circular(
                                                  screenWidth * 0.015,
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.remove,
                                                  color: currentQuantity > 1
                                                      ? Colors.black
                                                      : Colors.grey,
                                                  size: screenWidth * 0.035,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.015),
                                          Container(
                                            constraints: BoxConstraints(
                                              minWidth: screenWidth * 0.07,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.02,
                                            ),
                                            child: Text(
                                              "$currentQuantity",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.015),
                                          GestureDetector(
                                            onTap: onIncrement,
                                            child: Container(
                                              width: screenWidth * 0.07,
                                              height: screenWidth * 0.07,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                BorderRadius.circular(
                                                  screenWidth * 0.015,
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.black,
                                                  size: screenWidth * 0.035,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
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
            ),
          ),
        ),
      ],
    );
  }
}

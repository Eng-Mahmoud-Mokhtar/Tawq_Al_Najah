import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shimmer/shimmer.dart' as shimmer_package;
import 'package:tawqalnajah/Core/Widgets/AppBar.dart';
import 'package:tawqalnajah/Feature/Seller/Orders/presentation/view_model/views/widgets/emptyState.dart';
import '../../../../../../Core/utiles/Colors.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../Buyer/MyShipment/presentation/view_model/views/widgets/OrderThumb.dart';

class CancelledOrdersApi {
  CancelledOrdersApi({Dio? dio, FlutterSecureStorage? storage})
    : _dio = dio ?? Dio(),
      _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const String baseUrl = 'https://toknagah.viking-iceland.online/api';
  static const String cancelledOrdersEndpoint = '$baseUrl/saller/all-my-orders';
  static const String orderDetailsEndpoint = '$baseUrl/saller/order-details';

  Future<String?> _getToken() async {
    return await _storage.read(key: 'user_token');
  }

  Options _buildOptions(String token) {
    return Options(
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  Future<List<CancelledOrderModel>> getCancelledOrders({
    CancelToken? cancelToken,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing. Please login.');
    }

    final res = await _dio.get(
      cancelledOrdersEndpoint,
      queryParameters: {'type': 'cancelled'},
      options: _buildOptions(token),
      cancelToken: cancelToken,
    );

    if ((res.statusCode ?? 500) >= 200 &&
        (res.statusCode ?? 500) < 300 &&
        res.data != null) {
      final responseData = res.data as Map<String, dynamic>;
      final data = responseData['data'];

      if (data is List) {
        return data.map((e) => CancelledOrderModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<CancelledOrderDetailsModel> getOrderDetails({
    required String orderId,
    CancelToken? cancelToken,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing. Please login.');
    }

    final res = await _dio.get(
      '$orderDetailsEndpoint/$orderId',
      options: _buildOptions(token),
      cancelToken: cancelToken,
    );

    if ((res.statusCode ?? 500) >= 200 &&
        (res.statusCode ?? 500) < 300 &&
        res.data != null) {
      final responseData = res.data as Map<String, dynamic>;
      return CancelledOrderDetailsModel.fromJson(responseData['data']);
    }
    throw Exception('Failed to fetch order details');
  }
}

class CancelledOrderModel {
  final int orderId;
  final String orderNumber;
  final String status;
  final int isPaid;
  final double total;
  final double fees;
  final double finalTotal;
  final int countItems;
  final String createdAt;

  CancelledOrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.isPaid,
    required this.total,
    required this.fees,
    required this.finalTotal,
    required this.countItems,
    required this.createdAt,
  });

  factory CancelledOrderModel.fromJson(Map<String, dynamic> json) {
    return CancelledOrderModel(
      orderId: json['order_id'] ?? 0,
      orderNumber: json['order_number']?.toString() ?? '#0',
      status: json['status']?.toString() ?? 'cancelled',
      isPaid: json['is_paid'] ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
      finalTotal: (json['final_total'] as num?)?.toDouble() ?? 0.0,
      countItems: json['count_items'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class CancelledOrderDetailsModel {
  final CancelledUserInfo user;
  final CancelledOrderInfo order;
  final List<CancelledOrderItem> items;
  final CancelledTrackOrder trackOrder;

  CancelledOrderDetailsModel({
    required this.user,
    required this.order,
    required this.items,
    required this.trackOrder,
  });

  factory CancelledOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? {};
    final orderData = json['order'] as Map<String, dynamic>? ?? {};
    final itemsData = json['items'] as List<dynamic>? ?? [];
    final trackData = json['trackOrder'] as Map<String, dynamic>? ?? {};

    return CancelledOrderDetailsModel(
      user: CancelledUserInfo.fromJson(userData),
      order: CancelledOrderInfo.fromJson(orderData),
      items: itemsData.map((e) => CancelledOrderItem.fromJson(e)).toList(),
      trackOrder: CancelledTrackOrder.fromJson(trackData),
    );
  }
}

class CancelledUserInfo {
  final String name;
  final String email;
  final String country;
  final String phone;
  final String? image;

  CancelledUserInfo({
    required this.name,
    required this.email,
    required this.country,
    required this.phone,
    this.image,
  });

  factory CancelledUserInfo.fromJson(Map<String, dynamic> json) {
    return CancelledUserInfo(
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}

class CancelledOrderInfo {
  final int orderId;
  final String orderNumber;
  final String status;
  final int isPaid;
  final double total;
  final double fees;
  final double finalTotal;
  final String paymentType;
  final int countItems;
  final String createdAt;

  CancelledOrderInfo({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.isPaid,
    required this.total,
    required this.fees,
    required this.finalTotal,
    required this.paymentType,
    required this.countItems,
    required this.createdAt,
  });

  factory CancelledOrderInfo.fromJson(Map<String, dynamic> json) {
    return CancelledOrderInfo(
      orderId: json['order_id'] ?? 0,
      orderNumber: json['order_number']?.toString() ?? '#0',
      status: json['status']?.toString() ?? 'cancelled',
      isPaid: json['is_paid'] ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
      finalTotal: (json['final_total'] as num?)?.toDouble() ?? 0.0,
      paymentType: json['payment_type']?.toString() ?? '',
      countItems: json['count_items'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class CancelledOrderItem {
  final int itemId;
  final String itemName;
  final int quantity;
  final String description;
  final String price;
  final String discount;
  final String fees;
  final String total;
  final String image;

  CancelledOrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.description,
    required this.price,
    required this.discount,
    required this.fees,
    required this.total,
    required this.image,
  });

  factory CancelledOrderItem.fromJson(Map<String, dynamic> json) {
    return CancelledOrderItem(
      itemId: json['item_id'] ?? 0,
      itemName: json['item_name']?.toString() ?? 'Unknown Product',
      quantity: json['quantity'] ?? 1,
      description: json['description']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
      discount: json['discount']?.toString() ?? '0.00',
      fees: json['fees']?.toString() ?? '0.00',
      total: json['total']?.toString() ?? '0.00',
      image: json['image']?.toString() ?? '',
    );
  }
}

class CancelledTrackOrder {
  final int id;
  final int orderId;
  final int accepted;
  final String? acceptedTime;
  final int shipped;
  final String? shippedTime;
  final int completed;
  final String? completedTime;
  final dynamic canceled;
  final dynamic canceledTime;

  CancelledTrackOrder({
    required this.id,
    required this.orderId,
    required this.accepted,
    this.acceptedTime,
    required this.shipped,
    this.shippedTime,
    required this.completed,
    this.completedTime,
    this.canceled,
    this.canceledTime,
  });

  factory CancelledTrackOrder.fromJson(Map<String, dynamic> json) {
    return CancelledTrackOrder(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      accepted: json['accepted'] ?? 0,
      acceptedTime: json['accepted_time']?.toString(),
      shipped: json['shipped'] ?? 0,
      shippedTime: json['shipped_time']?.toString(),
      completed: json['compeleted'] ?? 0,
      completedTime: json['compeleted_time']?.toString(),
      canceled: json['canceled'],
      canceledTime: json['canceled_time'],
    );
  }
}

abstract class CancelledOrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CancelledOrdersLoading extends CancelledOrdersState {}

class CancelledOrdersLoaded extends CancelledOrdersState {
  final List<CancelledOrderModel> orders;

  CancelledOrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class CancelledOrdersError extends CancelledOrdersState {
  final String message;
  CancelledOrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

class CancelledOrdersCubit extends Cubit<CancelledOrdersState> {
  CancelledOrdersCubit(this._api) : super(CancelledOrdersLoading()) {
    fetchCancelledOrders();
  }

  final CancelledOrdersApi _api;
  CancelToken? _cancelToken;

  Future<void> fetchCancelledOrders() async {
    emit(CancelledOrdersLoading());
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    try {
      final list = await _api.getCancelledOrders(cancelToken: _cancelToken);
      emit(CancelledOrdersLoaded(orders: list));
    } catch (e) {
      emit(CancelledOrdersError(e.toString()));
    }
  }

  Future<CancelledOrderDetailsModel> getOrderDetails(String orderId) async {
    return await _api.getOrderDetails(orderId: orderId);
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }
}

// ===================== ShipmentCardSeller Widget =====================
class CancelledShipmentCardSeller extends StatelessWidget {
  final int orderId;
  final String orderNumber;
  final String status;
  final int countItems;
  final double finalTotal;
  final String? orderImage;
  final String createdAt;
  final VoidCallback? onTap;

  const CancelledShipmentCardSeller({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.countItems,
    required this.finalTotal,
    this.orderImage,
    required this.createdAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textDirection = Localizations.localeOf(context).languageCode == 'ar'
        ? TextDirection.rtl
        : TextDirection.ltr;

    return GestureDetector(
      onTap: onTap,
      child: Directionality(
        textDirection: textDirection,
        child: Container(
          margin: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.04,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OrderThumb(
                      size: screenWidth * 0.18,
                      radius: screenWidth * 0.02,
                      imageUrl: orderImage,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  orderNumber,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.bold,
                                    color: KprimaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03,
                                  vertical: screenWidth * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withAlpha(51),
                                  borderRadius: BorderRadius.circular(
                                    screenWidth * 0.015,
                                  ),
                                ),
                                child: Text(
                                  _getStatusText(status, context).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.025,
                                    fontWeight: FontWeight.w600,
                                    color: _getStatusColor(status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          Divider(color: Colors.grey.shade300),
                          SizedBox(height: screenWidth * 0.02),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).quantityLabel,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.005),
                                  Text(
                                    '$countItems',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: screenWidth * 0.1),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).date,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.005),
                                  Text(
                                    _formatDate(createdAt),
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    S.of(context).total,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.005),
                                  Text(
                                    '${finalTotal.toStringAsFixed(2)} ${S.of(context).SYP}',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xffFF580E),
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final st = status.toLowerCase();
    if (st.contains('pending') || st.contains('معلق')) {
      return Colors.orange;
    } else if (st.contains('confirmed') ||
        st.contains('تم التأكيد') ||
        st.contains('تمت الموافقة')) {
      return Colors.blue;
    } else if (st.contains('shipped') || st.contains('تم الشحن')) {
      return Colors.green;
    } else if (st.contains('delivered') ||
        st.contains('تم التسليم') ||
        st.contains('تم الاستلام')) {
      return KprimaryColor;
    } else if (st.contains('cancelled') || st.contains('ملغي')) {
      return const Color(0xffDD0C0C);
    }
    return Colors.grey;
  }

  String _getStatusText(String status, BuildContext context) {
    final st = status.toLowerCase();
    if (st.contains('pending') || st.contains('معلق')) {
      return S.of(context).pending;
    } else if (st.contains('confirmed') ||
        st.contains('تم التأكيد') ||
        st.contains('تمت الموافقة')) {
      return S.of(context).orderConfirmed;
    } else if (st.contains('shipped') || st.contains('تم الشحن')) {
      return S.of(context).shippedStatus;
    } else if (st.contains('delivered') ||
        st.contains('تم التسليم') ||
        st.contains('تم الاستلام')) {
      return S.of(context).receivedStatus;
    } else if (st.contains('cancelled') || st.contains('ملغي')) {
      return S.of(context).cancelledTab;
    }
    return status;
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '--';
    final parts = date.split(' ');
    return parts.isNotEmpty ? parts[0] : date;
  }
}

// ===================== CancelledOrderCardSeller Widget =====================
class CancelledOrderCardSeller extends StatelessWidget {
  final CancelledOrderModel order;

  const CancelledOrderCardSeller({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return CancelledShipmentCardSeller(
      orderId: order.orderId,
      orderNumber: order.orderNumber,
      status: order.status,
      countItems: order.countItems,
      finalTotal: order.finalTotal,
      createdAt: order.createdAt,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<CancelledOrdersCubit>(),
              child: CancelledOrderDetailsPage(order: order),
            ),
          ),
        );
      },
    );
  }
}

// ===================== CancelledOrderDetailsPage =====================
class CancelledOrderDetailsPage extends StatefulWidget {
  final CancelledOrderModel order;
  final CancelledOrderDetailsModel? details;

  const CancelledOrderDetailsPage({
    super.key,
    required this.order,
    this.details,
  });

  @override
  State<CancelledOrderDetailsPage> createState() =>
      _CancelledOrderDetailsPageState();
}

class _CancelledOrderDetailsPageState extends State<CancelledOrderDetailsPage> {
  CancelledOrderDetailsModel? _details;
  bool _loadingDetails = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  void _fetchOrderDetails() async {
    if (widget.details != null) {
      _details = widget.details;
      return;
    }

    setState(() {
      _loadingDetails = true;
    });

    try {
      final cubit = context.read<CancelledOrdersCubit>();
      final details = await cubit.getOrderDetails(
        widget.order.orderId.toString(),
      );
      setState(() {
        _details = details;
        _loadingDetails = false;
      });
    } catch (e) {
      setState(() {
        _loadingDetails = false;
      });
    }
  }

  Widget _buildCustomerInfo(double screenWidth) {
    if (_loadingDetails) {
      return _buildShimmerCustomerInfo(screenWidth);
    }

    final user = _details?.user;
    if (user == null) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: screenWidth * 0.08,
            backgroundColor: Colors.grey[200],
            child:
                user.image != null &&
                    user.image!.isNotEmpty &&
                    _isValidUrl(user.image!)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(screenWidth * 0.08),
                    child: CachedNetworkImage(
                      imageUrl: user.image!,
                      fit: BoxFit.cover,
                      width: screenWidth * 0.16,
                      height: screenWidth * 0.16,
                      placeholder: (context, url) => Container(
                        width: screenWidth * 0.16,
                        height: screenWidth * 0.16,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: screenWidth * 0.08,
                          color: Colors.grey[400],
                        ),
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.person,
                        size: screenWidth * 0.08,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: screenWidth * 0.08,
                    color: Colors.grey[600],
                  ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user.phone,
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user.country,
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Widget _buildShimmerCustomerInfo(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          shimmer_package.Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: CircleAvatar(
              radius: screenWidth * 0.08,
              backgroundColor: Colors.grey[300],
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmer_package.Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.04,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 8),
                shimmer_package.Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: screenWidth * 0.4,
                    height: screenWidth * 0.03,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: 8),
                shimmer_package.Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: screenWidth * 0.5,
                    height: screenWidth * 0.03,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderProducts(double screenWidth) {
    if (_loadingDetails) {
      return _buildShimmerProducts(screenWidth);
    }

    final items = _details?.items ?? [];
    if (items.isEmpty) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).productDetails,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          ...items.map((item) => _buildProductItem(item, screenWidth)).toList(),
          SizedBox(height: screenWidth * 0.02),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: screenWidth * 0.02),
          _buildRow(
            S.of(context).quantity,
            '${widget.order.countItems}',
            screenWidth,
          ),
          _buildRow(
            S.of(context).price,
            '${widget.order.total} ${S.of(context).SYP}',
            screenWidth,
          ),
          _buildRow(
            S.of(context).shippingCost,
            '${widget.order.fees} ${S.of(context).SYP}',
            screenWidth,
          ),
          _buildRow(
            S.of(context).paymentType,
            _getPaymentTypeText(_details?.order.paymentType ?? ''),
            screenWidth,
          ),
          _buildRow(
            S.of(context).total,
            '${widget.order.finalTotal} ${S.of(context).SYP}',
            screenWidth,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  String _getPaymentTypeText(String paymentType) {
    final type = paymentType.toLowerCase();
    if (type == 'visa' || type == 'credit_card') {
      return S.of(context).creditCard;
    } else if (type == 'cash') {
      return S.of(context).cashOnDelivery;
    } else if (type == 'wallet') {
      return S.of(context).wallet;
    } else if (type == 'bank_transfer') {
      return S.of(context).bankTransfer;
    } else {
      return paymentType;
    }
  }

  Widget _buildProductItem(CancelledOrderItem item, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrderThumb(
            size: screenWidth * 0.15,
            radius: screenWidth * 0.02,
            imageUrl: item.image,
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: screenWidth * 0.01),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.025,
                        vertical: screenWidth * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: KprimaryColor.withAlpha(51),
                        borderRadius: BorderRadius.circular(
                          screenWidth * 0.015,
                        ),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: TextStyle(
                          fontSize: screenWidth * 0.025,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    if (double.tryParse(item.discount) != null &&
                        double.parse(item.discount) > 0)
                      Text(
                        '${S.of(context).discountLabel} ${item.discount}%',
                        style: TextStyle(
                          fontSize: screenWidth * 0.025,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      item.total,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffFF580E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerProducts(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          shimmer_package.Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.035,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          ...List.generate(2, (_) => _buildShimmerProductItem(screenWidth)),
        ],
      ),
    );
  }

  Widget _buildShimmerProductItem(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.02),
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          shimmer_package.Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shimmer_package.Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: screenWidth * 0.4,
                    height: screenWidth * 0.03,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                shimmer_package.Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: screenWidth * 0.6,
                    height: screenWidth * 0.02,
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Row(
                  children: [
                    shimmer_package.Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: screenWidth * 0.15,
                        height: screenWidth * 0.03,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.01,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    shimmer_package.Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.03,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value,
    double width, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.01),
      child: Row(
        children: [
          SizedBox(
            width: width * 0.3,
            child: Text(
              label,
              style: TextStyle(fontSize: width * 0.03, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: width * 0.03,
                color: isTotal ? const Color(0xffFF580E) : Colors.black,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).orderDetails),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerInfo(screenWidth),
            SizedBox(height: screenWidth * 0.04),
            _buildOrderProducts(screenWidth),
            SizedBox(height: screenWidth * 0.04),
            Container(
              width: screenWidth,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).orderStatus,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getStatusText(widget.order.status, context),
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(widget.order.status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final st = status.toLowerCase();
    if (st.contains('pending') || st.contains('معلق')) {
      return Color(0xffFF580E);
    } else if (st.contains('confirmed') ||
        st.contains('تم التأكيد') ||
        st.contains('تمت الموافقة')) {
      return Colors.blue;
    } else if (st.contains('shipped') || st.contains('تم الشحن')) {
      return Colors.green;
    } else if (st.contains('delivered') ||
        st.contains('تم التسليم') ||
        st.contains('تم الاستلام')) {
      return KprimaryColor;
    } else if (st.contains('cancelled') || st.contains('ملغي')) {
      return const Color(0xffDD0C0C);
    }
    return Colors.grey;
  }

  String _getStatusText(String status, BuildContext context) {
    final st = status.toLowerCase();
    if (st.contains('pending') || st.contains('معلق')) {
      return S.of(context).pending;
    } else if (st.contains('confirmed') ||
        st.contains('تم التأكيد') ||
        st.contains('تمت الموافقة')) {
      return S.of(context).orderConfirmed;
    } else if (st.contains('shipped') || st.contains('تم الشحن')) {
      return S.of(context).shippedStatus;
    } else if (st.contains('delivered') ||
        st.contains('تم التسليم') ||
        st.contains('تم الاستلام')) {
      return S.of(context).receivedStatus;
    } else if (st.contains('cancelled') || st.contains('ملغي')) {
      return S.of(context).cancelledTab;
    }
    return status;
  }
}

// ===================== SellerCancelledOrdersPage =====================
// ... كود المستوردات والنماذج والـ API بدون تغيير ...

// ===================== SellerCancelledOrdersPage =====================
class SellerCancelledOrdersPage extends StatelessWidget {
  const SellerCancelledOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CancelledOrdersCubit(CancelledOrdersApi()),
      child: Scaffold(
        backgroundColor: const Color(0xfffafafa),
        appBar: CustomAppBar(title: S.of(context).cancelledTab),
        body: BlocBuilder<CancelledOrdersCubit, CancelledOrdersState>(
          builder: (context, state) {
            if (state is CancelledOrdersError) {
              // عرض تصميم فشل الاتصال مشابه لـ SuggestionsPage
              return _buildErrorState(context, state.message);
            }

            if (state is CancelledOrdersLoaded) {
              final orders = state.orders;
              if (orders.isEmpty) {
                return emptyState(context, S.of(context).noOrdersYet);
              }
              return RefreshIndicator(
                onRefresh: () async {
                  await context
                      .read<CancelledOrdersCubit>()
                      .fetchCancelledOrders();
                },
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return CancelledOrderCardSeller(order: order);
                  },
                ),
              );
            }

            return _buildCancelledOrdersShimmerList(context);
          },
        ),
      ),
    );
  }

  // تصميم حالة فشل الاتصال/السيرفر (مشابه لـ SuggestionsPage)
  Widget _buildErrorState(BuildContext context, String errorMessage) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: screenHeight * 0.8,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.network_check,
                color: Colors.grey,
                size: screenWidth * 0.15,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                S.of(context).connectionTimeout,
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
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
                    context.read<CancelledOrdersCubit>().fetchCancelledOrders();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFF580E),
                    minimumSize: Size(screenWidth * 0.4, screenHeight * 0.04),
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
      ),
    );
  }

  Widget _buildCancelledOrdersShimmerList(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = 6;

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.04,
          ),
          child: shimmer_package.Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth * 0.18,
                    height: screenWidth * 0.18,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: screenWidth * 0.035,
                          width: screenWidth * 0.4,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Container(
                          height: screenWidth * 0.03,
                          width: screenWidth * 0.6,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        Row(
                          children: [
                            Container(
                              height: screenWidth * 0.035,
                              width: screenWidth * 0.15,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.015,
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Container(
                              height: screenWidth * 0.03,
                              width: screenWidth * 0.2,
                              color: Colors.grey.shade300,
                            ),
                            const Spacer(),
                            Container(
                              height: screenWidth * 0.03,
                              width: screenWidth * 0.18,
                              color: Colors.grey.shade300,
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

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
import 'SellerNewOrdersPage.dart';

// ==================== API ==========================
class ActiveOrdersApi {
  ActiveOrdersApi({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage();

  final Dio _dio;
  final FlutterSecureStorage _storage;

  static const String baseUrl = 'https://toknagah.viking-iceland.online/api';
  static const String allOrdersEndpoint = '$baseUrl/saller/all-my-orders';
  static const String orderDetailsEndpoint = '$baseUrl/saller/order-details';
  static const String orderShippedEndpoint = '$baseUrl/saller/order-shipped';
  static const String orderDeliveredEndpoint = '$baseUrl/saller/order-compeleted'; // التعديل هنا

  Future<String?> _getToken() async => _storage.read(key: 'user_token');

  Options _buildOptions(String token) => Options(
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  Future<List<ActiveOrderModel>> getOrdersByType({
    required String type,
    CancelToken? cancelToken,
  }) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing. Please login.');
    }

    final res = await _dio.get(
      allOrdersEndpoint,
      queryParameters: {'type': type},
      options: _buildOptions(token),
      cancelToken: cancelToken,
    );

    if ((res.statusCode ?? 500) >= 200 && (res.statusCode ?? 500) < 300 && res.data != null) {
      final responseData = res.data as Map<String, dynamic>;
      final data = responseData['data'];

      if (data is List) {
        return data.map((e) => ActiveOrderModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  Future<OrderDetailsModel?> getOrderDetails(String orderId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing. Please login.');
    }

    try {
      final res = await _dio.get(
        '$orderDetailsEndpoint/$orderId',
        options: _buildOptions(token),
      );

      if ((res.statusCode ?? 500) >= 200 && (res.statusCode ?? 500) < 300 && res.data != null) {
        final responseData = res.data as Map<String, dynamic>;
        return OrderDetailsModel.fromJson(responseData['data']);
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
    return null;
  }

  // كل التغييرات SET تكون عبر GET (وليست POST)
  Future<bool> markOrderShipped(String orderId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing. Please login.');
    }

    try {
      final res = await _dio.get(
        '$orderShippedEndpoint/$orderId',
        options: _buildOptions(token),
      );
      return (res.statusCode ?? 500) >= 200 && (res.statusCode ?? 500) < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markOrderDelivered(String orderId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token is missing. Please login.');
    }

    try {
      final res = await _dio.get(
        '$orderDeliveredEndpoint/$orderId',
        options: _buildOptions(token),
      );
      print('Delivered response status: ${res.statusCode}');
      print('Delivered response data: ${res.data}');
      return (res.statusCode ?? 500) >= 200 && (res.statusCode ?? 500) < 300;
    } catch (e) {
      print('Error delivered: $e');
      return false;
    }
  }
}

// ==================== Models ==========================
class ActiveOrderModel {
  final int orderId;
  final String orderNumber;
  final String status;
  final int isPaid;
  final double total;
  final double fees;
  final double finalTotal;
  final int countItems;
  final String createdAt;

  ActiveOrderModel({
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

  factory ActiveOrderModel.fromJson(Map<String, dynamic> json) {
    return ActiveOrderModel(
      orderId: json['order_id'] ?? 0,
      orderNumber: json['order_number']?.toString() ?? '#0',
      status: json['status']?.toString() ?? 'pending',
      isPaid: json['is_paid'] ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
      finalTotal: (json['final_total'] as num?)?.toDouble() ?? 0.0,
      countItems: json['count_items'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class OrderDetailsModel {
  final UserInfo user;
  final OrderInfo order;
  final List<OrderItem> items;
  final TrackOrder trackOrder;

  OrderDetailsModel({
    required this.user,
    required this.order,
    required this.items,
    required this.trackOrder,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? {};
    final orderData = json['order'] as Map<String, dynamic>? ?? {};
    final itemsData = json['items'] as List<dynamic>? ?? [];
    final trackData = json['trackOrder'] as Map<String, dynamic>? ?? {};

    return OrderDetailsModel(
      user: UserInfo.fromJson(userData),
      order: OrderInfo.fromJson(orderData),
      items: itemsData.map((e) => OrderItem.fromJson(e)).toList(),
      trackOrder: TrackOrder.fromJson(trackData),
    );
  }
}

class UserInfo {
  final String name;
  final String email;
  final String country;
  final String phone;
  final String? image;

  UserInfo({
    required this.name,
    required this.email,
    required this.country,
    required this.phone,
    this.image,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      image: json['image']?.toString(),
    );
  }
}

class OrderInfo {
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

  OrderInfo({
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

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      orderId: json['order_id'] ?? 0,
      orderNumber: json['order_number']?.toString() ?? '#0',
      status: json['status']?.toString() ?? 'pending',
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

class OrderItem {
  final int itemId;
  final String itemName;
  final int quantity;
  final String description;
  final String price;
  final String discount;
  final String fees;
  final String total;
  final String image;

  OrderItem({
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

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
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

class TrackOrder {
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

  TrackOrder({
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

  factory TrackOrder.fromJson(Map<String, dynamic> json) {
    return TrackOrder(
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

// ==================== Bloc ==========================
abstract class ActiveOrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ActiveOrdersLoading extends ActiveOrdersState {}
class ActiveOrdersLoaded extends ActiveOrdersState {
  final List<ActiveOrderModel> accepted;
  final List<ActiveOrderModel> shipping;
  final List<ActiveOrderModel> completed;

  ActiveOrdersLoaded({
    required this.accepted,
    required this.shipping,
    required this.completed,
  });
  @override
  List<Object?> get props => [accepted, shipping, completed];

  ActiveOrdersLoaded copyWith({
    List<ActiveOrderModel>? accepted,
    List<ActiveOrderModel>? shipping,
    List<ActiveOrderModel>? completed,
  }) {
    return ActiveOrdersLoaded(
      accepted: accepted ?? this.accepted,
      shipping: shipping ?? this.shipping,
      completed: completed ?? this.completed,
    );
  }
}
class ActiveOrdersError extends ActiveOrdersState {
  final String message;
  ActiveOrdersError(this.message);
  @override
  List<Object?> get props => [message];
}

class ActiveOrdersCubit extends Cubit<ActiveOrdersState> {
  ActiveOrdersCubit(this._api) : super(ActiveOrdersLoading()) {
    fetchAll();
  }

  final ActiveOrdersApi _api;
  CancelToken? _cancelToken;

  Future<void> fetchAll() async {
    emit(ActiveOrdersLoading());
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    try {
      final results = await Future.wait<List<ActiveOrderModel>>([
        _api.getOrdersByType(type: 'accepted', cancelToken: _cancelToken),
        _api.getOrdersByType(type: 'shipping', cancelToken: _cancelToken),
        _api.getOrdersByType(type: 'completed', cancelToken: _cancelToken),
      ]);
      emit(ActiveOrdersLoaded(accepted: results[0], shipping: results[1], completed: results[2]));
    } catch (e) {
      emit(ActiveOrdersError(e.toString()));
    }
  }
  Future<void> fetchByType(String type) async {
    final current = state;
    try {
      final list = await _api.getOrdersByType(type: type);
      if (current is ActiveOrdersLoaded) {
        switch (type) {
          case 'accepted':
            emit(current.copyWith(accepted: list));
            break;
          case 'shipping':
            emit(current.copyWith(shipping: list));
            break;
          case 'completed':
            emit(current.copyWith(completed: list));
            break;
        }
      } else {
        await fetchAll();
      }
    } catch (e) {
      emit(ActiveOrdersError(e.toString()));
    }
  }
  Future<void> markShipped(String orderId) async {
    final ok = await _api.markOrderShipped(orderId);
    if (ok) await fetchAll();
  }
  Future<void> markDelivered(String orderId) async {
    final ok = await _api.markOrderDelivered(orderId);
    if (ok) await fetchAll();
  }
  Future<OrderDetailsModel?> loadDetails(String orderId) => _api.getOrderDetails(orderId);
  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }
}

// ==================== UIs ==========================

class ActiveShipmentCardSeller extends StatelessWidget {
  final ActiveOrderModel order;
  final Function(ActiveOrderModel, String)? onStatusChange;

  const ActiveShipmentCardSeller({
    super.key,
    required this.order,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return ShipmentCardSeller(
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
              value: context.read<ActiveOrdersCubit>(),
              child: SellerActiveOrderDetailsPage(
                order: order,
                onStatusChange: onStatusChange,
              ),
            ),
          ),
        );
      },
    );
  }
}

// صفحة تفاصيل الطلب الحالي (تشمل زر الشحن أو التوصيل حسب الحالة)
class SellerActiveOrderDetailsPage extends StatefulWidget {
  final ActiveOrderModel order;
  final OrderDetailsModel? details;
  final Function(ActiveOrderModel, String)? onStatusChange;

  const SellerActiveOrderDetailsPage({
    super.key,
    required this.order,
    this.details,
    this.onStatusChange,
  });

  @override
  State<SellerActiveOrderDetailsPage> createState() => _SellerActiveOrderDetailsPageState();
}

class _SellerActiveOrderDetailsPageState extends State<SellerActiveOrderDetailsPage> {
  OrderDetailsModel? _details;
  bool _loadingDetails = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  void _fetchOrderDetails() async {
    if (widget.details != null) {
      _details = widget.details;
      setState(() {});
      return;
    }
    setState(() {
      _loadingDetails = true;
    });
    try {
      final cubit = context.read<ActiveOrdersCubit>();
      final details = await cubit.loadDetails(widget.order.orderId.toString());
      setState(() {
        _details = details;
        _loadingDetails = false;
      });
    } catch (e) {
      setState(() { _loadingDetails = false; });
    }
  }

  Future<void> _handleAction(String status, BuildContext dialogContext) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cubit = context.read<ActiveOrdersCubit>();
      if (status == "shipping" || status == "shipped") {
        await cubit.markShipped(widget.order.orderId.toString());
      } else if (status == "completed" || status == "delivered") {
        await cubit.markDelivered(widget.order.orderId.toString());
      }
      Navigator.of(dialogContext).pop(); // أغلق الديالوج أولاً
      Navigator.of(context).pop();       // أغلق صفحة التفاصيل بعد العملية
    } catch (e) {
      setState(() {
        _error = S.of(context).updateFailed;
      });
      Navigator.of(dialogContext).pop(); // أغلق الديالوج حتى لو خطأ
      Navigator.of(context).pop();       // أغلق صفحة التفاصيل
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showActionDialog(String action, String newStatus) {
    final screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierDismissible: false, // الديالوج لا يقفل إلا من الأزرار
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xfffafafa),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            title: Text(
              S.of(context).confirmAction(action),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
            ),
            content: Text(
              S.of(context).confirmActionMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey[700]),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KprimaryColor,
                        minimumSize: Size(0, screenWidth * 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                        setDialogState(() {}); // إعادة بناء الديالوج
                        setState(() { _isLoading = true; });
                        await _handleAction(newStatus, dialogContext);
                      },
                      child: _isLoading
                          ? SizedBox(
                        width: screenWidth * 0.04,
                        height: screenWidth * 0.04,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        S.of(context).yes,
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        minimumSize: Size(0, screenWidth * 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading ? null : () => Navigator.pop(dialogContext),
                      child: Text(S.of(context).no, style: TextStyle(color: Colors.black87, fontSize: screenWidth * 0.035)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  bool _shouldShowShipButton(String status) {
    final st = status.toLowerCase();
    return st == 'accepted' ||
        st == 'confirmed' ||
        st == 'processing' ||
        st.contains('accepted') ||
        st.contains('confirmed') ||
        st.contains('processing');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: CustomAppBar(title: S.of(context).orderDetails),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
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
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).orderStatus,
                        style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold),
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
                ),
                SizedBox(height: screenWidth * 0.04),

                if (_shouldShowShipButton(widget.order.status))
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KprimaryColor,
                        minimumSize: Size(screenWidth, screenWidth * 0.12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading ? null : () {
                        _showActionDialog(S.of(context).ship, "shipping");
                      },
                      child: Text(
                        S.of(context).shippedStatus,
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035),
                      ),
                    ),
                  ),

                if (widget.order.status.toLowerCase() == 'shipping')
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KprimaryColor,
                        minimumSize: Size(screenWidth, screenWidth * 0.12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _isLoading ? null : () {
                        _showActionDialog(S.of(context).delivered, "completed");
                      },
                      child: Text(
                        S.of(context).markAsDelivered,
                        style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035),
                      ),
                    ),
                  ),

                if (_error != null)
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  )
              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.07),
                child: Center(
                  child: CircularProgressIndicator(color: KprimaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(double screenWidth) {
    if (_loadingDetails) return _buildShimmerCustomerInfo(screenWidth);
    final user = _details?.user;
    if (user == null) return Container();
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
            child: user.image != null && user.image!.isNotEmpty && _isValidUrl(user.image!)
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
                  child: Icon(Icons.person, size: screenWidth * 0.08, color: Colors.grey[400]),
                ),
                errorWidget: (_, __, ___) => Icon(Icons.person, size: screenWidth * 0.08, color: Colors.grey[600]),
              ),
            )
                : Icon(Icons.person, size: screenWidth * 0.08, color: Colors.grey[600]),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(user.phone, style: TextStyle(fontSize: screenWidth * 0.032, color: Colors.grey[700])),
                SizedBox(height: 4),
                Text(user.email, style: TextStyle(fontSize: screenWidth * 0.032, color: Colors.grey[700])),
                SizedBox(height: 4),
                Text(user.country, style: TextStyle(fontSize: screenWidth * 0.032, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
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
    if (_loadingDetails) return _buildShimmerProducts(screenWidth);
    final items = _details?.items ?? [];
    if (items.isEmpty) return Container();
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).productDetails, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold)),
          SizedBox(height: screenWidth * 0.02),
          ...items.map((item) => _buildProductItem(item, screenWidth)).toList(),
          SizedBox(height: screenWidth * 0.02),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: screenWidth * 0.02),
          _buildRow(S.of(context).quantityLabel, '${widget.order.countItems}', screenWidth),
          _buildRow(S.of(context).priceLabel, '${widget.order.total} ${S.of(context).SYP}', screenWidth),
          _buildRow(S.of(context).shippingCostLabel, '${widget.order.fees} ${S.of(context).SYP}', screenWidth),
          _buildRow(S.of(context).paymentType, _getPaymentTypeText(_details?.order.paymentType ?? ''), screenWidth),
          _buildRow(S.of(context).totalLabel, '${widget.order.finalTotal} ${S.of(context).SYP}', screenWidth, isTotal: true),
        ],
      ),
    );
  }
  String _getPaymentTypeText(String paymentType) {
    final type = paymentType.toLowerCase();
    if (type == 'visa' || type == 'credit_card') return S.of(context).visa;
    else if (type == 'cash') return S.of(context).cashOnDelivery;
    else if (type == 'wallet') return S.of(context).wallet;
    else if (type == 'bank_transfer') return S.of(context).bankTransfer;
    else return paymentType;
  }
  Widget _buildProductItem(OrderItem item, double screenWidth) {
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
                Text(item.itemName, style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.bold)),
                SizedBox(height: screenWidth * 0.01),
                if (item.description.isNotEmpty)
                  Text(
                    item.description,
                    style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.grey[600]),
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
                        borderRadius: BorderRadius.circular(screenWidth * 0.015),
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
                    if (double.tryParse(item.discount) != null && double.parse(item.discount) > 0)
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
        )
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
                          borderRadius: BorderRadius.circular(screenWidth * 0.01),
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
  Widget _buildRow(String label, String value, double width, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: width * 0.01),
      child: Row(
        children: [
          SizedBox(
            width: width * 0.3,
            child: Text(label, style: TextStyle(fontSize: width * 0.03, color: Colors.black54)),
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
  Color _getStatusColor(String status) {
    final st = status.toLowerCase();
    if (st.contains('pending') || st.contains('معلق')) {
      return Color(0xffFF580E);
    } else if (st.contains('confirmed') || st.contains('تم التأكيد') || st.contains('تمت الم��افقة') || st.contains('accepted')) {
      return Colors.blue;
    } else if (st.contains('shipped') || st.contains('تم الشحن') || st.contains('shipping')) {
      return Colors.green;
    } else if (st.contains('delivered') || st.contains('تم التسليم') || st.contains('تم الاستلام') || st.contains('completed')) {
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
    } else if (st.contains('confirmed') || st.contains('تم التأكيد') || st.contains('تمت الموافقة') || st.contains('accepted')) {
      return S.of(context).orderConfirmed;
    } else if (st.contains('shipped') || st.contains('تم الشحن') || st.contains('shipping')) {
      return S.of(context).shippedStatus;
    } else if (st.contains('delivered') || st.contains('تم التسليم') || st.contains('تم الاستلام') || st.contains('completed')) {
      return S.of(context).receivedStatus;
    } else if (st.contains('cancelled') || st.contains('ملغي')) {
      return S.of(context).cancelledTab;
    } else if (st.contains('processing') || st.contains('جاري المعالحه')) {
      return S.of(context).processingStatus;
    }
    return status;
  }
}

// ==================== صفحة الطلبات ==========================
// ... كود المستوردات والنماذج والـ API بدون تغيير ...

// ==================== صفحة الطلبات ==========================
class SellerActiveOrdersPage extends StatefulWidget {
  final bool fromBottomNav;
  const SellerActiveOrdersPage({super.key, this.fromBottomNav = false});
  @override
  State<SellerActiveOrdersPage> createState() => _SellerActiveOrdersPageState();
}

class _SellerActiveOrdersPageState extends State<SellerActiveOrdersPage> {
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActiveOrdersCubit(ActiveOrdersApi()),
      child: Scaffold(
        backgroundColor: const Color(0xfffafafa),
        appBar: CustomAppBar(title: S.of(context).manageOrders),
        body: BlocBuilder<ActiveOrdersCubit, ActiveOrdersState>(
          builder: (context, state) {
            if (state is ActiveOrdersError) {
              // عرض تصميم فشل الاتصال مشابه لـ SuggestionsPage
              return _buildErrorState(context, state.message);
            }
            if (state is! ActiveOrdersLoaded) {
              return _buildActiveOrdersShimmerList(context);
            }
            final lists = [state.accepted, state.shipping, state.completed];
            final tabs = [
              S.of(context).confirmedOrders,
              S.of(context).shippedOrders,
              S.of(context).deliveredOrders,
            ];
            final screenWidth = MediaQuery.of(context).size.width;
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Row(
                    children: List.generate(tabs.length, (i) {
                      final isSelected = selectedTabIndex == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedTabIndex = i),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                            decoration: BoxDecoration(
                              color: isSelected ? KprimaryColor : Colors.grey.shade200,
                              border: Border.all(color: isSelected ? KprimaryColor : Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(screenWidth * 0.05),
                            ),
                            child: Text(
                              "${tabs[i]} (${lists[i].length})",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Expanded(
                  child: lists[selectedTabIndex].isEmpty
                      ? emptyState(context, S.of(context).noOrdersYet)
                      : RefreshIndicator(
                    onRefresh: () async {
                      await context.read<ActiveOrdersCubit>().fetchAll();
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: lists[selectedTabIndex].length,
                      itemBuilder: (context, index) {
                        final order = lists[selectedTabIndex][index];
                        return ActiveShipmentCardSeller(
                          order: order,
                          onStatusChange: selectedTabIndex == 0
                              ? (o, status) => context.read<ActiveOrdersCubit>().markShipped(o.orderId.toString())
                              : selectedTabIndex == 1
                              ? (o, status) => context.read<ActiveOrdersCubit>().markDelivered(o.orderId.toString())
                              : null,
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

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
              ElevatedButton(
                onPressed: () {
                  context.read<ActiveOrdersCubit>().fetchAll();
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
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrdersShimmerList(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemCount = 6;

    return Column(
      children: [
        // Shimmer لعلامات التبويب
        Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: List.generate(3, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                  ),
                  child: shimmer_package.Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: screenWidth * 0.03,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        // Shimmer لعناصر القائمة
        Expanded(
          child: ListView.builder(
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
                                      borderRadius: BorderRadius.circular(screenWidth * 0.015),
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
          ),
        ),
      ],
    );
  }
}
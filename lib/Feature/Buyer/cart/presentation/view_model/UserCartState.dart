class UserCartState {
  final List<Map<String, dynamic>> cartItems;
  final double subtotal;
  final double shipping;
  final double total;
  final String currency;
  final bool isProcessing;
  final bool isLoading;
  final String? errorMessage;
  final int cartId;
  final String? updatingItemId;
  final bool isDeletingItem;

  UserCartState({
    required this.cartItems,
    this.subtotal = 0.0,
    this.shipping = 0.0,
    this.total = 0.0,
    this.currency = 'EGP',
    this.isProcessing = false,
    this.isLoading = false,
    this.errorMessage,
    this.cartId = 0,
    this.updatingItemId,
    this.isDeletingItem = false,
  });

  UserCartState copyWith({
    List<Map<String, dynamic>>? cartItems,
    double? subtotal,
    double? shipping,
    double? total,
    String? currency,
    bool? isProcessing,
    bool? isLoading,
    String? errorMessage,
    int? cartId,
    String? updatingItemId,
    bool? isDeletingItem,
  }) {
    return UserCartState(
      cartItems: cartItems ?? this.cartItems,
      subtotal: subtotal ?? this.subtotal,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      isProcessing: isProcessing ?? this.isProcessing,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      cartId: cartId ?? this.cartId,
      updatingItemId: updatingItemId,
      isDeletingItem: isDeletingItem ?? this.isDeletingItem,
    );
  }
}

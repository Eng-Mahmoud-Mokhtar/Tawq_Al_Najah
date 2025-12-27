abstract class CancelOrderState {
  const CancelOrderState();
}

class CancelOrderInitial extends CancelOrderState {
  const CancelOrderInitial();
}

class CancelOrderLoading extends CancelOrderState {
  const CancelOrderLoading();
}

class CancelOrderSuccess extends CancelOrderState {
  final String message;
  const CancelOrderSuccess({required this.message});
}

class CancelOrderFailure extends CancelOrderState {
  final String message;
  const CancelOrderFailure({required this.message});
}
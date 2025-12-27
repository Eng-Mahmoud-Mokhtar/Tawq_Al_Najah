import 'package:bloc/bloc.dart';
import '../../../../../generated/l10n.dart';
import '../../Data/OrdersRepository.dart';
import 'CancelOrderState.dart';

class CancelOrderCubit extends Cubit<CancelOrderState> {
  final OrdersRepository repo;

  CancelOrderCubit({required this.repo}) : super(const CancelOrderInitial());

  Future<void> cancelOrder(int orderId) async {
    emit(const CancelOrderLoading());
    try {
      final res = await repo.cancelOrderById(orderId);
      final st = res['status'];
      final ok = (st is int && st == 200) || (st is bool && st == true);

      if (ok) {
        emit(
          CancelOrderSuccess(
            message:
            (res['message'] ?? S.current.orderCancelledSuccess).toString(),
          ),
        );
      } else {
        emit(CancelOrderFailure(
            message: (res['message'] ?? 'Failed').toString()));
      }
    } catch (_) {
      emit(const CancelOrderFailure(message: 'Failed'));
    }
  }

  void reset() => emit(const CancelOrderInitial());
}

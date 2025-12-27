import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../Core/utiles/Colors.dart';
import '../../../../../../../generated/l10n.dart';
import '../../CancelOrderCubit.dart';
import '../../CancelOrderState.dart';

class CancelStatusDialog extends StatelessWidget {
  const CancelStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return BlocBuilder<CancelOrderCubit, CancelOrderState>(
      builder: (context, state) {
        Widget content;
        Widget? action;

        if (state is CancelOrderLoading) {
          content = Row(
            children: [
              SizedBox(
                width: w * 0.06,
                height: w * 0.06,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: KprimaryColor,
                ),
              ),
              SizedBox(width: w * 0.04),
              Expanded(
                child: Text(
                  S.of(context).cancellingOrder,
                  style: TextStyle(
                    fontSize: w * 0.035,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        } else if (state is CancelOrderSuccess) {
          content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: w * 0.14,
                height: w * 0.14,
                decoration: BoxDecoration(
                  color: KprimaryColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: KprimaryColor,
                  size: w * 0.085,
                ),
              ),
              SizedBox(height: h * 0.012),
              Text(
                S.of(context).orderCancelledSuccess,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: w * 0.035,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          );
          action = SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: KprimaryColor,
                minimumSize: Size(0, w * 0.11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.02),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                S.of(context).ok,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: w * 0.035,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        } else if (state is CancelOrderFailure) {
          content = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: w * 0.14,
                height: w * 0.14,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: w * 0.085,
                ),
              ),
              SizedBox(height: h * 0.012),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: w * 0.033,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          );
          action = SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.red,
                minimumSize: Size(0, w * 0.11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(w * 0.02),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                S.of(context).ok,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: w * 0.035,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        } else {
          content = const SizedBox.shrink();
        }

        return WillPopScope(
          onWillPop: () async => state is! CancelOrderLoading,
          child: AlertDialog(
            backgroundColor: const Color(0xfffafafa),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(w * 0.04),
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: w * 0.06,
              vertical: w * 0.06,
            ),
            content: content,
            actionsPadding: EdgeInsets.fromLTRB(
              w * 0.04,
              0,
              w * 0.04,
              h * 0.02,
            ),
            actions: action == null ? [] : [action],
          ),
        );
      },
    );
  }
}

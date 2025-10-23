import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../Core/utiles/Colors.dart';

class CodeCubit extends Cubit<List<TextEditingController>> {
  CodeCubit() : super(List.generate(4, (index) => TextEditingController()));

  void updateControllers() {
    emit(List.generate(4, (index) => TextEditingController()));
  }
}

class Code extends StatelessWidget {
  const Code({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CodeCubit(),
      child: BlocBuilder<CodeCubit, List<TextEditingController>>(
        builder: (context, controllers) {
          return LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double fieldSize = screenWidth * 0.18;
              double fontSize = screenWidth * 0.05;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: fieldSize,
                    height: fieldSize,
                    child: TextField(
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(fieldSize / 2),
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: screenWidth * 0.05,
                          horizontal: screenWidth * 0.05,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(fieldSize / 2),
                          borderSide: BorderSide(
                            color: KprimaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      controller: controllers[index],
                      onChanged: (value) {
                        bool isRTL = Directionality.of(context) == TextDirection.rtl;
                        if (value.isNotEmpty) {
                          if (!isRTL && index < controllers.length - 1) {
                            FocusScope.of(context).nextFocus();
                          } else if (isRTL && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        } else {
                          if (!isRTL && index > 0) {
                            FocusScope.of(context).previousFocus();
                          } else if (isRTL && index < controllers.length - 1) {
                            FocusScope.of(context).nextFocus();
                          }
                        }
                      },
                    ),
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }
}

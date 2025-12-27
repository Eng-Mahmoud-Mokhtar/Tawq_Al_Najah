import 'package:flutter/material.dart';

import '../../../../../../Core/utiles/Colors.dart';

class CodeWidget extends StatefulWidget {
  final Function(String) onCodeChanged;
  final bool hasError;

  const CodeWidget({
    super.key,
    required this.onCodeChanged,
    required this.hasError,
  });

  @override
  State<CodeWidget> createState() => _CodeWidgetState();
}

class _CodeWidgetState extends State<CodeWidget> {
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(_onCodeChanged);
    }
  }

  void _onCodeChanged() {
    String fullCode = '';
    for (var controller in _controllers) {
      fullCode += controller.text;
    }
    widget.onCodeChanged(fullCode);
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < _controllers.length - 1) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      }
    } else {
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
    _onCodeChanged();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double fieldSize = screenWidth * 0.18;
        double fontSize = screenWidth * 0.05;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
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
                  textDirection: TextDirection.ltr,
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
                        color: widget.hasError ? Color(0xffDD0C0C) : Colors.black,
                        width: widget.hasError ? 2 : 1.2,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.05,
                      horizontal: screenWidth * 0.05,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(fieldSize / 2),
                      borderSide: BorderSide(
                        color: widget.hasError ? Color(0xffDD0C0C) : KprimaryColor,
                        width: widget.hasError ? 2 : 1.5,
                      ),
                    ),
                  ),
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (value) => _onChanged(value, index),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
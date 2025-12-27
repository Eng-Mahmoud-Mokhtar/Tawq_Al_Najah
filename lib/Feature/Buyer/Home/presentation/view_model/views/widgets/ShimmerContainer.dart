import 'package:flutter/material.dart';
import 'SimpleShimmer.dart';

class ShimmerContainer extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  const ShimmerContainer({super.key, required this.height, required this.width, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    return SimpleShimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

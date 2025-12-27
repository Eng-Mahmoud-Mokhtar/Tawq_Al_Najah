import 'package:flutter/material.dart';
import 'ShimmerBox.dart';

class ShipmentsShimmerList extends StatelessWidget {
  const ShipmentsShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) {
        return Container(
          margin: EdgeInsets.only(
            left: w * 0.04,
            right: w * 0.04,
            bottom: w * 0.04,
          ),
          padding: EdgeInsets.all(w * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(w * 0.03),
          ),
          child: Row(
            children: [
              ShimmerBox(width: w * 0.18, height: w * 0.18, radius: w * 0.02),
              SizedBox(width: w * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: w * 0.5, height: w * 0.04, radius: 8),
                    SizedBox(height: w * 0.02),
                    ShimmerBox(width: w * 0.7, height: w * 0.035, radius: 8),
                    SizedBox(height: w * 0.02),
                    ShimmerBox(width: w * 0.35, height: w * 0.035, radius: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
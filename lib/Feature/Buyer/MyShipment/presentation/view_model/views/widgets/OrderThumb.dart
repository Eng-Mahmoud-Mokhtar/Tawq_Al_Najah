import 'package:flutter/material.dart';
import 'ShimmerBox.dart';

class OrderThumb extends StatelessWidget {
  final double size;
  final double radius;
  final String? imageUrl;

  const OrderThumb({super.key,
    required this.size,
    required this.radius,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: const Color(0xffFF580E),
          size: size * 0.45,
        ),
      ),
    );

    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ShimmerBox(width: size, height: size, radius: radius);
        },
      ),
    );
  }
}

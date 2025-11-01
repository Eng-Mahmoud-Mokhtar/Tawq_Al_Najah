import 'package:flutter/cupertino.dart';

class ConvexNotchedShape extends NotchedShape {
  const ConvexNotchedShape();
  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null) {
      return Path()..addRect(host);
    }

    final fabRadius = guest.width / 2;
    final bigRadius = fabRadius * 1.3;
    final path = Path()..moveTo(host.left, host.top);

    path.quadraticBezierTo(
      guest.center.dx - bigRadius * 1.2,
      host.top,
      guest.center.dx - bigRadius,
      host.top,
    );

    path.arcTo(
      Rect.fromCircle(center: guest.center, radius: bigRadius),
      0,
      -3.14159,
      false,
    );

    path.quadraticBezierTo(
      guest.center.dx + bigRadius * 1.2,
      host.top,
      guest.center.dx + bigRadius,
      host.top,
    );

    path.lineTo(host.right, host.top);
    path.lineTo(host.right, host.bottom);
    path.lineTo(host.left, host.bottom);
    path.close();

    return path;
  }
}

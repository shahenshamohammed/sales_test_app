
import 'package:flutter/material.dart';

class HeaderPainter extends CustomPainter {
  final Gradient gradient;
  HeaderPainter(this.gradient);
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..shader = gradient.createShader(Offset.zero & s);
    final path = Path()
      ..lineTo(0, s.height * .34)
      ..quadraticBezierTo(s.width * .25, s.height * .48, s.width * .5, s.height * .38)
      ..quadraticBezierTo(s.width * .80, s.height * .28, s.width, s.height * .42)
      ..lineTo(s.width, 0)
      ..close();
    c.drawPath(path, p);
  }
  @override
  bool shouldRepaint(covariant HeaderPainter oldDelegate) => false;
}
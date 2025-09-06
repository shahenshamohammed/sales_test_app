
import 'package:flutter/material.dart';

class CustomerHeroBackground extends StatelessWidget {
  final double progress; // 0..1
  const CustomerHeroBackground({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox.expand(
      child: CustomPaint(
        painter: _HeaderPainter(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary, cs.secondary],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
          child: Row(
            children: [

              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add New Customer',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      'Fill in the details — you’re ${(progress * 100).round()}% done',
                      style: TextStyle(color: Colors.white.withOpacity(.95)),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(.22),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderPainter extends CustomPainter {
  final Gradient gradient;
  _HeaderPainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..shader = gradient.createShader(rect);
    final path = Path()
      ..lineTo(0, size.height * .36)
      ..quadraticBezierTo(size.width * .25, size.height * .48, size.width * .5, size.height * .38)
      ..quadraticBezierTo(size.width * .78, size.height * .28, size.width, size.height * .42)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeaderPainter oldDelegate) => false;
}

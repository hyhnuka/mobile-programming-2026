import 'package:flutter/material.dart';

class GlassBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    
    paint.color = const Color(0xFF6A5ACD).withOpacity(0.2);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 150, paint);

    paint.color = const Color(0xFF4CAF50).withOpacity(0.2);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 200, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
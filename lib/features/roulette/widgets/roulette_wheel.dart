import 'dart:math';

import 'package:flutter/material.dart';

import 'package:lunch_roulette_app/models/restaurant.dart';

class RouletteWheel extends StatelessWidget {
  final List<Restaurant> restaurants;
  final double rotation;

  const RouletteWheel({
    super.key,
    required this.restaurants,
    required this.rotation,
  });

  static const List<Color> _sectionColors = [
    Color(0xFFFF8A65),
    Color(0xFFFFD54F),
    Color(0xFF4DB6AC),
    Color(0xFF64B5F6),
    Color(0xFFBA68C8),
    Color(0xFF81C784),
    Color(0xFFFFB74D),
    Color(0xFF7986CB),
    Color(0xFFE57373),
    Color(0xFF4DD0E1),
    Color(0xFFA1887F),
    Color(0xFFAED581),
    Color(0xFFF06292),
    Color(0xFF90A4AE),
    Color(0xFFDCE775),
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: rotation,
            child: CustomPaint(
              size: Size.infinite,
              painter: _WheelPainter(
                restaurants: restaurants,
                colors: _sectionColors,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: CustomPaint(
              size: const Size(24, 32),
              painter: _ArrowPainter(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<Restaurant> restaurants;
  final List<Color> colors;

  _WheelPainter({required this.restaurants, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sectionAngle = 2 * pi / restaurants.length;

    for (var i = 0; i < restaurants.length; i++) {
      final startAngle = i * sectionAngle - pi / 2;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        borderPaint,
      );

      // Draw label
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + sectionAngle / 2);

      final textPainter = TextPainter(
        text: TextSpan(
          text: _truncateName(restaurants[i].name),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: radius * 0.6);
      textPainter.paint(
        canvas,
        Offset(radius * 0.25, -textPainter.height / 2),
      );

      canvas.restore();
    }

    // Center circle
    canvas.drawCircle(
      center,
      radius * 0.12,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      center,
      radius * 0.12,
      Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  String _truncateName(String name) {
    if (name.length > 6) {
      return '${name.substring(0, 5)}..';
    }
    return name;
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.restaurants != restaurants;
}

class _ArrowPainter extends CustomPainter {
  final Color color;

  _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

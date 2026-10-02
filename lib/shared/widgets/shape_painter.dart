import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../features/game/domain/models/piece_shape.dart';

class SquarePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.squareColor
      ..style = PaintingStyle.fill;
      
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    
    // Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PentagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.pentagonColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final cx = width / 2;
    final cy = height / 2;
    final radius = min(width, height) / 2;

    for (var i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) - pi / 2;
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Shadow
    canvas.drawPath(
      path.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.5),
          AppTheme.circleColor,
          AppTheme.circleColor,
        ],
        stops: const [0.0, 0.5, 1.0],
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Shadow
    canvas.drawCircle(
      center + const Offset(0, 3),
      radius,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ShapeWidget extends StatelessWidget {
  final PieceShape? shape;

  const ShapeWidget({super.key, this.shape});

  @override
  Widget build(BuildContext context) {
    if (shape == null) {
      return const SizedBox.expand();
    }

    CustomPainter painter;
    switch (shape!) {
      case PieceShape.square:
        painter = SquarePainter();
        break;
      case PieceShape.pentagon:
        painter = PentagonPainter();
        break;
      case PieceShape.circle:
        painter = CirclePainter();
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomPaint(
        painter: painter,
        size: Size.infinite,
      ),
    );
  }
}

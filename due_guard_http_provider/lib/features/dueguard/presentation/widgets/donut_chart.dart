import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;

  DonutChartPainter({
    required this.values,
    required this.colors,
    this.strokeWidth = 22,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total == 0) {
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = const Color(0xFFE5E5E5);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        (size.width / 2) - strokeWidth / 2,
        p,
      );
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -90 * (math.pi / 180);
    const gap = 0.04;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * (2 * math.pi) - gap;
      if (sweepAngle <= 0) continue;

      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle + gap;
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    return !listEquals(oldDelegate.values, values) ||
        !listEquals(oldDelegate.colors, colors);
  }
}

class DonutChart extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final Widget centerChild;
  final double size;

  const DonutChart({
    super.key,
    required this.values,
    required this.colors,
    required this.centerChild,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: DonutChartPainter(values: values, colors: colors),
          ),
          centerChild,
        ],
      ),
    );
  }
}

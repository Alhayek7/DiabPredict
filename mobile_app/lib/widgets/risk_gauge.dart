import 'package:flutter/material.dart';

class RiskGauge extends StatelessWidget {
  final double riskPercentage;
  final String riskLevel;

  const RiskGauge({
    super.key,
    required this.riskPercentage,
    required this.riskLevel,
  });

  Color get _color {
    if (riskLevel == 'منخفض') return Colors.green;
    if (riskLevel == 'متوسط') return Colors.orange;
    return Colors.red;
  }

  String get _message {
    if (riskLevel == 'منخفض') return '✅ الخطر منخفض - استمر في نمط حياتك الصحي';
    if (riskLevel == 'متوسط') return '⚠️ خطر متوسط - ننصح باستشارة الطبيب';
    return '🔴 خطر مرتفع - يرجى مراجعة الطبيب فوراً';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // مقياس دائري باستخدام CustomPaint
            SizedBox(
              height: 180,
              width: 180,
              child: CustomPaint(
                painter: _RiskGaugePainter(
                  percentage: riskPercentage / 100,
                  color: color,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${riskPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'نسبة الخطر',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // مستوى الخطر
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: color),
              ),
              child: Text(
                riskLevel,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // رسالة
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskGaugePainter extends CustomPainter {
  final double percentage;
  final Color color;

  _RiskGaugePainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 15.0;
    final innerRadius = radius - strokeWidth / 2;

    // الخلفية
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, innerRadius, backgroundPaint);

    // المقدمة (النسبة)
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      -3.14159 / 2, // بداية من الأعلى
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
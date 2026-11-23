import 'package:flutter/material.dart';

import 'duo_theme.dart';

enum AvatarMood { idle, thinking, happy, error }

/// Mascotta ufficiale: un pinguino che cambia espressione con lo stato del tutor.
class PenguinMascot extends StatelessWidget {
  final AvatarMood mood;
  final double size;
  final Color scarfColor;
  final bool showShadow;

  const PenguinMascot({
    super.key,
    this.mood = AvatarMood.idle,
    this.size = 72,
    this.scarfColor = DuoColors.yellow,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _PenguinPainter(mood: mood, scarf: scarfColor, showShadow: showShadow),
    );
  }
}

/// Nome storico usato dalla home: ora disegna il pinguino.
class TutorAvatar extends StatelessWidget {
  final AvatarMood mood;
  final double size;

  const TutorAvatar({super.key, required this.mood, this.size = 68});

  @override
  Widget build(BuildContext context) => PenguinMascot(mood: mood, size: size);
}

/// Decorazione con tre pinguini, usata nelle schermate vuote e nel login.
class PenguinParade extends StatelessWidget {
  final double size;
  final List<Color> scarves;

  const PenguinParade({
    super.key,
    this.size = 54,
    this.scarves = const [DuoColors.yellow, DuoColors.blue, DuoColors.purple],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PenguinMascot(size: size * 0.82, scarfColor: scarves[0], mood: AvatarMood.idle),
        PenguinMascot(size: size, scarfColor: scarves[1], mood: AvatarMood.happy),
        PenguinMascot(size: size * 0.82, scarfColor: scarves[2], mood: AvatarMood.idle),
      ],
    );
  }
}

class _PenguinPainter extends CustomPainter {
  final AvatarMood mood;
  final Color scarf;
  final bool showShadow;

  static const _body = Color(0xFF26324A);
  static const _bodyLight = Color(0xFF3A4A66);
  static const _white = Color(0xFFFFFFFF);
  static const _beak = Color(0xFFFFA726);
  static const _beakDark = Color(0xFFF57C00);
  static const _ink = Color(0xFF1B2440);

  _PenguinPainter({required this.mood, required this.scarf, required this.showShadow});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final happy = mood == AvatarMood.happy;
    final thinking = mood == AvatarMood.thinking;
    final error = mood == AvatarMood.error;

    if (showShadow) {
      canvas.drawOval(
        Rect.fromLTWH(w * 0.18, h * 0.88, w * 0.64, h * 0.10),
        Paint()..color = const Color(0x22000000),
      );
    }

    // Zampe arancioni.
    final feet = Paint()..color = _beak;
    canvas.drawOval(Rect.fromLTWH(w * 0.24, h * 0.80, w * 0.24, h * 0.11), feet);
    canvas.drawOval(Rect.fromLTWH(w * 0.52, h * 0.80, w * 0.24, h * 0.11), feet);

    // Ali: in alto quando è felice.
    final wingAngle = happy ? -0.65 : thinking ? 0.28 : 0.12;
    _drawWing(canvas, w, h, left: true, angle: wingAngle);
    _drawWing(canvas, w, h, left: false, angle: -wingAngle);

    // Corpo e testa.
    canvas.drawOval(
      Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.64, h * 0.70),
      Paint()..color = _body,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.30), w * 0.235, Paint()..color = _body);

    // Pancia e maschera bianca.
    canvas.drawOval(
      Rect.fromLTWH(w * 0.31, h * 0.38, w * 0.38, h * 0.46),
      Paint()..color = _white,
    );
    canvas.drawOval(
      Rect.fromLTWH(w * 0.34, h * 0.17, w * 0.32, h * 0.27),
      Paint()..color = _white,
    );

    // Sciarpa colorata.
    _drawScarf(canvas, w, h);

    // Occhi.
    final eyeY = h * 0.285;
    final eyeGap = w * 0.082;
    final eyeR = w * 0.033;
    if (happy) {
      final line = Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022
        ..strokeCap = StrokeCap.round;
      for (final x in [w * 0.5 - eyeGap, w * 0.5 + eyeGap]) {
        final arc = Path()
          ..moveTo(x - eyeR * 1.2, eyeY + eyeR * 0.3)
          ..quadraticBezierTo(x, eyeY - eyeR * 1.5, x + eyeR * 1.2, eyeY + eyeR * 0.3);
        canvas.drawPath(arc, line);
      }
    } else {
      for (final x in [w * 0.5 - eyeGap, w * 0.5 + eyeGap]) {
        canvas.drawCircle(Offset(x, eyeY), eyeR, Paint()..color = _ink);
        canvas.drawCircle(
          Offset(x - eyeR * 0.3, eyeY - eyeR * 0.3),
          eyeR * 0.32,
          Paint()..color = _white,
        );
      }
    }

    // Sopracciglia: pensieroso / preoccupato.
    if (thinking || error) {
      final brow = Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018
        ..strokeCap = StrokeCap.round;
      final leftY = error ? h * 0.215 : h * 0.205;
      canvas.drawLine(Offset(w * 0.39, leftY), Offset(w * 0.47, h * 0.22), brow);
      canvas.drawLine(Offset(w * 0.53, h * 0.22), Offset(w * 0.61, error ? h * 0.215 : h * 0.195), brow);
    }

    // Becco.
    final beakPath = Path()
      ..moveTo(w * 0.5 - w * 0.055, h * 0.345)
      ..lineTo(w * 0.5 + w * 0.055, h * 0.345)
      ..lineTo(w * 0.5, h * 0.415)
      ..close();
    canvas.drawPath(beakPath, Paint()..color = _beak);
    final lowerBeak = Path()
      ..moveTo(w * 0.5 - w * 0.04, h * 0.385)
      ..lineTo(w * 0.5 + w * 0.04, h * 0.385)
      ..lineTo(w * 0.5, h * 0.425)
      ..close();
    canvas.drawPath(lowerBeak, Paint()..color = _beakDark);

    if (happy) _drawHearts(canvas, w, h);
    if (thinking) _drawThought(canvas, w, h);
    if (error) _drawSweat(canvas, w, h);

    // Riflesso morbido sul corpo.
    canvas.drawOval(
      Rect.fromLTWH(w * 0.24, h * 0.50, w * 0.08, h * 0.20),
      Paint()..color = _bodyLight.withValues(alpha: 0.55),
    );
  }

  void _drawWing(Canvas canvas, double w, double h, {required bool left, required double angle}) {
    final pivotX = left ? w * 0.22 : w * 0.78;
    final pivotY = h * 0.52;
    canvas.save();
    canvas.translate(pivotX, pivotY);
    canvas.rotate(left ? angle : -angle);
    canvas.drawOval(
      Rect.fromLTWH(-w * 0.075, -h * 0.16, w * 0.15, h * 0.32),
      Paint()..color = _body,
    );
    canvas.restore();
  }

  void _drawScarf(Canvas canvas, double w, double h) {
    final paint = Paint()..color = scarf;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.30, h * 0.435, w * 0.40, h * 0.085),
      Radius.circular(h * 0.035),
    );
    canvas.drawRRect(rrect, paint);
    final tail = Path()
      ..moveTo(w * 0.62, h * 0.48)
      ..lineTo(w * 0.72, h * 0.62)
      ..lineTo(w * 0.64, h * 0.66)
      ..lineTo(w * 0.58, h * 0.51)
      ..close();
    canvas.drawPath(tail, paint..color = scarf.withValues(alpha: 0.85));
    canvas.drawLine(
      Offset(w * 0.32, h * 0.51),
      Offset(w * 0.68, h * 0.51),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..strokeWidth = w * 0.012,
    );
  }

  void _drawHearts(Canvas canvas, double w, double h) {
    final heart = Paint()..color = DuoColors.red;
    for (final offset in [
      Offset(w * 0.10, h * 0.18),
      Offset(w * 0.88, h * 0.26),
    ]) {
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.scale(w * 0.0016);
      final path = Path()
        ..moveTo(0, 10)
        ..cubicTo(-18, -8, -8, -22, 0, -12)
        ..cubicTo(8, -22, 18, -8, 0, 10)
        ..close();
      canvas.drawPath(path, heart);
      canvas.restore();
    }
  }

  void _drawThought(Canvas canvas, double w, double h) {
    final bubble = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.82, h * 0.18), w * 0.12, bubble);
    canvas.drawCircle(Offset(w * 0.72, h * 0.12), w * 0.045, bubble);
    canvas.drawCircle(Offset(w * 0.66, h * 0.09), w * 0.022, bubble);
    final textPainter = TextPainter(
      text: const TextSpan(text: '?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: DuoColors.blue)),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(w * 0.82 - textPainter.width / 2, h * 0.18 - textPainter.height / 2));
  }

  void _drawSweat(Canvas canvas, double w, double h) {
    final drop = Path()
      ..moveTo(w * 0.86, h * 0.20)
      ..cubicTo(w * 0.91, h * 0.27, w * 0.90, h * 0.34, w * 0.86, h * 0.34)
      ..cubicTo(w * 0.82, h * 0.34, w * 0.81, h * 0.27, w * 0.86, h * 0.20)
      ..close();
    canvas.drawPath(drop, Paint()..color = DuoColors.blue);
  }

  @override
  bool shouldRepaint(covariant _PenguinPainter old) =>
      old.mood != mood || old.scarf != scarf || old.showShadow != showShadow;
}

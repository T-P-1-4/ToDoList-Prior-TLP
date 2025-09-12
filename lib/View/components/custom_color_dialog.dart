import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controller/controller.dart';
import '../../Controller/colors.dart';

class CustomColorDialog extends StatefulWidget {
  const CustomColorDialog({super.key});

  @override
  State<CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<CustomColorDialog> {
  HSVColor currentColor = HSVColor.fromAHSV(1, 0, 1, 1);

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<AppColorController>(context, listen: false);
    final custom = controller.getCustomColor();
    if (custom != null) {
      currentColor = HSVColor.fromColor(custom);
    } else {
      currentColor = HSVColor.fromAHSV(1, 0, 1, 1);
    }
  }

  void _onPan(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    final distance = sqrt(dx * dx + dy * dy);
    final radius = size.width / 2;

    if (distance > radius) return;

    final hue = (atan2(dy, dx) * 180 / pi + 360) % 360;
    final saturation = (distance / radius).clamp(0.0, 1.0);

    setState(() {
      currentColor = HSVColor.fromAHSV(1.0, hue, saturation, 1.0);
    });
  }

  void _submit() {
    final color = currentColor.toColor();

    final colorController = Provider.of<AppColorController>(context, listen: false);
    colorController.setCustomColorScheme(color);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = currentColor.toColor();

    return AlertDialog(
      title: Text(Controller.getTextLabel('Custom_Color')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanUpdate: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final local = box.globalToLocal(details.globalPosition);
                    _onPan(local, constraints.biggest);
                  },
                  onTapDown: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final local = box.globalToLocal(details.globalPosition);
                    _onPan(local, constraints.biggest);
                  },
                  child: CustomPaint(
                    painter: HSVColorWheelPainter(currentColor),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(Controller.getTextLabel('Selected_Color')),
          const SizedBox(height: 6),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(Controller.getTextLabel('Cancel'),
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(Controller.getTextLabel('Confirm'),
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }
}

class HSVColorWheelPainter extends CustomPainter {
  final HSVColor selected;

  HSVColorWheelPainter(this.selected);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final sweepGradient = SweepGradient(
      colors: List.generate(361, (i) => HSVColor.fromAHSV(1, i.toDouble(), 1, 1).toColor()),
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    final radialGradient = RadialGradient(
      colors: [Colors.white.withOpacity(0), Colors.white],
    );

    final overlayPaint = Paint()
      ..shader = radialGradient.createShader(rect)
      ..blendMode = BlendMode.overlay;

    canvas.drawCircle(center, radius, overlayPaint);

    final angle = selected.hue * pi / 180;
    final satRadius = selected.saturation * radius;
    final pointer = Offset(
      center.dx + satRadius * cos(angle),
      center.dy + satRadius * sin(angle),
    );

    final pointerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pointer, 6, pointerPaint);
    canvas.drawCircle(pointer, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

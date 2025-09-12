import 'package:flutter/material.dart';
import 'package:todo_appdev/Controller/controller.dart';

class WSMDialog extends StatefulWidget {
  const WSMDialog({super.key});

  @override
  State<WSMDialog> createState() => _WSMDialogState();
}

class _WSMDialogState extends State<WSMDialog> {
  Offset point = const Offset(0.33, 0.33);
  List<int> savedWeights = [33, 33, 34];

  @override
  void initState() {
    super.initState();
    Controller.readHiveWSM().then((value) {
      setState(() {
        savedWeights = value;
        point = Offset(1 / 3, 1 / 3);
      });
    });
  }

  void _onPanStart(Offset localPosition, Size size) {
    _onPanUpdate(localPosition, size);
  }

  void _onPanUpdate(Offset localPosition, Size size) {
    // Begrenzung; Punkt liegt innerhalb ds Dreiecks
    final Offset a = Offset(size.width / 2, 0);               // Priority
    final Offset b = Offset(0, size.height);                  // Duration
    final Offset c = Offset(size.width, size.height);         // Deadline

    final Offset p = localPosition;

    final v0 = b - a;
    final v1 = c - a;
    final v2 = p - a;

    final d00 = v0.dx * v0.dx + v0.dy * v0.dy;
    final d01 = v0.dx * v1.dx + v0.dy * v1.dy;
    final d11 = v1.dx * v1.dx + v1.dy * v1.dy;
    final d20 = v2.dx * v0.dx + v2.dy * v0.dy;
    final d21 = v2.dx * v1.dx + v2.dy * v1.dy;

    final denom = d00 * d11 - d01 * d01;

    double v = (d11 * d20 - d01 * d21) / denom;
    double w = (d00 * d21 - d01 * d20) / denom;
    double u = 1.0 - v - w;

    u = u.clamp(0.0, 1.0);
    v = v.clamp(0.0, 1.0 - u);
    w = (1.0 - u - v).clamp(0.0, 1.0);

    setState(() {
      point = Offset(u, v);
      savedWeights = [
        (u * 100).round(),
        (v * 100).round(),
        (w * 100).round(),
      ];
    });
  }

  void _submit() {
    Controller.writeHiveWSM(
      savedWeights[0],
      savedWeights[1],
      savedWeights[2],
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(Controller.getTextLabel('Prio_WSM')),
      content: SizedBox(
        width: 300,
        height: 380,
        child: Column(
          children: [
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: Center(
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onPanStart: (details) {
                          final box = context.findRenderObject() as RenderBox;
                          final local = box.globalToLocal(details.globalPosition);
                          _onPanStart(local, constraints.biggest);
                        },
                        onPanUpdate: (details) {
                          final box = context.findRenderObject() as RenderBox;
                          final local = box.globalToLocal(details.globalPosition);
                          _onPanUpdate(local, constraints.biggest);
                        },
                        child: CustomPaint(
                          painter: TrianglePainter(
                            weights: savedWeights,
                            color: scheme.primary,
                          ),
                          child: Container(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Priority: ${savedWeights[0]}%"),
            Text("Duration: ${savedWeights[1]}%"),
            Text("Deadline: ${savedWeights[2]}%"),
          ],
        ),
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

class TrianglePainter extends CustomPainter {
  final List<int> weights;
  final Color color;

  TrianglePainter({required this.weights, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final helper = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 0.6;

    final markerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Offset a = Offset(size.width / 2, 0);               // Priority
    final Offset b = Offset(0, size.height);                  // Duration
    final Offset c = Offset(size.width, size.height);         // Deadline

    final triangle = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();

    canvas.drawPath(triangle, paint);
    canvas.drawPath(triangle, border);

    // Linienstruktur im Inneren mit linearer interpolation
    const int steps = 10;

    for (int i = 1; i < steps; i++) {
      final t = i / steps;

      // Linie von einem Punkt auf AB zur Ecke C
      final ab = Offset.lerp(a, b, t)!;
      final abToC = Offset.lerp(ab, c, 1.0)!;
      canvas.drawLine(ab, abToC, helper);

      // Linie von einem Punkt auf BC zur Ecke A
      final bc = Offset.lerp(b, c, t)!;
      final bcToA = Offset.lerp(bc, a, 1.0)!;
      canvas.drawLine(bc, bcToA, helper);

      // Linie von einem Punkt auf CA zur Ecke B
      final ca = Offset.lerp(c, a, t)!;
      final caToB = Offset.lerp(ca, b, 1.0)!;
      canvas.drawLine(ca, caToB, helper);
    }

    // Auswahlpunkt
    final u = weights[0] / 100;
    final v = weights[1] / 100;
    final w = 1 - u - v;
    final point = Offset(
      a.dx * u + b.dx * v + c.dx * w,
      a.dy * u + b.dy * v + c.dy * w,
    );
    canvas.drawCircle(point, 8, markerPaint);

    // Beschriftung
    final textStyle = TextStyle(
      color: Colors.black54,
      fontWeight: FontWeight.bold,
    );

    final tp1 = TextPainter(
      text: TextSpan(text: 'Priority', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final tp2 = TextPainter(
      text: TextSpan(text: 'Duration', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final tp3 = TextPainter(
      text: TextSpan(text: 'Deadline', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    tp1.paint(canvas, a.translate(-tp1.width / 2, -20));
    tp2.paint(canvas, b.translate(-tp2.width - 4, -4));
    tp3.paint(canvas, c.translate(4, -4));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

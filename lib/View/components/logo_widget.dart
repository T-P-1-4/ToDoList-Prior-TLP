import 'package:flutter/material.dart';

class ColoredLogo extends StatelessWidget {
  final Color color;
  final double size;

  const ColoredLogo({
    super.key,
    required this.color,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/config/logo_transparent_cropped.png',
      height: size,
      width: size,
      color: color,
      colorBlendMode: BlendMode.srcIn,
    );
  }
}

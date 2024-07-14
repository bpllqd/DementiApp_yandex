import 'package:demetiapp/core/utils/utils.dart';
import 'package:flutter/material.dart';

class CheckBoxButton extends StatelessWidget {
  final String imagePath;
  final int? color;
  final VoidCallback onTap;

  const CheckBoxButton({
    super.key,
    required this.imagePath,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashRadius: 18.0,
      onPressed: onTap,
      icon: SVG(
        imagePath: imagePath,
        color: color,
      ),
    );
  }
}

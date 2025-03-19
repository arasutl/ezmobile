import 'package:ez/core/CustomColors.dart';
import 'package:flutter/material.dart';

import '../config/theme.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    this.color = BrandColors.primary,
    this.isRounded = false,
    this.isFullWidth = false,
    this.isLoading = false,
    required this.label,
    required this.onPressed,
  });

  final Color color;
  final bool isRounded;
  final bool isFullWidth;
  final bool isLoading;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
        minimumSize: MaterialStateProperty.all(
          Size(
            isFullWidth ? double.maxFinite : double.minPositive,
            0,
          ),
        ),
        padding: MaterialStateProperty.all(
          EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isLoading ? 4 : 10,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isRounded ? 48 : 5),
          ),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator(backgroundColor: Colors.white)
          : Text(
              label,
              style: const TextStyle(
                  color: CustomColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/colors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // ← nullable now
  final LinearGradient gradient;
  final IconData? suffixIcon;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.gradient = AppColors.caretakerButtonGradient,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5733).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed != null ? () => onPressed!() : null, // ← fixed
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (suffixIcon != null)
                    Icon(
                      suffixIcon,
                      color: Colors.white,
                      size: 28,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

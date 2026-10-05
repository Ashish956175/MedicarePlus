import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'glass_container.dart';

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData? icon;
  final bool isLoading;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: GlassContainer(
            borderRadius: 16,
            opacity: 0.15,
            blur: 10,
            color: primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, color: primaryColor, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

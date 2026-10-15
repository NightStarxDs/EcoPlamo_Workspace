import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class EcoPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;

  const EcoPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.height = 52,
    this.borderRadius = 12,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.6),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTypography.button(color: textColor),
                  ),
                ],
              ),
      ),
    );
  }
}

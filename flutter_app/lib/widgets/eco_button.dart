import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class EcoPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;
  final List<BoxShadow>? boxShadow;

  const EcoPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.height = 48,
    this.borderRadius = AppRadius.input,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.icon,
    this.boxShadow,
  });

  @override
  State<EcoPrimaryButton> createState() => _EcoPrimaryButtonState();
}

class _EcoPrimaryButtonState extends State<EcoPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: const Cubic(0.16, 1, 0.3, 1),
      child: Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.boxShadow,
        ),
        child: Listener(
          onPointerDown: (_) {
            if (!widget.isLoading && widget.onPressed != null) {
              setState(() => _isPressed = true);
            }
          },
          onPointerUp: (_) {
            if (_isPressed) setState(() => _isPressed = false);
          },
          onPointerCancel: (_) {
            if (_isPressed) setState(() => _isPressed = false);
          },
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor,
              foregroundColor: widget.textColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              disabledBackgroundColor: widget.backgroundColor.withValues(alpha: 0.6),
            ),
            onPressed: widget.isLoading ? null : widget.onPressed,
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        widget.icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: AppTypography.button(color: widget.textColor),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

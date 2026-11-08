import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Nút bấm nền gradient có bóng phát sáng, hỗ trợ trạng thái đang tải.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient gradient;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.gradient = AppTheme.brandGradient,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(AppTheme.radiusMd);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled || isLoading ? 1 : 0.55,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: radius,
          boxShadow: enabled ? AppTheme.glowShadow() : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: enabled ? onPressed : null,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        key: const ValueKey('label'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ô vuông bo góc chứa icon trên nền gradient.
class GradientIconBox extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final double size;
  final double iconSize;
  final double radius;
  final bool glow;

  const GradientIconBox({
    super.key,
    required this.icon,
    this.gradient = AppTheme.brandGradient,
    this.size = 44,
    this.iconSize = 22,
    this.radius = 14,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: glow ? AppTheme.glowShadow(gradient.colors.last) : null,
      ),
      child: Icon(icon, color: Colors.white, size: iconSize),
    );
  }
}

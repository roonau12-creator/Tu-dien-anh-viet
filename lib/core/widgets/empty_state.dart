import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Trạng thái trống dùng chung cho danh sách, tìm kiếm, ...
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = AppTheme.gradientFor(color);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          builder: (context, t, child) => Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, 16 * (1 - t)),
              child: child,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.06),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.10),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: gradient,
                      boxShadow: AppTheme.glowShadow(gradient.colors.last),
                    ),
                    child: Icon(icon, size: 30, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

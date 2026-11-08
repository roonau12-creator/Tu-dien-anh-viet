import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Nền gradient nhẹ kèm các "đốm sáng" trang trí mờ dùng cho các màn hình nội dung.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: Stack(
        children: [
          const Positioned(
            top: -120,
            right: -90,
            child: GlowBlob(size: 300, color: AppTheme.violet, opacity: 0.12),
          ),
          const Positioned(
            bottom: -140,
            left: -110,
            child: GlowBlob(size: 320, color: AppTheme.blue, opacity: 0.10),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

/// Một đốm sáng tròn mờ dần (radial gradient) dùng làm hoạ tiết nền.
class GlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const GlowBlob({
    super.key,
    required this.size,
    required this.color,
    this.opacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

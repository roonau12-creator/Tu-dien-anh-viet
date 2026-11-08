import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Thẻ hiển thị một mục từ trong danh sách (tra cứu, yêu thích, lịch sử).
class WordCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? tag;
  final String? leadingText;
  final IconData? leadingIcon;
  final Color accentColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Vị trí trong danh sách – dùng để tạo hiệu ứng xuất hiện so le.
  final int index;

  const WordCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.tag,
    this.leadingText,
    this.leadingIcon,
    this.accentColor = AppTheme.primary,
    this.trailing,
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = AppTheme.gradientFor(accentColor);
    final radius = BorderRadius.circular(AppTheme.radiusLg);

    // Hiệu ứng trượt + mờ dần, các phần tử sau xuất hiện chậm hơn một chút.
    final step = math.min(index, 8);
    final total = 320 + step * 45;
    final start = (step * 45) / total;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - t)),
          child: child,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          boxShadow: AppTheme.softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.colors.last.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: leadingIcon != null
                        ? Icon(leadingIcon, size: 23, color: Colors.white)
                        : Text(
                            (leadingText == null ||
                                    leadingText!.trim().isEmpty)
                                ? '?'
                                : leadingText!.trim()[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                            if (tag != null && tag!.trim().isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.09),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  tag!,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  trailing ??
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppTheme.primary,
                        ),
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

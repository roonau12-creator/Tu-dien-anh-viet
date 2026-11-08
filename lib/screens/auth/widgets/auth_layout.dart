import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_background.dart';

/// Bố cục dùng chung cho màn hình Đăng nhập / Đăng ký:
/// nền gradient + hoạ tiết, logo kính mờ và thẻ form bo góc lớn.
class AuthLayout extends StatelessWidget {
  final IconData brandIcon;
  final String brandTitle;
  final String brandSubtitle;
  final String formTitle;
  final String formSubtitle;
  final Widget form;
  final bool showBack;

  const AuthLayout({
    super.key,
    required this.brandIcon,
    required this.brandTitle,
    required this.brandSubtitle,
    required this.formTitle,
    required this.formSubtitle,
    required this.form,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.authGradient),
          child: Stack(
            children: [
              const Positioned(
                top: -80,
                left: -60,
                child: GlowBlob(size: 280, color: Colors.white, opacity: 0.16),
              ),
              const Positioned(
                bottom: -120,
                right: -80,
                child: GlowBlob(
                  size: 340,
                  color: Color(0xFFC4B5FD),
                  opacity: 0.30,
                ),
              ),
              const Positioned(
                top: 180,
                right: -40,
                child: GlowBlob(
                  size: 160,
                  color: Color(0xFF7DD3FC),
                  opacity: 0.25,
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, showBack ? 56 : 24, 24, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, child) => Opacity(
                          opacity: t,
                          child: Transform.translate(
                            offset: Offset(0, 24 * (1 - t)),
                            child: child,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildBrand(),
                            const SizedBox(height: 30),
                            _buildCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (showBack)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: IconButton(
                      tooltip: 'Quay lại',
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.30),
                Colors.white.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Icon(brandIcon, size: 42, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          brandTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          brandSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.78),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.30),
            blurRadius: 50,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            formTitle,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formSubtitle,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          form,
        ],
      ),
    );
  }
}

/// Dòng phân cách "hoặc" + liên kết chuyển màn hình ở cuối form.
class AuthSwitchLink extends StatelessWidget {
  final String question;
  final String action;
  final VoidCallback onTap;

  const AuthSwitchLink({
    super.key,
    required this.question,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'hoặc',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: onTap,
          child: Text.rich(
            TextSpan(
              text: '$question ',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: action,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

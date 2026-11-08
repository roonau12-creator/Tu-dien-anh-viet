import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_background.dart';
import '../../services/firebase_service.dart';
import '../dictionary/add_edit_word_screen.dart';
import '../dictionary/search_tab.dart';
import '../favorites/favorites_tab.dart';
import '../history/history_tab.dart';
import 'widgets/stats_banner.dart';

class MainScreen extends StatefulWidget {
  final String currentUserId;
  final String displayUsername;

  const MainScreen({
    super.key,
    required this.currentUserId,
    required this.displayUsername,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    _TabInfo(Icons.search_rounded, Icons.search_rounded, 'Tra cứu'),
    _TabInfo(
      Icons.favorite_outline_rounded,
      Icons.favorite_rounded,
      'Yêu thích',
    ),
    _TabInfo(Icons.history_outlined, Icons.history_rounded, 'Lịch sử'),
  ];

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.logout_rounded,
          color: AppTheme.primary,
          size: 30,
        ),
        title: const Text('Đăng xuất'),
        content: Text(
          'Bạn có muốn đăng xuất khỏi tài khoản "${widget.displayUsername}" không?',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseService.logout();
    }
  }

  void _openAddWord() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditWordScreen()),
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Chào buổi sáng';
    if (hour < 14) return 'Chào buổi trưa';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBody: true,
        body: AppBackground(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    SearchTab(userId: widget.currentUserId),
                    FavoritesTab(userId: widget.currentUserId),
                    HistoryTab(userId: widget.currentUserId),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _FloatingNavBar(
          tabs: _tabs,
          selectedIndex: _selectedIndex,
          onSelected: (idx) => setState(() => _selectedIndex = idx),
        ),
        floatingActionButton: AnimatedScale(
          scale: _selectedIndex == 0 ? 1 : 0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: _GradientFab(onPressed: _openAddWord),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final username = widget.displayUsername.trim();
    final initial = username.isEmpty ? '?' : username[0].toUpperCase();

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: AppTheme.glowShadow(AppTheme.primary),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -60,
              right: -40,
              child: GlowBlob(size: 200, color: Colors.white, opacity: 0.22),
            ),
            const Positioned(
              bottom: -70,
              left: -30,
              child: GlowBlob(
                size: 180,
                color: Color(0xFF7DD3FC),
                opacity: 0.30,
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_greeting 👋',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Đăng xuất',
                          onPressed: _confirmLogout,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.16),
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.logout_rounded, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: StatsBanner(userId: widget.currentUserId),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabInfo {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _TabInfo(this.icon, this.selectedIcon, this.label);
}

/// Thanh điều hướng dạng "viên thuốc" nổi phía dưới màn hình.
class _FloatingNavBar extends StatelessWidget {
  final List<_TabInfo> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FloatingNavBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B3F8F).withValues(alpha: 0.14),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final tab = tabs[i];
            final selected = i == selectedIndex;
            return Expanded(
              flex: selected ? 5 : 3,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: selected ? AppTheme.brandGradient : null,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: selected ? AppTheme.glowShadow() : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? tab.selectedIcon : tab.icon,
                        size: 23,
                        color: selected ? Colors.white : AppTheme.textMuted,
                      ),
                      if (selected) ...[
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            tab.label,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _GradientFab extends StatelessWidget {
  final VoidCallback onPressed;

  const _GradientFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: radius,
        boxShadow: AppTheme.glowShadow(AppTheme.violet),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: 6),
                Text(
                  'Thêm từ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

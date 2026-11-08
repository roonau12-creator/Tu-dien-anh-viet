import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/gradient_button.dart';
import '../../models/word_entry.dart';
import '../../services/firebase_service.dart';
import 'add_edit_word_screen.dart';

class WordDetailScreen extends StatefulWidget {
  final String wordId;
  final String userId;

  const WordDetailScreen({
    super.key,
    required this.wordId,
    required this.userId,
  });

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late Future<WordEntry?> _wordFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _wordFuture = FirebaseService.getWordById(widget.wordId);
  }

  void _reload() {
    setState(() {
      _wordFuture = FirebaseService.getWordById(widget.wordId);
    });
  }

  Future<void> _openEdit(WordEntry word) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditWordScreen(existingWord: word),
      ),
    );
    if (mounted) _reload();
  }

  Future<void> _confirmDelete(BuildContext context, WordEntry word) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_forever_rounded,
            color: AppTheme.danger,
            size: 30,
          ),
        ),
        title: const Text('Xác nhận xóa mục từ'),
        content: Text(
          'Bạn có chắc chắn muốn xóa mục từ "${word.vietnamese} – ${word.english}"?\n\n'
          'Lưu ý: Mọi bản ghi yêu thích và lịch sử liên quan đến mục từ này sẽ bị xóa khỏi đám mây.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.danger,
              minimumSize: const Size(0, 44),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      setState(() => _isDeleting = true);
      final error = await FirebaseService.deleteWordCascade(word.id);
      if (mounted) setState(() => _isDeleting = false);
      if (!context.mounted) return;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.danger,
          ),
        );
        return;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa mục từ và các dữ liệu liên quan.'),
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _toggleFavorite(WordEntry word, bool isFav) async {
    HapticFeedback.lightImpact();
    await FirebaseService.toggleFavorite(widget.userId, word.id);
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isFav
              ? 'Đã bỏ khỏi danh sách yêu thích.'
              : 'Đã thêm vào danh sách yêu thích.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({List<Widget> actions = const []}) {
    return AppBar(
      title: const Text('Chi tiết mục từ'),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Center(
          child: _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Quay lại',
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
      ),
      leadingWidth: 64,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WordEntry?>(
      future: _wordFuture,
      builder: (context, wordSnap) {
        if (wordSnap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: _buildAppBar(),
            extendBodyBehindAppBar: true,
            body: const AppBackground(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final word = wordSnap.data;
        if (word == null) {
          return Scaffold(
            appBar: _buildAppBar(),
            extendBodyBehindAppBar: true,
            body: const AppBackground(
              child: EmptyState(
                icon: Icons.menu_book_rounded,
                title: 'Không tìm thấy mục từ',
                message:
                    'Mục từ này đã bị xóa hoặc không còn tồn tại trong từ điển.',
              ),
            ),
          );
        }

        return StreamBuilder<bool>(
          stream: FirebaseService.isFavoriteStream(widget.userId, word.id),
          builder: (context, favSnap) {
            final isFav = favSnap.data ?? false;

            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: _buildAppBar(
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _CircleIconButton(
                      tooltip: isFav ? 'Bỏ yêu thích' : 'Đánh dấu yêu thích',
                      onPressed: () => _toggleFavorite(word, isFav),
                      icon: isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? AppTheme.danger : AppTheme.textSecondary,
                      background: isFav
                          ? AppTheme.danger.withValues(alpha: 0.12)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
              body: AppBackground(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    child: Column(
                      children: [
                        _WordHero(word: word, isFavorite: isFav),
                        const SizedBox(height: 16),
                        _ExampleCard(example: word.example),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: GradientButton(
                                label: 'Chỉnh sửa',
                                icon: Icons.edit_rounded,
                                onPressed: () => _openEdit(word),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 54,
                                child: OutlinedButton.icon(
                                  onPressed: _isDeleting
                                      ? null
                                      : () => _confirmDelete(context, word),
                                  icon: _isDeleting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.danger,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 20,
                                        ),
                                  label: const Text('Xóa'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.danger,
                                    backgroundColor:
                                        AppTheme.danger.withValues(alpha: 0.05),
                                    side: BorderSide(
                                      color: AppTheme.danger
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;
  final Color background;

  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = AppTheme.textPrimary,
    this.background = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppTheme.softShadow,
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: background,
          foregroundColor: color,
          fixedSize: const Size(44, 44),
        ),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(icon, key: ValueKey(icon), size: 22),
        ),
      ),
    );
  }
}

class _WordHero extends StatelessWidget {
  final WordEntry word;
  final bool isFavorite;

  const _WordHero({required this.word, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.35),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                right: -70,
                top: -70,
                child: GlowBlob(size: 220, color: Colors.white, opacity: 0.22),
              ),
              const Positioned(
                left: -60,
                bottom: -90,
                child: GlowBlob(
                  size: 200,
                  color: Color(0xFF7DD3FC),
                  opacity: 0.35,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GlassPill(
                        icon: Icons.category_rounded,
                        text: word.wordType,
                      ),
                      if (isFavorite) ...[
                        const SizedBox(width: 8),
                        const _GlassPill(
                          icon: Icons.favorite_rounded,
                          text: 'Yêu thích',
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _LangLabel(code: 'VI', label: 'TIẾNG VIỆT'),
                  const SizedBox(height: 8),
                  Text(
                    word.vietnamese,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.6,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          child: const Icon(
                            Icons.south_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _LangLabel(code: 'EN', label: 'TIẾNG ANH'),
                  const SizedBox(height: 8),
                  Text(
                    word.english,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.96),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '#${word.id}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GlassPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LangLabel extends StatelessWidget {
  final String code;
  final String label;

  const _LangLabel({required this.code, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            code,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String example;

  const _ExampleCard({required this.example});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              GradientIconBox(
                icon: Icons.format_quote_rounded,
                gradient: AppTheme.skyGradient,
                size: 38,
                iconSize: 20,
                radius: 12,
              ),
              SizedBox(width: 12),
              Text(
                'Câu ví dụ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: Container(
              color: AppTheme.surfaceSoft,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 4,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.blue, AppTheme.violet],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                        child: Text(
                          example,
                          style: const TextStyle(
                            fontSize: 15.5,
                            color: AppTheme.textPrimary,
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

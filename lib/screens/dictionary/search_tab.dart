import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/word_card.dart';
import '../../models/word_entry.dart';
import '../../services/firebase_service.dart';
import 'word_detail_screen.dart';

class SearchTab extends StatefulWidget {
  final String userId;

  const SearchTab({super.key, required this.userId});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String _direction = 'VI_EN';
  String _query = '';
  double _swapTurns = 0;
  final _searchController = TextEditingController();

  bool get _isViEn => _direction == 'VI_EN';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _swapDirection() {
    setState(() {
      _direction = _isViEn ? 'EN_VI' : 'VI_EN';
      _swapTurns += 0.5;
    });
  }

  Future<void> _openWord(WordEntry word) async {
    try {
      await FirebaseService.addHistory(
        userId: widget.userId,
        wordId: word.id,
        direction: _direction,
      );
    } catch (_) {
      // Không chặn việc mở chi tiết nếu ghi lịch sử thất bại.
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WordDetailScreen(
          wordId: word.id,
          userId: widget.userId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl - 4),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              children: [
                _buildLanguageSwitcher(),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _query = val),
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: _isViEn
                        ? 'Nhập từ tiếng Việt cần tra...'
                        : 'Nhập từ tiếng Anh cần tra...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            tooltip: 'Xóa tìm kiếm',
                            icon: const Icon(Icons.cancel_rounded, size: 20),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<WordEntry>>(
            stream: FirebaseService.getWordsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allWords = snapshot.data ?? [];
              final cleanQuery = _query.trim().toLowerCase();

              final filtered = allWords.where((word) {
                if (cleanQuery.isEmpty) return true;
                if (_isViEn) {
                  return word.normalizedVi.contains(cleanQuery);
                }
                return word.normalizedEn.contains(cleanQuery);
              }).toList();

              if (filtered.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Không tìm thấy mục từ',
                  message: cleanQuery.isEmpty
                      ? 'Từ điển chưa có mục từ nào. Hãy thêm từ mới bằng nút "Thêm từ".'
                      : 'Không có kết quả cho "$cleanQuery". Thử từ khóa khác nhé.',
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                    child: Row(
                      children: [
                        Text(
                          cleanQuery.isEmpty ? 'Tất cả mục từ' : 'Kết quả',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.brandGradient,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${filtered.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 180),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final word = filtered[index];
                        final primary =
                            _isViEn ? word.vietnamese : word.english;
                        final secondary =
                            _isViEn ? word.english : word.vietnamese;

                        return WordCard(
                          key: ValueKey('${word.id}_$_direction'),
                          index: index,
                          title: primary,
                          subtitle: secondary,
                          tag: word.wordType,
                          leadingText: primary,
                          accentColor: AppTheme.primary,
                          onTap: () => _openWord(word),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSwitcher() {
    return Row(
      children: [
        Expanded(
          child: _LanguageChip(
            flag: _isViEn ? 'VI' : 'EN',
            label: _isViEn ? 'Tiếng Việt' : 'Tiếng Anh',
            caption: 'Từ',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Tooltip(
            message: 'Đảo chiều tra cứu',
            child: GestureDetector(
              onTap: _swapDirection,
              child: AnimatedRotation(
                turns: _swapTurns,
                duration: const Duration(milliseconds: 380),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.brandGradient,
                    boxShadow: AppTheme.glowShadow(),
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: _LanguageChip(
            flag: _isViEn ? 'EN' : 'VI',
            label: _isViEn ? 'Tiếng Anh' : 'Tiếng Việt',
            caption: 'Sang',
            alignEnd: true,
          ),
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String flag;
  final String label;
  final String caption;
  final bool alignEnd;

  const _LanguageChip({
    required this.flag,
    required this.label,
    required this.caption,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(alignEnd ? -0.25 : 0.25, 0),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(label),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppTheme.surfaceSoft,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Row(
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!alignEnd) ...[
              _CodeBadge(code: flag),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: alignEnd
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    caption,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (alignEnd) ...[
              const SizedBox(width: 8),
              _CodeBadge(code: flag),
            ],
          ],
        ),
      ),
    );
  }
}

class _CodeBadge extends StatelessWidget {
  final String code;

  const _CodeBadge({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppTheme.softShadow,
      ),
      child: ShaderMask(
        shaderCallback: (rect) => AppTheme.brandGradient.createShader(rect),
        child: Text(
          code,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

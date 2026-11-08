import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/word_card.dart';
import '../../models/history_entry.dart';
import '../../models/word_entry.dart';
import '../../services/firebase_service.dart';
import '../dictionary/word_detail_screen.dart';

class HistoryTab extends StatelessWidget {
  final String userId;

  const HistoryTab({super.key, required this.userId});

  Future<void> _confirmDeleteSingle(
    BuildContext context,
    HistoryEntry item,
    String wordTitle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.danger,
            size: 26,
          ),
        ),
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có muốn xóa lượt tra cứu "$wordTitle" lúc ${item.formattedTime} không?',
          textAlign: TextAlign.center,
        ),
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
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseService.deleteHistoryItem(item.id);
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.danger.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_sweep_rounded,
            color: AppTheme.danger,
            size: 28,
          ),
        ),
        title: const Text('Xóa toàn bộ lịch sử'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa toàn bộ lịch sử tra cứu của tài khoản hiện tại không?',
          textAlign: TextAlign.center,
        ),
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
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseService.clearUserHistory(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<HistoryEntry>>(
      stream: FirebaseService.getUserHistoryStream(userId),
      builder: (context, hisSnap) {
        if (hisSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final historyList = hisSnap.data ?? [];

        if (historyList.isEmpty) {
          return const EmptyState(
            icon: Icons.history_toggle_off_rounded,
            title: 'Chưa có lịch sử tra cứu',
            message:
                'Mỗi khi bạn mở xem một từ, lượt tra cứu sẽ tự động được ghi lại tại đây.',
            color: AppTheme.accent,
          );
        }

        return StreamBuilder<List<WordEntry>>(
          stream: FirebaseService.getWordsStream(),
          builder: (context, wordSnap) {
            if (wordSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allWords = wordSnap.data ?? [];
            final wordMap = {for (final w in allWords) w.id: w};

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: AppTheme.skyGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Lịch sử tra cứu',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${historyList.length}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Mới nhất được hiển thị trước',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _confirmClearAll(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            foregroundColor: AppTheme.danger,
                            backgroundColor:
                                AppTheme.danger.withValues(alpha: 0.05),
                            side: BorderSide(
                              color: AppTheme.danger.withValues(alpha: 0.25),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                          label: const Text('Xóa hết'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                    itemCount: historyList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = historyList[index];
                      final word = wordMap[item.wordId];

                      final title = word == null
                          ? 'Mục từ đã bị xóa'
                          : (item.direction == 'VI_EN'
                              ? '${word.vietnamese} ➔ ${word.english}'
                              : '${word.english} ➔ ${word.vietnamese}');

                      return WordCard(
                        key: ValueKey(item.id),
                        index: index,
                        title: title,
                        subtitle: item.formattedTime,
                        tag: item.directionLabel,
                        leadingIcon: Icons.swap_horiz_rounded,
                        accentColor: AppTheme.accent,
                        trailing: IconButton(
                          tooltip: 'Xóa lượt này',
                          onPressed: () =>
                              _confirmDeleteSingle(context, item, title),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.surfaceSoft,
                            foregroundColor: AppTheme.textSecondary,
                            fixedSize: const Size(36, 36),
                          ),
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                          ),
                        ),
                        onTap: word == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WordDetailScreen(
                                      wordId: word.id,
                                      userId: userId,
                                    ),
                                  ),
                                );
                              },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

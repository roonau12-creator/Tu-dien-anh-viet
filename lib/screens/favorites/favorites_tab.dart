import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/word_card.dart';
import '../../models/word_entry.dart';
import '../../services/firebase_service.dart';
import '../dictionary/word_detail_screen.dart';

class FavoritesTab extends StatelessWidget {
  final String userId;

  const FavoritesTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: FirebaseService.getFavoriteWordIdsStream(userId),
      builder: (context, favSnap) {
        if (favSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final favIds = favSnap.data ?? [];

        if (favIds.isEmpty) {
          return const EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'Chưa có từ yêu thích',
            message:
                'Nhấn biểu tượng trái tim khi xem bất kỳ mục từ nào để lưu vào danh sách của bạn.',
            color: AppTheme.danger,
          );
        }

        return StreamBuilder<List<WordEntry>>(
          stream: FirebaseService.getWordsStream(),
          builder: (context, wordSnap) {
            if (wordSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allWords = wordSnap.data ?? [];
            final favoriteWords =
                allWords.where((w) => favIds.contains(w.id)).toList();

            if (favoriteWords.isEmpty) {
              return const EmptyState(
                icon: Icons.favorite_border_rounded,
                title: 'Chưa có từ yêu thích',
                message:
                    'Nhấn biểu tượng trái tim khi xem bất kỳ mục từ nào để lưu vào danh sách của bạn.',
                color: AppTheme.danger,
              );
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
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
                            gradient: AppTheme.dangerGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.danger.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bộ sưu tập của bạn',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Các mục từ quan trọng đã lưu',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.danger.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${favoriteWords.length} từ',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 140),
                    itemCount: favoriteWords.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final word = favoriteWords[index];

                      return WordCard(
                        key: ValueKey(word.id),
                        index: index,
                        title: word.vietnamese,
                        subtitle: word.english,
                        tag: word.wordType,
                        leadingIcon: Icons.favorite_rounded,
                        accentColor: AppTheme.danger,
                        trailing: IconButton(
                          tooltip: 'Bỏ yêu thích',
                          onPressed: () async {
                            await FirebaseService.toggleFavorite(
                              userId,
                              word.id,
                            );
                          },
                          style: IconButton.styleFrom(
                            backgroundColor:
                                AppTheme.danger.withValues(alpha: 0.08),
                            foregroundColor: AppTheme.danger,
                            fixedSize: const Size(36, 36),
                          ),
                          icon: const Icon(
                            Icons.favorite_rounded,
                            size: 19,
                          ),
                        ),
                        onTap: () {
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

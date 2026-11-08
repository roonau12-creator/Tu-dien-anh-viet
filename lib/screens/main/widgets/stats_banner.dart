import 'package:flutter/material.dart';

import '../../../models/history_entry.dart';
import '../../../models/word_entry.dart';
import '../../../services/firebase_service.dart';

/// Dải thống kê kiểu kính mờ, đặt bên trong header gradient.
class StatsBanner extends StatelessWidget {
  final String userId;

  const StatsBanner({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<WordEntry>>(
            stream: FirebaseService.getWordsStream(),
            builder: (context, snapshot) => _StatItem(
              icon: Icons.menu_book_rounded,
              label: 'Mục từ',
              value: snapshot.data?.length ?? 0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StreamBuilder<List<String>>(
            stream: FirebaseService.getFavoriteWordIdsStream(userId),
            builder: (context, snapshot) => _StatItem(
              icon: Icons.favorite_rounded,
              label: 'Yêu thích',
              value: snapshot.data?.length ?? 0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StreamBuilder<List<HistoryEntry>>(
            stream: FirebaseService.getUserHistoryStream(userId),
            builder: (context, snapshot) => _StatItem(
              icon: Icons.history_rounded,
              label: 'Lịch sử',
              value: snapshot.data?.length ?? 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiệu ứng đếm số khi giá trị thay đổi.
                TweenAnimationBuilder<double>(
                  tween: Tween(end: value.toDouble()),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Text(
                    v.round().toString(),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

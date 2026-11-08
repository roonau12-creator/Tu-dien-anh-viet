class FavoriteEntry {
  final String userId;
  final String wordId;

  const FavoriteEntry({
    required this.userId,
    required this.wordId,
  });

  String get compositeKey => buildKey(userId, wordId);

  static String buildKey(String userId, String wordId) =>
      '${userId.trim().toLowerCase()}_${wordId.trim()}';

  Map<String, dynamic> toMap() => {
    'userId': userId.trim().toLowerCase(),
    'wordId': wordId.trim(),
  };

  factory FavoriteEntry.fromMap(Map<String, dynamic> map) => FavoriteEntry(
    userId: (map['userId'] ?? '').toString().trim().toLowerCase(),
    wordId: (map['wordId'] ?? '').toString().trim(),
  );
}
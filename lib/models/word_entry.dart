class WordEntry {
  final String id;
  final String vietnamese;
  final String english;
  final String wordType;
  final String example;

  const WordEntry({
    required this.id,
    required this.vietnamese,
    required this.english,
    required this.wordType,
    required this.example,
  });

  String get normalizedVi => vietnamese.trim().toLowerCase();
  String get normalizedEn => english.trim().toLowerCase();

  Map<String, dynamic> toMap() => {
    'id': id,
    'vietnamese': vietnamese.trim(),
    'english': english.trim(),
    'wordType': wordType.trim(),
    'example': example.trim(),
  };

  factory WordEntry.fromMap(Map<String, dynamic> map) => WordEntry(
    id: (map['id'] ?? '').toString(),
    vietnamese: (map['vietnamese'] ?? '').toString().trim(),
    english: (map['english'] ?? '').toString().trim(),
    wordType: (map['wordType'] ?? '').toString().trim(),
    example: (map['example'] ?? '').toString().trim(),
  );
}
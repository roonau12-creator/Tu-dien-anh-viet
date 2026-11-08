import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryEntry {
  final String id;
  final String userId;
  final String wordId;
  final String direction;
  final DateTime timestamp;

  const HistoryEntry({
    required this.id,
    required this.userId,
    required this.wordId,
    required this.direction,
    required this.timestamp,
  });

  String get directionLabel => direction == 'VI_EN' ? 'Việt ➔ Anh' : 'Anh ➔ Việt';

  String get formattedTime {
    final d = timestamp.day.toString().padLeft(2, '0');
    final m = timestamp.month.toString().padLeft(2, '0');
    final y = timestamp.year;
    final h = timestamp.hour.toString().padLeft(2, '0');
    final min = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min:$s';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId.trim().toLowerCase(),
    'wordId': wordId.trim(),
    'direction': direction,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory HistoryEntry.fromMap(Map<String, dynamic> map, String docId) {
    DateTime time;
    final rawTime = map['timestamp'];
    if (rawTime is Timestamp) {
      time = rawTime.toDate();
    } else if (rawTime is String) {
      time = DateTime.tryParse(rawTime) ?? DateTime.now();
    } else {
      time = DateTime.now();
    }

    return HistoryEntry(
      id: docId,
      userId: (map['userId'] ?? '').toString().trim().toLowerCase(),
      wordId: (map['wordId'] ?? '').toString().trim(),
      direction: (map['direction'] ?? 'VI_EN').toString(),
      timestamp: time,
    );
  }
}
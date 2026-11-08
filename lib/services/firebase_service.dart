import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/initial_words.dart';
import '../models/favorite_entry.dart';
import '../models/history_entry.dart';
import '../models/word_entry.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get wordsRef =>
      db.collection('words');
  static CollectionReference<Map<String, dynamic>> get favsRef =>
      db.collection('favorites');
  static CollectionReference<Map<String, dynamic>> get historyRef =>
      db.collection('history');
  static DocumentReference<Map<String, dynamic>> get configRef =>
      db.collection('settings').doc('app_config');

  static String? get currentUserId => auth.currentUser?.uid;
  static Stream<User?> get authStateChanges => auth.authStateChanges();

  // Chuyển username thành định dạng email nội bộ cho Firebase Auth
  static String _formatEmail(String username) {
    final clean = username.trim().toLowerCase();
    return clean.contains('@') ? clean : '$clean@dictionary.app';
  }

  static Future<String?> register(String username, String password) async {
    try {
      final email = _formatEmail(username);
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password.trim(),
      );
      await cred.user?.updateDisplayName(username.trim().toLowerCase());
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Tên đăng nhập này đã tồn tại.';
      } else if (e.code == 'weak-password') {
        return 'Mật khẩu phải chứa ít nhất 6 ký tự.';
      }
      return e.message ?? 'Đăng ký không thành công.';
    } catch (e) {
      return 'Lỗi: $e';
    }
  }

  static Future<String?> login(String username, String password) async {
    try {
      final email = _formatEmail(username);
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password.trim(),
      );
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        return 'Tài khoản hoặc mật khẩu không đúng.';
      } else if (e.code == 'wrong-password') {
        return 'Mật khẩu không chính xác.';
      }
      return e.message ?? 'Đăng nhập không thành công.';
    } catch (e) {
      return 'Lỗi: $e';
    }
  }

  static Future<void> logout() async {
    await auth.signOut();
  }

  static Future<void> seedInitialWords() async {
    final configDoc = await configRef.get();
    if (configDoc.exists && configDoc.data()?['isSeeded'] == true) {
      return;
    }

    final batch = db.batch();
    for (final word in kInitialWords) {
      final docRef = wordsRef.doc(word.id);
      batch.set(docRef, {
        ...word.toMap(),
        'searchVi': word.normalizedVi,
        'searchEn': word.normalizedEn,
      });
    }

    batch.set(configRef, {'isSeeded': true});
    await batch.commit();
  }

  static Stream<List<WordEntry>> getWordsStream() {
    return wordsRef.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => WordEntry.fromMap(doc.data()))
          .toList();
      list.sort((a, b) => a.normalizedVi.compareTo(b.normalizedVi));
      return list;
    });
  }

  static Future<WordEntry?> getWordById(String wordId) async {
    final doc = await wordsRef.doc(wordId).get();
    if (!doc.exists || doc.data() == null) return null;
    return WordEntry.fromMap(doc.data()!);
  }

  static Future<String?> saveWord({
    String? existingId,
    required String vietnamese,
    required String english,
    required String wordType,
    required String example,
  }) async {
    final cleanVi = vietnamese.trim();
    final cleanEn = english.trim();
    final cleanType = wordType.trim();
    final cleanEx = example.trim();

    if (cleanVi.isEmpty || cleanEn.isEmpty || cleanType.isEmpty || cleanEx.isEmpty) {
      return 'Vui lòng điền đầy đủ các thông tin.';
    }

    final targetVi = cleanVi.toLowerCase();
    final targetEn = cleanEn.toLowerCase();

    // Chỉ lọc theo searchVi để tránh yêu cầu composite index của Firestore,
    // sau đó so khớp searchEn ở phía client.
    final query = await wordsRef.where('searchVi', isEqualTo: targetVi).get();

    for (final doc in query.docs) {
      final data = doc.data();
      final docEn = (data['searchEn'] as String?)?.trim().toLowerCase();
      if (docEn != targetEn) continue;
      if (existingId == null || doc.id != existingId) {
        return 'Cặp từ Việt–Anh này đã tồn tại trong từ điển!';
      }
    }

    final String id = existingId ?? 'w_${DateTime.now().millisecondsSinceEpoch}';
    final entry = WordEntry(
      id: id,
      vietnamese: cleanVi,
      english: cleanEn,
      wordType: cleanType,
      example: cleanEx,
    );

    await wordsRef.doc(id).set({
      ...entry.toMap(),
      'searchVi': targetVi,
      'searchEn': targetEn,
    });
    return null;
  }

  /// Xóa mục từ và dọn dẹp các bản ghi yêu thích/lịch sử liên quan.
  /// Trả về `null` nếu thành công, ngược lại trả về thông báo lỗi.
  static Future<String?> deleteWordCascade(String wordId) async {
    // 1. Xóa mục từ chính (bắt buộc phải thành công).
    try {
      await wordsRef.doc(wordId).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Không có quyền xóa mục từ (kiểm tra Firestore Security Rules).';
      }
      return 'Xóa thất bại: ${e.message ?? e.code}';
    } catch (e) {
      return 'Xóa thất bại: $e';
    }

    // 2. Dọn dẹp dữ liệu liên quan (best-effort, không chặn việc xóa).
    await _deleteRelated(favsRef, wordId);
    await _deleteRelated(historyRef, wordId);
    return null;
  }

  static Future<void> _deleteRelated(
    CollectionReference<Map<String, dynamic>> ref,
    String wordId,
  ) async {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
    try {
      // Thử xóa của tất cả người dùng (cần rules cho phép đọc chéo).
      docs = (await ref.where('wordId', isEqualTo: wordId).get()).docs;
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') return;
      // Rules chỉ cho phép đọc dữ liệu của chính mình → chỉ dọn của user hiện tại.
      final uid = currentUserId;
      if (uid == null) return;
      try {
        docs = (await ref.where('userId', isEqualTo: uid).get())
            .docs
            .where((d) => d.data()['wordId'] == wordId)
            .toList();
      } catch (_) {
        return;
      }
    } catch (_) {
      return;
    }

    if (docs.isEmpty) return;
    try {
      final batch = db.batch();
      for (final doc in docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (_) {
      // Bỏ qua: các bản ghi mồ côi được UI xử lý ("Mục từ đã bị xóa").
    }
  }

  static Stream<bool> isFavoriteStream(String userId, String wordId) {
    final docKey = FavoriteEntry.buildKey(userId, wordId);
    return favsRef.doc(docKey).snapshots().map((doc) => doc.exists);
  }

  static Future<void> toggleFavorite(String userId, String wordId) async {
    final docKey = FavoriteEntry.buildKey(userId, wordId);
    final doc = await favsRef.doc(docKey).get();

    if (doc.exists) {
      await favsRef.doc(docKey).delete();
    } else {
      await favsRef.doc(docKey).set({
        'userId': userId,
        'wordId': wordId,
      });
    }
  }

  static Stream<List<String>> getFavoriteWordIdsStream(String userId) {
    return favsRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((s) => s.docs.map((doc) => doc['wordId'] as String).toList());
  }

  static Future<void> addHistory({
    required String userId,
    required String wordId,
    required String direction,
  }) async {
    final docRef = historyRef.doc();
    final entry = HistoryEntry(
      id: docRef.id,
      userId: userId,
      wordId: wordId,
      direction: direction,
      timestamp: DateTime.now(),
    );
    await docRef.set(entry.toMap());
  }

  static Stream<List<HistoryEntry>> getUserHistoryStream(String userId) {
    return historyRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => HistoryEntry.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  static Future<void> deleteHistoryItem(String historyId) async {
    await historyRef.doc(historyId).delete();
  }

  static Future<void> clearUserHistory(String userId) async {
    final docs = await historyRef.where('userId', isEqualTo: userId).get();
    final batch = db.batch();
    for (final doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
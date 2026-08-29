import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/song.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _songs => _db.collection('songs');

  /// Live stream of all songs, newest first.
  Stream<List<Song>> streamSongs() {
    return _songs.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs
              .map((d) => Song.fromMap(d.id, d.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  Stream<List<Song>> streamByCategory(String category) {
    return _songs
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Song.fromMap(d.id, d.data() as Map<String, dynamic>))
            .toList());
  }

  /// Simple client-side search by title/artist prefix.
  /// For production-scale search, consider Algolia or Firestore full-text add-ons.
  Future<List<Song>> searchSongs(String query) async {
    final snap = await _songs.get();
    final all = snap.docs
        .map((d) => Song.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
    final q = query.toLowerCase();
    return all
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q))
        .toList();
  }

  // ---- Admin operations ----

  Future<void> addSong(Song song) {
    return _songs.doc(song.id).set(song.toMap());
  }

  Future<void> deleteSong(String id) {
    return _songs.doc(id).delete();
  }

  Future<void> incrementPlayCount(String id) {
    return _songs.doc(id).update({'playCount': FieldValue.increment(1)});
  }

  // ---- Favorites (per user, subcollection) ----

  Future<void> toggleFavorite(String uid, String songId, bool isFav) async {
    final ref = _db.collection('users').doc(uid).collection('favorites').doc(songId);
    if (isFav) {
      await ref.delete();
    } else {
      await ref.set({'songId': songId, 'addedAt': DateTime.now().toIso8601String()});
    }
  }

  Stream<List<String>> streamFavoriteIds(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }
}

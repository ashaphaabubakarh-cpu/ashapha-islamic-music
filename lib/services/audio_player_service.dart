import 'dart:convert';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';

/// Handles playback and offline "download for offline listening" of
/// songs that Ashapa Music itself owns and has uploaded to Supabase
/// Storage. This does NOT download from YouTube or any third-party
/// platform — only from your own hosted audio files.
class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Song? currentSong;

  List<Song> _queue = [];
  int _currentIndex = -1;

  String? lastError;
  bool _repeatOne = false;

  /// Goes up every time the list of downloaded songs changes,
  /// so screens know when to reload it.
  int downloadsVersion = 0;
  static const _metaKey = 'offline_songs_v1';

  AudioPlayer get player => _player;
  bool get isRepeatOne => _repeatOne;

  bool get hasNext =>
      _queue.isNotEmpty && _currentIndex >= 0 && _currentIndex < _queue.length - 1;

  bool get hasPrevious => _queue.isNotEmpty && _currentIndex > 0;

  Future<void> toggleRepeatOne() async {
    _repeatOne = !_repeatOne;
    await _player.setLoopMode(_repeatOne ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  Future<void> playSong(Song song, {List<Song>? queue}) async {
    if (queue != null) {
      _queue = queue;
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    } else if (_queue.isEmpty ||
        _queue.indexWhere((s) => s.id == song.id) == -1) {
      _queue = [song];
      _currentIndex = 0;
    } else {
      _currentIndex = _queue.indexWhere((s) => s.id == song.id);
    }

    currentSong = song;
    lastError = null;
    notifyListeners();

    try {
      final localPath = await _localFilePath(song.id);
      final file = File(localPath);

      if (await file.exists()) {
        // Already fully downloaded — play straight from disk.
        await _player.setFilePath(localPath);
      } else {
        // Stream directly from Supabase.
        await _player.setUrl(song.audioUrl);
      }
      await _player.setLoopMode(_repeatOne ? LoopMode.one : LoopMode.off);
      await _player.play();
    } catch (e) {
      lastError = 'Kuskure wajen kunna waka: $e';
      notifyListeners();
    }
  }

  Future<void> playNext() async {
    if (!hasNext) return;
    await playSong(_queue[_currentIndex + 1]);
  }

  Future<void> playPrevious() async {
    if (!hasPrevious) return;
    await playSong(_queue[_currentIndex - 1]);
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.play();
  Future<void> seek(Duration position) => _player.seek(position);

  Future<String> _localFilePath(String songId) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/ashapa_$songId.mp3';
  }

  Future<bool> isDownloaded(String songId) async {
    final path = await _localFilePath(songId);
    return File(path).exists();
  }

  // ---- Saved details (title, cover...) of downloaded songs ----
  // These let the app list downloaded songs with no internet.

  Future<Map<String, dynamic>> _readMeta() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_metaKey);
      if (raw == null || raw.isEmpty) return {};
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeMeta(Map<String, dynamic> meta) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_metaKey, jsonEncode(meta));
  }

  /// Every song saved on this phone. Works with no internet.
  Future<List<Song>> downloadedSongs() async {
    final meta = await _readMeta();
    final result = <Song>[];
    for (final e in meta.entries) {
      if (await isDownloaded(e.key)) {
        result.add(Song.fromMap(
            e.key, Map<String, dynamic>.from(e.value as Map)));
      }
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Songs downloaded before this update have no saved details yet.
  /// Fill them in from the online list the next time the app is online.
  Future<void> rememberDownloaded(List<Song> songs) async {
    final meta = await _readMeta();
    var changed = false;
    for (final s in songs) {
      if (!meta.containsKey(s.id) && await isDownloaded(s.id)) {
        meta[s.id] = s.toMap();
        changed = true;
      }
    }
    if (changed) {
      await _writeMeta(meta);
      downloadsVersion++;
      notifyListeners();
    }
  }

  /// Downloads the song's own audio file to local device storage for
  /// offline playback. It is saved under a temporary name first, so a
  /// download that was cut off is never mistaken for a finished one.
  Future<void> downloadForOffline(
    Song song, {
    void Function(int received, int? total)? onProgress,
  }) async {
    final path = await _localFilePath(song.id);
    final tmpPath = '$path.part';
    final dio = Dio();
    try {
      await dio.download(
        song.audioUrl,
        tmpPath,
        onReceiveProgress: onProgress,
      );
      await File(tmpPath).rename(path);
    } catch (e) {
      final tmp = File(tmpPath);
      if (await tmp.exists()) await tmp.delete();
      rethrow;
    }

    final meta = await _readMeta();
    meta[song.id] = song.toMap();
    await _writeMeta(meta);
    downloadsVersion++;
    notifyListeners();
  }

  Future<void> deleteDownload(String songId) async {
    final path = await _localFilePath(songId);
    final file = File(path);
    if (await file.exists()) await file.delete();

    final meta = await _readMeta();
    if (meta.remove(songId) != null) await _writeMeta(meta);
    downloadsVersion++;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

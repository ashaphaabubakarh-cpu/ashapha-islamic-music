import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/song.dart';

/// Handles playback and offline "download for offline listening" of
/// songs that Ashapa Music itself owns and has uploaded to Firebase
/// Storage. This does NOT download from YouTube or any third-party
/// platform — only from your own Firebase-hosted audio files.
class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  Song? currentSong;

  List<Song> _queue = [];
  int _currentIndex = -1;

  AudioPlayer get player => _player;

  bool get hasNext =>
      _queue.isNotEmpty && _currentIndex >= 0 && _currentIndex < _queue.length - 1;

  bool get hasPrevious => _queue.isNotEmpty && _currentIndex > 0;

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
    notifyListeners();

    final localPath = await _localFilePath(song.id);
    final file = File(localPath);

    if (await file.exists()) {
      await _player.setFilePath(localPath);
    } else {
      await _player.setUrl(song.audioUrl);
    }
    await _player.play();
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

  /// Downloads the song's own audio file (from Firebase Storage) to
  /// local device storage for offline playback.
  Future<void> downloadForOffline(
    Song song, {
    void Function(int received, int total)? onProgress,
  }) async {
    final path = await _localFilePath(song.id);
    final dio = Dio();
    await dio.download(
      song.audioUrl,
      path,
      onReceiveProgress: onProgress,
    );
  }

  Future<void> deleteDownload(String songId) async {
    final path = await _localFilePath(songId);
    final file = File(path);
    if (await file.exists()) await file.delete();
  playerService.playSong(song, queue: songs);

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

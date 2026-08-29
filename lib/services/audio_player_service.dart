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

  AudioPlayer get player => _player;

  Future<void> playSong(Song song) async {
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
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

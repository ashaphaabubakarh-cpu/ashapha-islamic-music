import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/audio_player_service.dart';
import '../theme/app_theme.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  double? _downloadProgress;
  bool _downloaded = false;

  @override
  void initState() {
    super.initState();
    _checkDownloaded();
  }

  Future<void> _checkDownloaded() async {
    final service = context.read<AudioPlayerService>();
    final song = service.currentSong;
    if (song == null) return;
    final done = await service.isDownloaded(song.id);
    if (mounted) setState(() => _downloaded = done);
  }

  Future<void> _download() async {
    final service = context.read<AudioPlayerService>();
    final song = service.currentSong;
    if (song == null) return;
    setState(() => _downloadProgress = 0);
    await service.downloadForOffline(
      song,
      onProgress: (received, total) {
        if (total > 0 && mounted) {
          setState(() => _downloadProgress = received / total);
        }
      },
    );
    if (mounted) {
      setState(() {
        _downloaded = true;
        _downloadProgress = null;
      });
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AudioPlayerService>();
    final song = service.currentSong;

    if (song == null) {
      return const Scaffold(body: Center(child: Text('Babu waƙar da ake kunnawa')));
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: const Text('Ana Kunnawa')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: song.coverUrl,
                width: 260,
                height: 260,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 260,
                  height: 260,
                  color: AppColors.cardGrey,
                  child: const Icon(Icons.music_note, color: AppColors.gold, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(song.title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(song.artist, style: const TextStyle(color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 24),
            StreamBuilder<Duration>(
              stream: service.player.positionStream,
              builder: (context, snap) {
                final pos = snap.data ?? Duration.zero;
                final dur = service.player.duration ?? Duration.zero;
                return Column(
                  children: [
                    Slider(
                      value: pos.inSeconds.toDouble().clamp(0, dur.inSeconds.toDouble()),
                      max: dur.inSeconds.toDouble() > 0 ? dur.inSeconds.toDouble() : 1,
                      activeColor: AppColors.gold,
                      inactiveColor: AppColors.cardGrey,
                      onChanged: (v) => service.seek(Duration(seconds: v.toInt())),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt(pos), style: const TextStyle(color: Colors.grey)),
                          Text(_fmt(dur), style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),
            StreamBuilder<bool>(
              stream: service.player.playingStream,
              builder: (context, snap) {
                final playing = snap.data ?? false;
                return IconButton(
                  iconSize: 72,
                  color: AppColors.gold,
                  icon: Icon(playing
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled),
                  onPressed: () => playing ? service.pause() : service.resume(),
                );
              },
            ),
            const SizedBox(height: 16),
            if (_downloadProgress != null)
              Column(
                children: [
                  LinearProgressIndicator(
                      value: _downloadProgress, color: AppColors.gold),
                  const SizedBox(height: 6),
                  Text('${((_downloadProgress ?? 0) * 100).toInt()}%',
                      style: const TextStyle(color: Colors.grey)),
                ],
              )
            else
              TextButton.icon(
                onPressed: _downloaded ? null : _download,
                icon: Icon(_downloaded ? Icons.check_circle : Icons.download,
                    color: AppColors.gold),
                label: Text(
                  _downloaded ? 'An adana don Offline' : 'Download don Offline',
                  style: const TextStyle(color: AppColors.goldLight),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../theme/app_theme.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerService = context.watch<AudioPlayerService>();
    final song = playerService.currentSong;
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PlayerScreen()),
      ),
      child: Container(
        height: 64,
        color: AppColors.darkGrey,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(Icons.music_note, color: AppColors.gold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(song.title,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            StreamBuilder<bool>(
              stream: playerService.player.playingStream,
              builder: (context, snap) {
                final playing = snap.data ?? false;
                return IconButton(
                  icon: Icon(
                    playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    color: AppColors.gold,
                    size: 34,
                  ),
                  onPressed: () =>
                      playing ? playerService.pause() : playerService.resume(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

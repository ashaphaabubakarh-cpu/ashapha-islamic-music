import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/audio_player_service.dart';
import '../models/song.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final firestore = FirestoreService();
    final playerService = context.read<AudioPlayerService>();

    return StreamBuilder<List<String>>(
      stream: firestore.streamFavoriteIds(uid),
      builder: (context, favSnap) {
        final favIds = favSnap.data ?? [];
        if (favIds.isEmpty) {
          return const Center(
            child: Text('Babu waƙar da aka fi so tukuna.',
                style: TextStyle(color: Colors.grey)),
          );
        }
        return StreamBuilder<List<Song>>(
          stream: firestore.streamSongs(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.gold));
            }
            final favSongs =
                snap.data!.where((s) => favIds.contains(s.id)).toList();
            return ListView.builder(
              itemCount: favSongs.length,
              itemBuilder: (context, i) {
                final song = favSongs[i];
                return SongTile(
                  song: song,
                  isFavorite: true,
                  onTap: () => playerService.playSong(song),
                  onFavoriteTap: () =>
                      firestore.toggleFavorite(uid, song.id, true),
                );
              },
            );
          },
        );
      },
    );
  }
}

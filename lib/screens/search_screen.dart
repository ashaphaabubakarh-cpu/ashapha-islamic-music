import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/audio_player_service.dart';
import '../models/song.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _firestore = FirestoreService();
  final _ctrl = TextEditingController();
  List<Song> _results = [];
  bool _loading = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    final results = await _firestore.searchSongs(query.trim());
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final playerService = context.read<AudioPlayerService>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _ctrl,
            onChanged: _search,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Nemi waƙa ko mawaƙi...',
              prefixIcon: Icon(Icons.search, color: AppColors.gold),
            ),
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        Expanded(
          child: StreamBuilder<List<String>>(
            stream: _firestore.streamFavoriteIds(uid),
            builder: (context, favSnap) {
              final favIds = favSnap.data ?? [];
              return ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, i) {
                  final song = _results[i];
                  final isFav = favIds.contains(song.id);
                  return SongTile(
                    song: song,
                    isFavorite: isFav,
                    onTap: () => playerService.playSong(song),
                    onFavoriteTap: () =>
                        _firestore.toggleFavorite(uid, song.id, isFav),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

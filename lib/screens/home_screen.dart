import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/audio_player_service.dart';
import '../models/song.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';
import '../widgets/mini_player.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final pages = [
      _SongListTab(firestore: _firestore, uid: uid),
      const SearchScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: const Text('Ashapa Music')),
      body: pages[_tab],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          BottomNavigationBar(
            currentIndex: _tab,
            onTap: (i) => setState(() => _tab = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SongListTab extends StatelessWidget {
  final FirestoreService firestore;
  final String uid;
  const _SongListTab({required this.firestore, required this.uid});

  @override
  Widget build(BuildContext context) {
    final playerService = context.read<AudioPlayerService>();

    return StreamBuilder<List<String>>(
      stream: firestore.streamFavoriteIds(uid),
      builder: (context, favSnap) {
        final favIds = favSnap.data ?? [];
        return StreamBuilder<List<Song>>(
          stream: firestore.streamSongs(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.gold));
            }
            final songs = snap.data!;
            if (songs.isEmpty) {
              return const Center(
                child: Text('Babu waƙa tukuna. Admin zai ƙara waƙoƙi ba da daɗewa.',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, i) {
                final song = songs[i];
                final isFav = favIds.contains(song.id);
                return SongTile(
                  song: song,
                  isFavorite: isFav,
                  onTap: () {
                    playerService.playSong(song);
                    firestore.incrementPlayCount(song.id);
                  },
                  onFavoriteTap: () =>
                      firestore.toggleFavorite(uid, song.id, isFav),
                );
              },
            );
          },
        );
      },
    );
  }
}

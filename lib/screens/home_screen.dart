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
import 'offline_screen.dart';
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
      const OfflineScreen(),
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
              BottomNavigationBarItem(icon: Icon(Icons.download_done), label: 'Offline'),
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
              // No answer from the internet yet: after a few seconds,
              // show the songs that are saved on the phone instead.
              return const _WaitingOrOffline();
            }
            final songs = snap.data!;
            if (songs.isEmpty) {
              return const Center(
                child: Text('Babu waƙa tukuna. Admin zai ƙara waƙoƙi ba da daɗewa.',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            // Remember details of songs downloaded before, so they
            // can be listed with no internet later.
            playerService.rememberDownloaded(songs);
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, i) {
                final song = songs[i];
                final isFav = favIds.contains(song.id);
                return SongTile(
                  song: song,
                  isFavorite: isFav,
                  onTap: () {
                    playerService.playSong(song, queue: songs);
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

/// Shown while the song list has not arrived. After 3 seconds with no
/// answer (no internet), it lists the songs saved on the phone.
class _WaitingOrOffline extends StatefulWidget {
  const _WaitingOrOffline();

  @override
  State<_WaitingOrOffline> createState() => _WaitingOrOfflineState();
}

class _WaitingOrOfflineState extends State<_WaitingOrOffline> {
  bool _waited = false;
  Future<List<Song>>? _downloaded;

  @override
  void initState() {
    super.initState();
    _downloaded = context.read<AudioPlayerService>().downloadedSongs();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _waited = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_waited) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.gold));
    }
    final player = context.read<AudioPlayerService>();
    return FutureBuilder<List<Song>>(
      future: _downloaded,
      builder: (context, snap) {
        final songs = snap.data ?? [];
        return Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.darkGrey,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.gold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      songs.isEmpty
                          ? 'Babu intanet. Ana jiran haɗi...'
                          : 'Babu intanet. Ga waƙoƙin da ke wayarka:',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, i) {
                  final song = songs[i];
                  return DownloadedTile(
                    song: song,
                    onTap: () => player.playSong(song, queue: songs),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

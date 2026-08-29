import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/song.dart';
import '../../theme/app_theme.dart';
import 'add_song_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: const Text('Admin Dashboard')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        child: const Icon(Icons.add, color: AppColors.black),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddSongScreen()),
        ),
      ),
      body: StreamBuilder<List<Song>>(
        stream: firestore.streamSongs(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.gold));
          }
          final songs = snap.data!;
          if (songs.isEmpty) {
            return const Center(
              child: Text('Babu waƙa. Danna + don ƙara sabuwa.',
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, i) {
              final song = songs[i];
              return ListTile(
                title: Text(song.title, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${song.artist} • ${song.category} • ${song.playCount} plays',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => firestore.deleteSong(song.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

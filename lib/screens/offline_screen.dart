import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';
import '../theme/app_theme.dart';

/// One row for a song that is saved on the phone.
class DownloadedTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const DownloadedTile({
    super.key,
    required this.song,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: song.coverUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(
            width: 52,
            height: 52,
            color: AppColors.cardGrey,
            child: const Icon(Icons.music_note, color: AppColors.gold),
          ),
        ),
      ),
      title: Text(song.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
      subtitle: Text(song.artist, style: const TextStyle(color: Colors.grey)),
      trailing: onDelete == null
          ? const Icon(Icons.download_done, color: AppColors.gold)
          : IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: onDelete,
            ),
    );
  }
}

/// The "Offline" tab: songs saved on the phone. Works with no internet.
class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  List<Song>? _songs;
  int _version = -1;

  Future<void> _load(AudioPlayerService service) async {
    final songs = await service.downloadedSongs();
    if (mounted) setState(() => _songs = songs);
  }

  Future<void> _confirmDelete(AudioPlayerService service, Song song) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkGrey,
        title: const Text('Share waƙar?'),
        content: Text('Za a share "${song.title}" daga wayarka. Za ka iya sake sauke ta daga baya.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("A'a"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Share', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok == true) await service.deleteDownload(song.id);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AudioPlayerService>();
    if (service.downloadsVersion != _version) {
      _version = service.downloadsVersion;
      _load(service);
    }

    final songs = _songs;
    if (songs == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
    }
    if (songs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Babu waƙar da aka sauke tukuna.\n\nBuɗe waƙa, ka danna "Download don Offline", sannan za ta bayyana a nan, kuma za ka iya sauraronta ba tare da intanet ba.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, i) {
        final song = songs[i];
        return DownloadedTile(
          song: song,
          onTap: () => service.playSong(song, queue: songs),
          onDelete: () => _confirmDelete(service, song),
        );
      },
    );
  }
}

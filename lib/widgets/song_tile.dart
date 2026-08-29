import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/song.dart';
import '../theme/app_theme.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const SongTile({
    super.key,
    required this.song,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
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
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(song.artist, style: const TextStyle(color: Colors.grey)),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppColors.gold : Colors.grey,
        ),
        onPressed: onFavoriteTap,
      ),
    );
  }
}

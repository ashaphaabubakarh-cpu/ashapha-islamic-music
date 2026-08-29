class Song {
  final String id;
  final String title;
  final String artist;
  final String audioUrl; // Firebase Storage download URL (mp3/m4a)
  final String coverUrl; // Firebase Storage image URL
  final int durationSeconds;
  final String category; // e.g. "Nasheed", "Lecture"
  final int playCount;
  final DateTime createdAt;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.coverUrl,
    required this.durationSeconds,
    required this.category,
    this.playCount = 0,
    required this.createdAt,
  });

  factory Song.fromMap(String id, Map<String, dynamic> map) {
    return Song(
      id: id,
      title: map['title'] ?? '',
      artist: map['artist'] ?? 'Ashapa',
      audioUrl: map['audioUrl'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      durationSeconds: map['durationSeconds'] ?? 0,
      category: map['category'] ?? 'Nasheed',
      playCount: map['playCount'] ?? 0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'audioUrl': audioUrl,
      'coverUrl': coverUrl,
      'durationSeconds': durationSeconds,
      'category': category,
      'playCount': playCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

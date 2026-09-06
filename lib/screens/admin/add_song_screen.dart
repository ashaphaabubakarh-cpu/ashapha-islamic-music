import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/firestore_service.dart';
import '../../models/song.dart';
import '../../theme/app_theme.dart';

/// NOTE: this screen uses `file_picker` to let the admin choose an
/// audio file (mp3/m4a) and a cover image from their own device, then
/// uploads both to Supabase Storage (songs / covers buckets).
class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _firestore = FirestoreService();
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController(text: 'Ashapa');
  final _categoryCtrl = TextEditingController(text: 'Nasheed');

  File? _audioFile;
  File? _coverFile;
  bool _uploading = false;

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() => _audioFile = File(result.files.single.path!));
    }
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _coverFile = File(result.files.single.path!));
    }
  }

  Future<void> _upload() async {
    if (_audioFile == null || _titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ka zabi audio file kuma ka rubuta suna.')),
      );
      return;
    }

    setState(() => _uploading = true);

    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final storage = Supabase.instance.client.storage;

      // Upload audio to Supabase Storage "songs" bucket
      final audioPath = '$id.mp3';
      await storage.from('songs').upload(
            audioPath,
            _audioFile!,
            fileOptions: const FileOptions(upsert: true),
          );
      final audioUrl = storage.from('songs').getPublicUrl(audioPath);

      // Upload cover (optional) to "covers" bucket
      String coverUrl = '';
      if (_coverFile != null) {
        final coverPath = '$id.jpg';
        await storage.from('covers').upload(
              coverPath,
              _coverFile!,
              fileOptions: const FileOptions(upsert: true),
            );
        coverUrl = storage.from('covers').getPublicUrl(coverPath);
      }

      final song = Song(
        id: id,
        title: _titleCtrl.text.trim(),
        artist: _artistCtrl.text.trim(),
        audioUrl: audioUrl,
        coverUrl: coverUrl,
        durationSeconds: 0,
        category: _categoryCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      await _firestore.addSong(song);

      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An dora waka cikin nasara!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kuskure wajen dorawa: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: const Text('Kara Sabon Waka')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Sunan Waka'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _artistCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Mawaki'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Category (misali: Nasheed)'),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _pickAudio,
              icon: const Icon(Icons.audio_file, color: AppColors.gold),
              label: Text(
                _audioFile == null ? 'Zabi Audio File' : 'Audio: ✓ an zaba',
                style: const TextStyle(color: AppColors.goldLight),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickCover,
              icon: const Icon(Icons.image, color: AppColors.gold),
              label: Text(
                _coverFile == null ? 'Zabi Cover Image (zabi ne kawai)' : 'Cover: ✓ an zaba',
                style: const TextStyle(color: AppColors.goldLight),
              ),
            ),
            const SizedBox(height: 24),
            if (_uploading) ...[
              const LinearProgressIndicator(color: AppColors.gold),
              const SizedBox(height: 8),
              const Text('Ana dorawa, da fatan za a jira...',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _uploading ? null : _upload,
              child: const Text('Dora (Upload)'),
            ),
          ],
        ),
      ),
    );
  }
}

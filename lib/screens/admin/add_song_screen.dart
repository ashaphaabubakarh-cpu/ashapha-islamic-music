import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/firestore_service.dart';
import '../../models/song.dart';
import '../../theme/app_theme.dart';

/// NOTE: this screen uses `file_picker` to let the admin choose an
/// audio file (mp3/m4a) and a cover image from their own device, then
/// uploads both to Firebase Storage. Add `file_picker: ^6.1.1` to
/// pubspec.yaml if it isn't already there.
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
  double _progress = 0;

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
        const SnackBar(content: Text('Ka zaɓi audio file kuma ka rubuta suna.')),
      );
      return;
    }
    setState(() => _uploading = true);

    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final audioRef = FirebaseStorage.instance.ref('songs/$id.mp3');
    final audioTask = audioRef.putFile(_audioFile!);
    audioTask.snapshotEvents.listen((s) {
      setState(() => _progress = s.bytesTransferred / s.totalBytes);
    });
    await audioTask;
    final audioUrl = await audioRef.getDownloadURL();

    String coverUrl = '';
    if (_coverFile != null) {
      final coverRef = FirebaseStorage.instance.ref('covers/$id.jpg');
      await coverRef.putFile(_coverFile!);
      coverUrl = await coverRef.getDownloadURL();
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
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(title: const Text('Ƙara Sabon Waƙa')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Sunan Waƙa'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _artistCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'Mawaƙi'),
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
                _audioFile == null ? 'Zaɓi Audio File' : 'Audio: ✓ an zaɓa',
                style: const TextStyle(color: AppColors.goldLight),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _pickCover,
              icon: const Icon(Icons.image, color: AppColors.gold),
              label: Text(
                _coverFile == null ? 'Zaɓi Cover Image (zaɓi ne kawai)' : 'Cover: ✓ an zaɓa',
                style: const TextStyle(color: AppColors.goldLight),
              ),
            ),
            const SizedBox(height: 24),
            if (_uploading) ...[
              LinearProgressIndicator(value: _progress, color: AppColors.gold),
              const SizedBox(height: 8),
              Text('${(_progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _uploading ? null : _upload,
              child: const Text('Ɗora (Upload)'),
            ),
          ],
        ),
      ),
    );
  }
}

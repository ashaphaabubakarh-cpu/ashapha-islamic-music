import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'services/audio_player_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();await Supabase.initialize(
    url: 'https://hkvccgtpuipcqongrvmw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ3amR1cXVsdnZwZ2JlYmxneG94Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgyNTY3NzgsImV4cCI6MjEwMzgzMjc3OH0.0QKMXHU8900qPKa1D7uHn5W29H8AkE5xS3j3DWzafK0',
  );
  runApp(const AshapaApp());
}

class AshapaApp extends StatelessWidget {
  const AshapaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioPlayerService(),
      child: MaterialApp(
        title: 'Ashapa Music',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }
}

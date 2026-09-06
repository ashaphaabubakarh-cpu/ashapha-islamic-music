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
    anonKey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhrdmNjZ3RwdWlwY3Fvbmdydm13Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgyNTczMTEsImV4cCI6MjEwMzgzMzMxMX0.72ImuVGGTS6YSS6_hIE4zGRDJTEKzIwgOhNlWfaQ1z0',
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

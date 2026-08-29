import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';

/// Gate screen: only lets a user through to the Admin Dashboard if
/// their Firestore user doc has `isAdmin: true`. Set that flag manually
/// in the Firebase Console (Firestore > users > <uid> > isAdmin = true)
/// for accounts that should manage the app's songs.
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _auth = AuthService();
  bool _checking = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _checking = false);
      return;
    }
    final result = await _auth.isAdmin(uid);
    setState(() {
      _isAdmin = result;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );
    }
    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Ba ka da izinin admin a wannan account.\n\n'
              'Domin a ba wani account izinin admin: buɗe Firebase Console → '
              'Firestore Database → users → (uid na wannan mai amfani) → '
              'saka field "isAdmin" mai darajar true.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }
    return const AdminDashboardScreen();
  }
}

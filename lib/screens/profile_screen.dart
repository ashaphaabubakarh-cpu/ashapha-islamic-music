import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'admin/admin_login_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final auth = AuthService();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.cardGrey,
            child: Icon(Icons.person, color: AppColors.gold, size: 40),
          ),
          const SizedBox(height: 16),
          Text(user?.email ?? '', style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: AppColors.gold),
            title: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Fita (Logout)', style: TextStyle(color: Colors.white)),
            onTap: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

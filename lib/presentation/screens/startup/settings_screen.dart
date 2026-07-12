import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/themes/app_theme.dart';
import '../../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingItem(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: 'Edit profile coming soon!',
                  backgroundColor: AppColors.primary,
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {
                Fluttertoast.showToast(
                  msg: 'Change password coming soon!',
                  backgroundColor: AppColors.primary,
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                Fluttertoast.showToast(
                  msg: 'Notifications coming soon!',
                  backgroundColor: AppColors.primary,
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              onTap: () {
                Fluttertoast.showToast(
                  msg: 'Dark mode coming soon!',
                  backgroundColor: AppColors.primary,
                );
              },
            ),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: 'About Ingazi',
              onTap: () {
                Fluttertoast.showToast(
                  msg: 'Ingazi v1.0.0 - Connect. Grow. Impact.',
                  backgroundColor: AppColors.primary,
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Ingazi v1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }
}
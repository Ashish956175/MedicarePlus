import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSettingsHeader('Notifications'),
          _buildSettingsItem('Push Notifications', 'Receive alerts for appointments', true),
          _buildSettingsItem('Email Notifications', 'Receive summary of your activity', false),
          const SizedBox(height: 24),
          _buildSettingsHeader('Security'),
          _buildSettingsActionItem(context, 'Change Password', Icons.lock_outline),
          _buildSettingsActionItem(context, 'Two-Factor Authentication', Icons.verified_user_outlined),
          _buildSettingsActionItem(context, 'Privacy Settings', Icons.privacy_tip_outlined),
        ],
      ),
    );
  }

  Widget _buildSettingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: AppTextStyles.h3),
    );
  }

  Widget _buildSettingsItem(String title, String subtitle, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.bodyLarge),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
        value: value,
        onChanged: (v) {},
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.grey200),
        ),
      ),
    );
  }

  Widget _buildSettingsActionItem(BuildContext context, String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyLarge),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}

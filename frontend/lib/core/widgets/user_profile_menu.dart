import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/theme_provider.dart';
import '../services/auth_service.dart';
import '../../features/auth/login_screen.dart';
import '../theme/page_transitions.dart';

// New screen imports
import '../../features/patient/profile/profile_screen.dart';
import '../../features/patient/records/medical_records_screen.dart';
import '../../features/patient/settings/settings_screen.dart';
import '../../features/patient/help/help_support_screen.dart';
import '../../features/doctor/profile/doctor_profile_screen.dart';
import '../constants/api_constants.dart';

class UserProfileMenu extends StatelessWidget {
  final String userName;
  final String? profileImage;
  final String? role;

  const UserProfileMenu({
    super.key,
    required this.userName,
    this.profileImage,
    this.role,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 28),
            const SizedBox(width: 12),
            Text('Logout', style: AppTextStyles.h3),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: AppTextStyles.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          FadePageRoute(child: const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      FadePageRoute(child: screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPatient = role == 'USER' || role == 'PATIENT' || role == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return PopupMenuButton<String>(
      offset: const Offset(0, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.grey200, width: 1),
      ),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Theme.of(context).cardColor,
      onSelected: (value) {
        switch (value) {
          case 'profile':
            if (role == 'DOCTOR') {
               _navigateTo(context, const DoctorProfileScreen());
            } else {
               _navigateTo(context, const ProfileScreen());
            }
            break;
          case 'records':
            _navigateTo(context, const MedicalRecordsScreen());
            break;
          case 'settings':
          case 'notifications':
          case 'security':
            _navigateTo(context, const SettingsScreen());
            break;
          case 'help':
            _navigateTo(context, const HelpSupportScreen());
            break;
          case 'logout':
            _handleLogout(context);
            break;
          case 'theme':
            themeProvider.toggleTheme();
            break;
        }
      },
      itemBuilder: (context) => [
        // Header with User Info
        PopupMenuItem(
          enabled: false,
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isDark ? Colors.white.withOpacity(0.1) : AppColors.grey200,
                    backgroundImage: (profileImage != null && profileImage!.isNotEmpty)
                        ? NetworkImage('${ApiConstants.profileImage}/$profileImage')
                        : null,
                    onBackgroundImageError: (profileImage != null && profileImage!.isNotEmpty) 
                        ? (exception, stackTrace) {
                            debugPrint('Error loading menu header image: $exception');
                          }
                        : null,
                    radius: 24,
                    child: (profileImage == null || profileImage!.isEmpty)
                        ? Icon(Icons.person, color: isDark ? AppColors.liquidGold : AppColors.textSecondary, size: 24)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: AppTextStyles.h3.copyWith(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          role ?? 'User',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
            ],
          ),
        ),

        // Menu Items
        _buildMenuItem(
          value: 'profile',
          icon: Icons.person_outline_rounded,
          label: 'My Profile',
          color: AppColors.primary,
        ),
        
        if (isPatient)
          _buildMenuItem(
            value: 'records',
            icon: Icons.assignment_outlined,
            label: 'Medical Records',
            color: AppColors.success,
          ),

        _buildMenuItem(
          value: 'theme',
          icon: themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          label: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
          color: Colors.purple,
          trailing: Switch(
            value: themeProvider.isDarkMode,
            onChanged: (v) => themeProvider.toggleTheme(),
            activeColor: AppColors.primary,
          ),
        ),

        _buildMenuItem(
          value: 'notifications',
          icon: Icons.notifications_none_rounded,
          label: 'Notifications',
          color: AppColors.warning,
        ),

        _buildMenuItem(
          value: 'security',
          icon: Icons.security_rounded,
          label: 'Security',
          color: AppColors.info,
        ),

        _buildMenuItem(
          value: 'help',
          icon: Icons.help_outline_rounded,
          label: 'Help & Support',
          color: AppColors.textSecondary,
        ),

        const PopupMenuDivider(height: 1),

        _buildMenuItem(
          value: 'logout',
          icon: Icons.logout_rounded,
          label: 'Logout',
          color: AppColors.error,
        ),

        // App Version Footer
        PopupMenuItem(
          enabled: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'MedicarePlus v1.0.0',
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
            ),
          ),
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(
          backgroundColor: isDark ? Colors.white.withOpacity(0.1) : AppColors.grey200,
          backgroundImage: (profileImage != null && profileImage!.isNotEmpty)
              ? NetworkImage('${ApiConstants.profileImage}/$profileImage')
              : null,
          onBackgroundImageError: (profileImage != null && profileImage!.isNotEmpty) 
              ? (exception, stackTrace) {
                  debugPrint('Error loading profile image: $exception');
                }
              : null,
          child: (profileImage == null || profileImage!.isEmpty) 
              ? Icon(Icons.person, color: isDark ? AppColors.liquidGold : AppColors.textSecondary, size: 22) 
              : null,
          radius: 22,
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String label,
    required Color color,
    Widget? trailing,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing,
          ],
        ],
      ),
    );
  }
}

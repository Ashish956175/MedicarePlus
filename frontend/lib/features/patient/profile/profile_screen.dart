import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/constants/api_constants.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();
  
  String _name = 'Loading...';
  String _email = 'Loading...';
  String _phone = 'Not set';
  String _address = 'Not set';
  String? _profileImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? 'User';
      _email = prefs.getString('email') ?? '';
      _phone = prefs.getString('phoneNumber') ?? 'Not set';
      _address = prefs.getString('address') ?? 'Not set';
      _profileImage = prefs.getString('profileImage');
      _isLoading = false;
    });
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isLoading = true);
    
    final fileName = await _profileService.uploadProfileImage(image);
    
    if (fileName != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', fileName);
      
      setState(() {
        _profileImage = fileName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated successfully!'), backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload photo'), backgroundColor: AppColors.error),
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _removeImage() async {
    setState(() => _isLoading = true);
    final success = await _profileService.removeProfileImage();
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profileImage');
      
      setState(() => _profileImage = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo removed'), backgroundColor: AppColors.primary),
      );
    }
    setState(() => _isLoading = false);
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    if (result == true) {
      _loadUserData(); // Refresh data if updated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.grey200,
                          backgroundImage: _profileImage != null 
                              ? NetworkImage('${ApiConstants.profileImage}/$_profileImage')
                              : const NetworkImage('https://i.pravatar.cc/150?img=12'),
                          child: _profileImage == null
                              ? const Icon(Icons.person, color: AppColors
                        .textSecondary, size: 40)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              radius: 20,
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_profileImage != null)
                    TextButton(
                      onPressed: _removeImage,
                      child: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                    ),
                  const SizedBox(height: 32),
                  _buildProfileItem(context, 'Full Name', _name, Icons.person_outline),
                  _buildProfileItem(context, 'Email', _email, Icons.email_outlined),
                  _buildProfileItem(context, 'Phone', _phone, Icons.phone_outlined),
                  _buildProfileItem(context, 'Address', _address, Icons.location_on_outlined),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _navigateToEditProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/doctor_service.dart';
import '../../../core/services/profile_service.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/constants/api_constants.dart';
import '../../patient/profile/edit_profile_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final DoctorService _doctorService = DoctorService();
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = true;
  Map<String, dynamic>? _doctorProfile;
  final TextEditingController _feeController = TextEditingController();

  // User Details (SharedPrefs)
  String _name = 'Loading...';
  String _profileImageOrPath = '';
  
  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadUserData(),
      _loadDoctorProfile(),
    ]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _name = prefs.getString('name') ?? 'Doctor';
        _profileImageOrPath = prefs.getString('profileImage') ?? '';
      });
    }
  }

  Future<void> _loadDoctorProfile() async {
    try {
      final profile = await _doctorService.getDoctorProfile();
      if (mounted) {
        setState(() {
          _doctorProfile = profile;
          _feeController.text = (profile['fee'] ?? 0.0).toString();
        });
      }
    } catch (e) {
      debugPrint('Error loading doctor profile: $e');
    }
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
        _profileImageOrPath = fileName;
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

  Future<void> _updateFee() async {
    final double? newFee = double.tryParse(_feeController.text);
    if (newFee == null || newFee < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid fee amount'), backgroundColor: AppColors.error),
      );
      return;
    }

    final success = await _doctorService.updateFee(newFee);
    if (success) {
       await _loadDoctorProfile(); 
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Consultation fee updated successfully!'), backgroundColor: AppColors.success),
         );
         Navigator.pop(context); 
       }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update fee'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showFeeUpdateDialog() {
    _feeController.text = _doctorProfile?['fee']?.toString() ?? '0.0';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Consultation Fee', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _feeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Fee (₹)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixText: '₹ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
               _updateFee();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    if (result == true) {
      _loadUserData(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingState());
    
    final specialization = _doctorProfile?['specialization'] ?? 'General';
    final experience = _doctorProfile?['experience'] ?? 0;
    final about = _doctorProfile?['about'] ?? 'No description available.';
    final fee = _doctorProfile?['fee'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Professional Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
           IconButton(
             icon: const Icon(Icons.edit, color: AppColors.primary),
             onPressed: _navigateToEditProfile,
             tooltip: 'Edit Personal Details',
           ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             // Header Card with Image Upload
             Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.grey200,
                        backgroundImage: _profileImageOrPath.isNotEmpty
                            ? NetworkImage('${ApiConstants.profileImage}/$_profileImageOrPath')
                            : null,
                        child: _profileImageOrPath.isEmpty
                            ? const Icon(Icons.person, color: AppColors.textSecondary, size: 60)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
             ),
             const SizedBox(height: 16),
             Text(_name.startsWith('Dr.') ? _name : 'Dr. $_name', style: AppTextStyles.h2),
             Text(specialization, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
             const SizedBox(height: 4),
             Text('$experience Years Experience', style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
             
             const SizedBox(height: 32),

             // Fee Section
             _buildSection(
               context, 
               'Consultation Fee', 
               '₹$fee', 
               Icons.currency_rupee,
               trailing: TextButton.icon(
                 onPressed: _showFeeUpdateDialog,
                 icon: const Icon(Icons.edit, size: 16),
                 label: const Text('Edit'),
               ),
             ),
             
             const SizedBox(height: 20),
             
             // About Section
             _buildSection(context, 'About', about, Icons.info_outline),
             
             const SizedBox(height: 20),
             
             // Quick Actions for Profile
             ElevatedButton.icon(
               onPressed: _navigateToEditProfile,
               icon: const Icon(Icons.person_outline),
               label: const Text('Edit Personal Details'),
               style: ElevatedButton.styleFrom(
                 minimumSize: const Size(double.infinity, 50),
                 backgroundColor: Theme.of(context).cardColor,
                 foregroundColor: AppColors.primary,
                 elevation: 0,
                 side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
               ),
             ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, IconData icon, {Widget? trailing, bool isPlaceholder = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: isPlaceholder ? AppColors.grey400 : AppColors.primary),
                  const SizedBox(width: 12),
                  Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
                ],
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content, 
            style: AppTextStyles.bodyMedium.copyWith(
              color: isPlaceholder ? AppColors.textHint : AppColors.textSecondary
            )
          ),
        ],
      ),
    );
  }
}

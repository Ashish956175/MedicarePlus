import 'package:flutter/material.dart';
import '../../../../core/models/doctor_model.dart';
import '../../../../core/services/saved_doctors_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../home/widgets/doctor_card_enhanced.dart';

class SavedDoctorsScreen extends StatefulWidget {
  const SavedDoctorsScreen({super.key});

  @override
  State<SavedDoctorsScreen> createState() => _SavedDoctorsScreenState();
}

class _SavedDoctorsScreenState extends State<SavedDoctorsScreen> {
  final UserService _userService = UserService();
  final SavedDoctorsService _savedDoctorsService = SavedDoctorsService();
  
  List<Doctor> _savedDoctors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedDoctors();
  }

  Future<void> _loadSavedDoctors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch all doctors and saved IDs in parallel
      final results = await Future.wait([
        _userService.getAllDoctors(),
        _savedDoctorsService.getSavedDoctors(),
      ]);

      final allDoctors = results[0] as List<Doctor>;
      final savedIds = results[1] as List<int>;

      if (mounted) {
        setState(() {
          _savedDoctors = allDoctors
              .where((doctor) => savedIds.contains(doctor.id))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load saved doctors';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDoctorDetails(Doctor doctor) {
    // TODO: Navigate to doctor details screen
    // For now, just show a snackbar or print
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: ${doctor.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Saved Doctors', style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSavedDoctors,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_savedDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Doctors',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              'Doctors you save will appear here',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSavedDoctors,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _savedDoctors.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final doctor = _savedDoctors[index];
          // We wrap in a Builder to ensure the card can update the list if unsaved
          return DoctorCardEnhanced(
            key: ValueKey(doctor.id),
            doctor: doctor,
            onTap: () => _navigateToDoctorDetails(doctor),
            onSaveStatusChanged: (isSaved) {
              if (!isSaved) {
                setState(() {
                  _savedDoctors.removeWhere((d) => d.id == doctor.id);
                });
              }
            },
          );
        },
      ),
    );
  }
}

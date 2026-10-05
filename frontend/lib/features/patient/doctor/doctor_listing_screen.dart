import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/models/doctor_model.dart';
import 'doctor_detail_screen.dart';
import '../../../core/widgets/responsive_web_container.dart';
import '../home/widgets/doctor_card_enhanced.dart';

import '../../../core/services/user_service.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/entrance_animation.dart';
import '../../../core/theme/page_transitions.dart';

class DoctorListingScreen extends StatefulWidget {
  const DoctorListingScreen({super.key});

  @override
  State<DoctorListingScreen> createState() => _DoctorListingScreenState();
}

class _DoctorListingScreenState extends State<DoctorListingScreen> {
  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  
  // Sorting
  String _selectedSort = 'All';
  final List<String> _sortOptions = ['All', 'Experience', 'Fee: Low to High', 'Fee: High to Low', 'Rating'];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await UserService().getAllDoctors();
      if (mounted) {
        setState(() {
          _allDoctors = doctors;
          _filteredDoctors = doctors;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _onSortChanged(String newSort) {
    setState(() {
      _selectedSort = newSort;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    List<Doctor> temp = _allDoctors.where((doc) {
      return doc.name.toLowerCase().contains(query) || 
             doc.specialization.toLowerCase().contains(query);
    }).toList();

    // sorting logic
    switch (_selectedSort) {
      case 'Experience':
        temp.sort((a, b) => b.experience.compareTo(a.experience)); // High to Low
        break;
      case 'Fee: Low to High':
        temp.sort((a, b) => a.fee.compareTo(b.fee));
        break;
      case 'Fee: High to Low':
        temp.sort((a, b) => b.fee.compareTo(a.fee));
        break;
      case 'Rating':
        temp.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        // 'All' - no specific sort (could be ID or default)
        break;
    }

    setState(() {
      _filteredDoctors = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Find Doctors', style: AppTextStyles.h2.copyWith(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ResponsiveWebContainer(
        child: Column(
          children: [
            // Search Bar Area
            EntranceAnimation(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                color: AppColors.scaffoldBackground, // "Sticky" feel
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for doctors, specialty...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _sortOptions.map((option) {
                          final isSelected = _selectedSort == option;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(option),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) _onSortChanged(option);
                              },
                              selectedColor: AppColors.primary.withOpacity(0.1),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : AppColors.grey300,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: _isLoading 
                  ? const LoadingState()
                  : _errorMessage != null
                      ? ErrorState(message: 'Failed to load doctors', onRetry: _loadDoctors)
                      : _filteredDoctors.isEmpty
                          ? _buildEmptyState()
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 800;
                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: isWide ? 400 : constraints.maxWidth,
                              childAspectRatio: isWide ? 2.5 : 2.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredDoctors.length,
                            itemBuilder: (context, index) {
                              final doctor = _filteredDoctors[index];
                              return EntranceAnimation(
                                key: ValueKey('entrance_${doctor.id}'),
                                delay: Duration(milliseconds: isWide ? 100 * (index % 5) : 50 * (index % 10)),
                                child: DoctorCardEnhanced(
                                  key: ValueKey('doctor_card_${doctor.id}'),
                                  doctor: doctor,
                                  onTap: () => _navigateToDetail(doctor),
                                  isAvailableToday: index % 3 == 0,
                                ),
                              );
                            },
                          );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(Doctor doctor) {
    Navigator.push(
      context,
      FadePageRoute(
        child: DoctorDetailScreen(doctor: doctor),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text('No doctors found', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

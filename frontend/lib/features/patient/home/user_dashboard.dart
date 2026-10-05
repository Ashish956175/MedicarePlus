import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/doctor_model.dart';
import '../doctor/doctor_listing_screen.dart';
import '../doctor/doctor_detail_screen.dart';
import '../doctor/saved_doctors_screen.dart';
import '../appointments/my_appointments_screen.dart';
import '../../../core/widgets/responsive_web_container.dart';
import 'category_detail_screen.dart';
import '../records/wellness_wallet_screen.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../chat/presentation/screens/chat_screen.dart';
import '../home/screens/pharmacy_screen.dart';
import '../pharmacy/presentation/screens/order_history_screen.dart';

import '../../../core/services/user_service.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/login_screen.dart';

// New Widgets
import 'widgets/home_app_bar.dart';
import 'widgets/health_actions_panel.dart';
import 'widgets/doctor_card_enhanced.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/widgets/entrance_animation.dart';
import '../../../core/theme/page_transitions.dart';


class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}
class _UserDashboardState extends State<UserDashboard> {
  late Future<List<Doctor>> _doctorsFuture;
  String _userName = 'User';
  String? _userRole;
  String? _userImage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    AuthService().getName().then((name) {
      if (name != null && name.isNotEmpty && mounted) {
        setState(() => _userName = name);
      }
    });
    AuthService().getRole().then((role) {
      if (role != null && mounted) {
        setState(() => _userRole = role);
      }
    });
    AuthService().getProfileImage().then((image) {
      if (image != null && mounted) {
        setState(() => _userImage = image);
      }
    });
    _doctorsFuture = UserService().getTopDoctors();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _loadData();
    });
    await _doctorsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ResponsiveWebContainer(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Home App Bar (Greeting & Profile)
                  EntranceAnimation(
                    child: HomeAppBar(
                      userName: _userName,
                      profileImage: _userImage,
                      role: _userRole,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 2. Search Bar (Enhanced with sticky feel visual)
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 100),
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(height: 24),
                  
                  // 3. Health Actions Panel
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: HealthActionsPanel(
                      onMyAppointmentsTap: () {
                         Navigator.push(
                          context, 
                          FadePageRoute(child: const MyAppointmentsScreen())
                        );
                      },
                      onSavedDoctorsTap: () {
                         Navigator.push(
                          context, 
                          FadePageRoute(child: const SavedDoctorsScreen())
                        );
                      },
                      onWellnessWalletTap: () {
                        Navigator.push(
                          context,
                          FadePageRoute(child: const WellnessWalletScreen()),
                        );
                      },
                      onPharmacyTap: () {
                        Navigator.push(
                          context,
                          FadePageRoute(child: const PharmacyScreen()),
                        );
                      },
                      onPharmacyOrdersTap: () {
                        Navigator.push(
                          context,
                          FadePageRoute(child: const OrderHistoryScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Premium Promo Banner (Liquid Gold)
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 250),
                    child: _buildPromoBanner(),
                  ),
                  const SizedBox(height: 24),

                  // 4. Categories
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: _buildCategoriesSection(),
                  ),
                  const SizedBox(height: 24),
                  
                  // 5. Top Doctors
                  EntranceAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: _buildTopDoctorsSection(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 8,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context, 
              FadePageRoute(child: const MyAppointmentsScreen())
            );
          } else if (index == 2) {
             Navigator.push(
              context, 
              FadePageRoute(child: const ChatScreen(otherUserId: 'doctor_1', otherUserName: 'Dr. Smith'))
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search doctor, specialty...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Categories', style: AppTextStyles.h3),
            TextButton(
              onPressed: () {}, 
              child: Text(
                'See All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryItem(Icons.favorite, 'Cardiology', Colors.red),
              _buildCategoryItem(Icons.medical_services, 'General', Colors.blue),
              _buildCategoryItem(Icons.local_hospital, 'Dentist', Colors.orange),
              _buildCategoryItem(Icons.visibility, 'Neurology', Colors.purple),
              _buildCategoryItem(Icons.child_care, 'Pediatric', Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadePageRoute(
            child: CategoryDetailScreen(
              categoryName: label,
              icon: icon,
              themeColor: color,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        width: 70,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label, 
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDoctorsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Top Doctors', style: AppTextStyles.h3),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  FadePageRoute(
                    child: const DoctorListingScreen(),
                  ),
                );
              },
              child: Text(
                'See All',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Doctor>>(
          future: _doctorsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildDoctorsSkeleton();
            } else if (snapshot.hasError) {
              return ErrorState(message: 'Failed to load doctors');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                 child: Padding(
                   padding: EdgeInsets.all(24.0),
                   child: Text('No doctors available'),
                 )
              );
            }

            final doctors = snapshot.data!;
            
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                if (isWide) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: doctors.map((doctor) => SizedBox(
                      width: (constraints.maxWidth - 16) / 2, // 2 columns
                      child: DoctorCardEnhanced(
                        doctor: doctor,
                        onTap: () => _navigateToDoctorDetail(doctor),
                        isAvailableToday: doctor.id % 2 == 0, // Mock logic
                      ),
                    )).toList(),
                  );
                } else {
                  return Column(
                    children: doctors.map((doctor) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0), // Gap handled by AppCard margin
                      child: DoctorCardEnhanced(
                        doctor: doctor,
                        onTap: () => _navigateToDoctorDetail(doctor),
                        isAvailableToday: doctor.id % 2 == 0,
                      ),
                    )).toList(),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.liquidGold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.liquidGold.withOpacity(0.5)),
                    ),
                    child: Text(
                      'NEW FEATURE',
                      style: AppTextStyles.caption.copyWith(color: AppColors.liquidGold, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Health Vault is Ready!',
                    style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Access all your prescriptions and medical records in one secure place.',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        FadePageRoute(child: const WellnessWalletScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Access Wallet'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDoctorDetail(Doctor doctor) {
    Navigator.push(
      context,
      FadePageRoute(
        child: DoctorDetailScreen(doctor: doctor),
      ),
    );
  }

  Widget _buildDoctorsSkeleton() {
    return Column(
      children: List.generate(3, (index) => const Padding(
        padding: EdgeInsets.only(bottom: 16.0),
        child: SkeletonLoader(width: double.infinity, height: 100),
      )),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../doctors/doctor_approval_screen.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/login_screen.dart';
import '../../../core/services/admin_service.dart';
import 'all_users_screen.dart';
import 'all_appointments_screen.dart';
import 'specialization_management_screen.dart';
import 'activity_logs_screen.dart';
import '../../../../core/widgets/user_profile_menu.dart';
import '../monitoring/presentation/screens/system_status_screen.dart';
import '../payouts/presentation/screens/payout_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  int _totalUsers = 0;
  int _totalDoctors = 0;
  int _totalAppointments = 0;
  int _pendingDoctors = 0;
  double _totalRevenue = 0;
  Map<String, dynamic> _monthlyRevenue = {};
  Map<String, dynamic> _specRevenue = {};
  String _adminName = 'Admin';
  String? _userRole;
  String? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await AdminService().getStats();
      final pending = await AdminService().getPendingDoctors();
      final revenueData = await AdminService().getRevenueStats();
      final name = await AuthService().getName();
      final role = await AuthService().getRole();
      final profileImg = await AuthService().getProfileImage();
      
      setState(() {
        _totalDoctors = stats['totalDoctors'] ?? 0;
        _totalUsers = stats['totalPatients'] ?? 0;
        _totalAppointments = stats['totalAppointments'] ?? 0;
        _pendingDoctors = pending.length;
        _totalRevenue = (revenueData['totalRevenue'] ?? 0).toDouble();
        _monthlyRevenue = revenueData['monthlyRevenue'] ?? {};
        _specRevenue = revenueData['specializationRevenue'] ?? {};
        _adminName = name ?? 'Admin';
        _userRole = role;
        _profileImage = profileImg;
      });
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AdminDashboard: build() called');
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.displaySmall?.color,
        elevation: 0,
        actions: [
          UserProfileMenu(
            userName: _adminName,
            profileImage: _profileImage,
            role: _userRole,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text('System Command Center', style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(
              'Monitor and manage your healthcare platform',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            const SizedBox(height: 24),

            // System Health Banner
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SystemStatusScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.success, Color(0xFF00C853)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System Status',
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.9)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'All systems operational',
                            style: AppTextStyles.h3.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pending Approvals Highlight
            if (_pendingDoctors > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning, width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pending_actions, color: AppColors.warning, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending Doctor Approvals',
                            style: AppTextStyles.h3.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_pendingDoctors doctors awaiting verification',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DoctorApprovalScreen()),
                        ).then((_) => _loadData());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Review'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // KPI Cards
            Text('Key Metrics', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48 - 24) / 3,
                  child: _buildKPICard(
                    'Total Users',
                    _totalUsers.toString(),
                    Icons.people,
                    AppColors.primary,
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48 - 24) / 3,
                  child: _buildKPICard(
                    'Doctors',
                    _totalDoctors.toString(),
                    Icons.medical_services,
                    AppColors.success,
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 48 - 24) / 3,
                  child: _buildKPICard(
                    'Appointments',
                    _totalAppointments.toString(),
                    Icons.event,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Financial Summary Card
            Text('Financial Overview', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _buildRevenueCard(),
            const SizedBox(height: 32),

            // Quick Navigation
            Text('Quick Actions', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildQuickActionCard(
                  context,
                  'Doctor Approvals',
                  Icons.how_to_reg,
                  AppColors.primary,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DoctorApprovalScreen()),
                  ).then((_) => _loadData()),
                ),
                _buildQuickActionCard(
                  context,
                  'User Management',
                  Icons.people_alt,
                  AppColors.success,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllUsersScreen()),
                    );
                  },
                ),
                _buildQuickActionCard(
                  context,
                  'Appointments',
                  Icons.event_note,
                  AppColors.warning,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AllAppointmentsScreen()),
                    );
                  },
                ),
                _buildQuickActionCard(
                  context,
                  'Specializations',
                  Icons.category,
                  AppColors.primary,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SpecializationManagementScreen()),
                    );
                  },
                ),
                _buildQuickActionCard(
                  context,
                  'Activity Logs',
                  Icons.history,
                  AppColors.warning,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActivityLogsScreen()),
                    );
                  },
                ),

                _buildQuickActionCard(
                  context,
                  'Payouts',
                  Icons.payments,
                  AppColors.success,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PayoutManagementScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Platform Revenue',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_totalRevenue.toStringAsFixed(2)}',
                    style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 32),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            'Revenue by Specialization',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._specRevenue.entries.take(3).map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.8))),
                Text('₹${e.value.toStringAsFixed(0)}', style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          )).toList(),
          if (_specRevenue.length > 3)
            Text(
              '+ ${_specRevenue.length - 3} more categories',
              style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.6), fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Theme.of(context).brightness == Brightness.light ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.h2.copyWith(color: color, fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
          boxShadow: Theme.of(context).brightness == Brightness.light ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

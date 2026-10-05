import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../schedule/availability_manager_screen.dart';
import '../prescriptions/prescription_builder_screen.dart';
import '../../telehealth/presentation/screens/consultation_screen.dart';
import '../../chat/presentation/screens/chat_screen.dart';
import '../analytics/presentation/screens/doctor_analytics_screen.dart';
import '../referrals/presentation/screens/create_referral_screen.dart';
import '../patients/presentation/screens/patient_insights_list_screen.dart';
import '../records/presentation/screens/patient_records_screen.dart';

import 'package:intl/intl.dart';
import '../../../core/services/doctor_service.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../auth/login_screen.dart';
import '../../../core/widgets/user_profile_menu.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  late Future<List<Appointment>> _appointmentsFuture;
  Map<String, int> _stats = {'pending': 0, 'completed': 0, 'total': 0};
  String _doctorName = 'Doctor';
  String? _userRole;
  String? _profileImage;
  int _totalPatients = 0;
  bool _isEmergencyLive = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    AuthService().getName().then((name) {
      if (name != null && name.isNotEmpty) {
        setState(() => _doctorName = name);
      }
    });
    AuthService().getRole().then((role) {
      if (role != null && mounted) {
        setState(() => _userRole = role);
      }
    });
    AuthService().getProfileImage().then((image) {
      if (image != null && mounted) {
        setState(() => _profileImage = image);
      }
    });

    setState(() {
      _appointmentsFuture = DoctorService().getDoctorAppointments().then((apps) {
        // Fetch real stats from backend for accuracy
        DoctorService().getStats().then((stats) {
          if (mounted) {
            setState(() {
              _stats['total'] = stats['totalAppointments'] ?? 0;
              _stats['completed'] = stats['completedAppointments'] ?? 0;
              _stats['pending'] = stats['pendingAppointments'] ?? 0;
            });
          }
        });
        _totalPatients = apps.map((a) => a.userId).toSet().length;
        return apps;
      });
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FutureBuilder<List<Appointment>>(
          future: _appointmentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
               return const LoadingState();
            } else if (snapshot.hasError) {
               return ErrorState(message: 'Failed to load dashboard', onRetry: _loadData);
            } 

            final appointments = snapshot.data ?? [];
            
            // Filter for Today
            final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
            final todayAppointments = appointments.where((a) => a.date == todayStr).toList();
            
            // Sort by time
            todayAppointments.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));
            
            // Find next appointment
            final now = DateTime.now();
            final nextAppointment = todayAppointments.firstWhere(
              (app) {
                try {
                  final timeParts = app.timeSlot.split(' ');
                  final hourMinute = timeParts[0].split(':');
                  int hour = int.parse(hourMinute[0]);
                  final isPM = timeParts[1].toUpperCase() == 'PM';
                  if (isPM && hour != 12) hour += 12;
                  if (!isPM && hour == 12) hour = 0;
                  
                  final appointmentTime = DateTime(now.year, now.month, now.day, hour, 0);
                  return appointmentTime.isAfter(now) && app.status == 'BOOKED';
                } catch (e) {
                  return false;
                }
              },
              orElse: () => Appointment(
                id: -1, 
                userId: 0, 
                doctorId: 0, 
                date: '', 
                timeSlot: '', 
                status: ''
              ),
            );

            final todayBooked = todayAppointments.where((a) => a.status == 'BOOKED').length;
            final todayCompleted = todayAppointments.where((a) => a.status == 'COMPLETED').length;

            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getGreeting(), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                              Text(_doctorName.startsWith('Dr.') ? _doctorName : 'Dr. $_doctorName', style: AppTextStyles.h2),
                            ],
                          ),
                        ),
                        UserProfileMenu(
                          userName: _doctorName,
                          profileImage: _profileImage,
                          role: _userRole,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Emergency Toggle Banner
                    GestureDetector(
                      onTap: () => setState(() => _isEmergencyLive = !_isEmergencyLive),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isEmergencyLive ? AppColors.error.withOpacity(0.1) : AppColors.cardBackground.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isEmergencyLive ? AppColors.error : AppColors.divider,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isEmergencyLive ? AppColors.error : AppColors.grey400,
                                shape: BoxShape.circle,
                                boxShadow: _isEmergencyLive ? [
                                  BoxShadow(color: AppColors.error.withOpacity(0.5), blurRadius: 4, spreadRadius: 2)
                                ] : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isEmergencyLive ? 'EMERGENCY LIVE' : 'Emergency Mode Off',
                              style: AppTextStyles.caption.copyWith(
                                color: _isEmergencyLive ? AppColors.error : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: _isEmergencyLive,
                              onChanged: (val) => setState(() => _isEmergencyLive = val),
                              activeColor: AppColors.error,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Text('Quick Actions', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildQuickAction(
                            'Analytics', 
                            Icons.analytics_outlined, 
                            AppColors.primary,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorAnalyticsScreen())),
                          ),
                          _buildQuickAction(
                            'Referrals', 
                            Icons.assignment_outlined, 
                            AppColors.secondary,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateReferralScreen())),
                          ),
                          _buildQuickAction(
                            'Insights', 
                            Icons.insights_outlined, 
                            AppColors.warning,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientInsightsListScreen())),
                          ),
                          _buildQuickAction(
                            'Records', 
                            Icons.folder_shared_outlined, 
                            AppColors.success,
                            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientRecordsScreen())),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Today at a Glance Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF3D5AFE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.today, color: Colors.white, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Today at a Glance',
                                style: AppTextStyles.h3.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildGlanceItem('Total', todayAppointments.length.toString()),
                              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                              _buildGlanceItem('Pending', todayBooked.toString()),
                              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                              _buildGlanceItem('Done', todayCompleted.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Stats
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Total Patients', _totalPatients.toString(), Icons.people, AppColors.success)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Appointments', _stats['total'].toString(), Icons.event, AppColors.primary)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('Rating', '4.8', Icons.star, AppColors.warning)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Next Appointment Highlight
                    if (nextAppointment.id != -1) ...[
                      Text('Next Appointment', style: AppTextStyles.h3),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          border: Border.all(color: AppColors.warning, width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.alarm, color: AppColors.warning, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Patient ID: ${nextAppointment.userId}', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('${nextAppointment.timeSlot} - General Consultation', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: AppColors.warning),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Today's Appointments Timeline
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Today's Schedule", style: AppTextStyles.h3),
                        Text('${todayAppointments.length} appointments', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    todayAppointments.isEmpty 
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: todayAppointments.length,
                          itemBuilder: (context, index) {
                            final app = todayAppointments[index];
                            final isNext = app.id == nextAppointment.id;
                            
                            // Check for Missed Status
                            bool isMissed = false;
                            if (app.status == 'BOOKED') {
                              try {
                                final timeParts = app.timeSlot.split(' '); // "10:00 AM"
                                final timeStr = timeParts[0];
                                final amPm = timeParts.length > 1 ? timeParts[1] : '';
                                
                                final hourMin = timeStr.split(':');
                                int hour = int.parse(hourMin[0]);
                                int minute = int.parse(hourMin[1]);
                                
                                if (amPm.toUpperCase() == 'PM' && hour != 12) hour += 12;
                                if (amPm.toUpperCase() == 'AM' && hour == 12) hour = 0;
                                
                                final now = DateTime.now();
                                final appTime = DateTime(now.year, now.month, now.day, hour, minute);
                                
                                // Considered missed if 30 mins passed since start time
                                if (now.isAfter(appTime.add(const Duration(minutes: 30)))) {
                                  isMissed = true;
                                }
                              } catch (e) {
                                // ignore parse errors
                              }
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: AppCard(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Timeline indicator
                                        Container(
                                          width: 4,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: app.status == 'COMPLETED' ? AppColors.success : 
                                                    app.status == 'CANCELLED' ? AppColors.error :
                                                    isMissed ? AppColors.error : // Red for missed
                                                    isNext ? AppColors.warning : AppColors.primary,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        CircleAvatar(
                                          backgroundColor: AppColors.grey200,
                                          child: const Icon(Icons.person, color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text('Patient ID: ${app.userId}', style: AppTextStyles.h3.copyWith(fontSize: 15)),
                                                  const SizedBox(width: 8),
                                                  if (isMissed)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.error.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(color: AppColors.error, width: 0.5),
                                                      ),
                                                      child: Text('Missed', style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                                                    )
                                                  else if (app.status == 'COMPLETED')
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.success.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(4),
                                                        border: Border.all(color: AppColors.success, width: 0.5),
                                                      ),
                                                      child: Text('Completed', style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                                                  const SizedBox(width: 4),
                                                  Text(app.timeSlot, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        StatusChip(status: app.status == 'BOOKED' ? Status.booked : 
                                                           app.status == 'COMPLETED' ? Status.completed : 
                                                           Status.cancelled),
                                      ],
                                    ),
                                    if (app.status == 'BOOKED' && !isMissed) ...[
                                      const Divider(height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.videocam_outlined, color: AppColors.secondary),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ConsultationScreen(
                                                    appointmentId: app.id,
                                                    patientId: app.userId,
                                                  ),
                                                ),
                                              );
                                            },
                                            tooltip: 'Start Video Consultation',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ChatScreen(
                                                    otherUserId: app.userId.toString(),
                                                    otherUserName: 'Patient ${app.userId}',
                                                  ),
                                                ),
                                              );
                                            },
                                            tooltip: 'Chat with Patient',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.description_outlined, color: AppColors.primary),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => PrescriptionBuilderScreen(
                                                    appointmentId: app.id,
                                                    patientId: app.userId,
                                                  ),
                                                ),
                                              );
                                            },
                                            tooltip: 'Write Prescription',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AvailabilityManagerScreen()),
          );
        },
        label: const Text('Manage Schedule'),
        icon: const Icon(Icons.edit_calendar),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildGlanceItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 28)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.9))),
      ],
    );
  }

  Widget _buildQuickAction(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h3.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.event_available, size: 80, color: AppColors.grey300),
            const SizedBox(height: 16),
            Text(
              'No appointments today',
              style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Enjoy your day off!',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

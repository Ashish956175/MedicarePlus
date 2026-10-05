import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/services/appointment_service.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/glass_card.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Appointment>> _appointmentsFuture;
  List<Appointment>? _cachedAppointments;
  Map<int, Doctor> _doctorMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  void _loadAppointments() {
     _loadDoctors();
     setState(() {
       _appointmentsFuture = AppointmentService().getUserAppointments();
     });
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await UserService().getAllDoctors();
      if (mounted) {
        setState(() {
          _doctorMap = {for (var doc in doctors) doc.id: doc};
        });
      }
    } catch (e) {
      debugPrint('Error loading doctors: $e');
    }
  }

  Future<void> _refreshAppointments() async {
    final appointments = await AppointmentService().getUserAppointments();
    setState(() {
      _cachedAppointments = appointments;
      _appointmentsFuture = Future.value(appointments);
    });
  }

  int _getCountForStatus(List<Appointment> appointments, Status status) {
    return appointments.where((app) {
      if (app.status == null) return false;
      final appStatus = app.status.toUpperCase();
      if (status == Status.booked) return appStatus == 'BOOKED';
      if (status == Status.cancelled) return appStatus == 'CANCELLED';
      if (status == Status.completed) return appStatus == 'COMPLETED';
      return false;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Appointments', 
          style: AppTextStyles.h2.copyWith(
            fontSize: 20,
            color: isDark ? Colors.white : AppColors.textPrimary,
          )
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: FutureBuilder<List<Appointment>>(
            future: _appointmentsFuture,
            builder: (context, snapshot) {
              final appointments = snapshot.data ?? _cachedAppointments ?? [];
              final upcomingCount = _getCountForStatus(appointments, Status.booked);
              final completedCount = _getCountForStatus(appointments, Status.completed);
              final cancelledCount = _getCountForStatus(appointments, Status.cancelled);

              return TabBar(
                controller: _tabController,
                labelColor: isDark ? AppColors.liquidGold : AppColors.primary,
                unselectedLabelColor: isDark ? Colors.white70 : AppColors.textSecondary,
                indicatorColor: isDark ? AppColors.liquidGold : AppColors.primary,
                labelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(child: _buildTabWithBadge('Upcoming', upcomingCount)),
                  Tab(child: _buildTabWithBadge('Past', completedCount)),
                  Tab(child: _buildTabWithBadge('Cancelled', cancelledCount)),
                ],
              );
            },
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentList(Status.booked),
          _buildAppointmentList(Status.completed),
          _buildAppointmentList(Status.cancelled),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String label, int count) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? AppColors.liquidGold : AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: isDark ? AppColors.royalNoir : Colors.white, 
                fontSize: 10, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAppointmentList(Status status) {
    return FutureBuilder<List<Appointment>>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingState();
        } else if (snapshot.hasError) {
          return ErrorState(message: 'Failed to load appointments', onRetry: _loadAppointments);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(status);
        }

        // Cache for badge counts
        if (snapshot.hasData) {
          _cachedAppointments = snapshot.data;
        }

        // Filter by status
        final allAppointments = snapshot.data!;
        final filtered = allAppointments.where((app) {
           if (app.status == null) return false;
           final appStatus = app.status.toUpperCase();
           if (status == Status.booked) return appStatus == 'BOOKED';
           if (status == Status.cancelled) return appStatus == 'CANCELLED';
           if (status == Status.completed) return appStatus == 'COMPLETED';
           return false;
        }).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState(status);
        }

        return RefreshIndicator(
          onRefresh: _refreshAppointments,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return _buildAppointmentCard(filtered[index], status);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Status status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String message;
    IconData icon;
    
    switch (status) {
      case Status.booked:
        message = 'No upcoming appointments.\nBook your first appointment!';
        icon = Icons.event_available;
        break;
      case Status.completed:
        message = 'No past appointments yet.';
        icon = Icons.history;
        break;
      case Status.cancelled:
        message = 'No cancelled appointments.';
        icon = Icons.event_busy;
        break;
      default:
        message = 'No appointments found.';
        icon = Icons.event_available;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: isDark ? Colors.white.withOpacity(0.1) : AppColors.grey300),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? Colors.white60 : AppColors.textSecondary
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, Status status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canCancel = _canCancelAppointment(appointment);
    
    Doctor? doctor;
    try {
      doctor = _doctorMap[appointment.doctorId];
    } catch (e) {
      debugPrint('Error looking up doctor ${appointment.doctorId}: $e');
    }

    Widget cardContent = Column(
      children: [
        Row(
          children: [
            // Doctor Avatar
            (() {
              final String? imgUrl = doctor?.image;
              final bool hasImage = imgUrl != null && imgUrl.isNotEmpty;
              
              return CircleAvatar(
                radius: 28,
                backgroundColor: isDark ? Colors.white.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                backgroundImage: hasImage
                    ? (imgUrl!.startsWith('http') 
                        ? NetworkImage(imgUrl) 
                        : AssetImage(imgUrl) as ImageProvider)
                    : null,
                child: !hasImage
                    ? Icon(Icons.person, color: isDark ? AppColors.liquidGold : AppColors.primary, size: 28)
                    : null,
              );
            })(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctor?.name ?? 'Doctor (ID: ${appointment.doctorId})',
                          style: AppTextStyles.h3.copyWith(
                            fontSize: 16,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (status == Status.booked && _isWithin24Hours(appointment))
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.notifications_active, size: 14, color: AppColors.warning),
                              const SizedBox(width: 4),
                              Text(
                                'Soon',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor?.specialization ?? 'General Consultation',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? Colors.white70 : AppColors.textSecondary
                    ),
                  ),
                ],
              ),
            ),
            StatusChip(status: status),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: isDark ? Colors.white10 : AppColors.grey200, height: 1),
        const SizedBox(height: 16),
        Row(
           children: [
             Icon(Icons.calendar_today, size: 18, color: isDark ? AppColors.liquidGold : AppColors.primary),
             const SizedBox(width: 8),
             Text(appointment.date, 
               style: AppTextStyles.bodyMedium.copyWith(
                 color: isDark ? Colors.white70 : AppColors.textPrimary
               )
             ),
             const Spacer(),
             Icon(Icons.access_time, size: 18, color: isDark ? AppColors.liquidGold : AppColors.primary),
             const SizedBox(width: 8),
             Text(appointment.timeSlot, 
               style: AppTextStyles.bodyMedium.copyWith(
                 color: isDark ? Colors.white70 : AppColors.textPrimary
               )
             ),
           ],
        ),
        if (status == Status.booked) ...[ 
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: canCancel ? () => _showCancelConfirmation(context, appointment.id) : null,
              icon: const Icon(Icons.cancel_outlined),
              label: Text(canCancel ? 'Cancel Appointment' : 'Cannot Cancel (Too Close)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: canCancel ? AppColors.error : (isDark ? Colors.white30 : AppColors.textHint),
                side: BorderSide(color: canCancel ? AppColors.error : (isDark ? Colors.white10 : AppColors.grey300)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: isDark 
        ? GlassCard(padding: const EdgeInsets.all(16), child: cardContent)
        : AppCard(child: cardContent),
    );
  }

  bool _canCancelAppointment(Appointment appointment) {
    try {
      // Parse the date and time
      // Assuming date format: yyyy-MM-dd and timeSlot format: "HH:MM AM/PM"
      final dateParts = appointment.date.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      // Parse time slot (e.g., "09:00 AM")
      final timeParts = appointment.timeSlot.split(' ');
      final hourMinute = timeParts[0].split(':');
      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);
      final isPM = timeParts[1].toUpperCase() == 'PM';

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      final appointmentDateTime = DateTime(year, month, day, hour, minute);
      final now = DateTime.now();
      final difference = appointmentDateTime.difference(now);

      // Allow cancel if more than 2 hours away
      return difference.inHours >= 2;
    } catch (e) {
      // If parsing fails, allow cancel (default safe behavior)
      return true;
    }
  }

  bool _isWithin24Hours(Appointment appointment) {
    try {
      final dateParts = appointment.date.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      final timeParts = appointment.timeSlot.split(' ');
      final hourMinute = timeParts[0].split(':');
      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);
      final isPM = timeParts[1].toUpperCase() == 'PM';

      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      final appointmentDateTime = DateTime(year, month, day, hour, minute);
      final now = DateTime.now();
      final difference = appointmentDateTime.difference(now);

      // Check if within 24 hours and in the future
      return difference.inHours >= 0 && difference.inHours <= 24;
    } catch (e) {
      return false;
    }
  }

  void _showCancelConfirmation(BuildContext context, int appointmentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            const SizedBox(width: 12),
            const Text('Cancel Appointment?'),
          ],
        ),
        content: const Text('Are you sure you want to cancel this appointment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Appointment'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await AppointmentService().cancelAppointment(appointmentId);
              if (success) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment cancelled successfully'),
                    backgroundColor: AppColors.success,
                  )
                );
                _loadAppointments();
              } else {
                 if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to cancel appointment'),
                    backgroundColor: AppColors.error,
                  )
                );
              }
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

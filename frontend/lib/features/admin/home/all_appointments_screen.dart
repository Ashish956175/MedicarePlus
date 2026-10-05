import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/models/appointment_model.dart';
import '../../../core/widgets/app_card.dart';

class AllAppointmentsScreen extends StatefulWidget {
  const AllAppointmentsScreen({super.key});

  @override
  State<AllAppointmentsScreen> createState() => _AllAppointmentsScreenState();
}

class _AllAppointmentsScreenState extends State<AllAppointmentsScreen> {
  final AdminService _adminService = AdminService();
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String _statusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _adminService.getAllAppointments();
      setState(() => _appointments = appointments);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppointments = _statusFilter == 'ALL'
        ? _appointments
        : _appointments.where((a) => a.status == _statusFilter).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('All Appointments'),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).textTheme.displaySmall?.color,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (val) => setState(() => _statusFilter = val),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ALL', child: Text('All Status')),
              const PopupMenuItem(value: 'BOOKED', child: Text('Booked')),
              const PopupMenuItem(value: 'COMPLETED', child: Text('Completed')),
              const PopupMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredAppointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: AppColors.grey300),
                      const SizedBox(height: 16),
                      Text(
                        'No appointments found',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredAppointments.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final app = filteredAppointments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.event, color: AppColors.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('MMM dd, yyyy').format(DateTime.parse(app.date)),
                                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                                    ),
                                  ],
                                ),
                                _buildStatusBadge(app.status),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(Icons.person_outline, 'User ID:', app.userId.toString()),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.medical_services_outlined, 'Doctor ID:', app.doctorId.toString()),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.access_time, 'Time Slot:', app.timeSlot),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        const SizedBox(width: 8),
        Text(value, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'BOOKED':
        color = AppColors.primary;
        break;
      case 'COMPLETED':
        color = AppColors.success;
        break;
      case 'CANCELLED':
        color = AppColors.error;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

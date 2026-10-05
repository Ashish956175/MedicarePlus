import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/constants/api_constants.dart';

import 'package:intl/intl.dart';
import '../../../core/services/appointment_service.dart';
import '../appointments/booking_summary_screen.dart';

import '../../../core/services/schedule_service.dart';
import '../../../core/models/availability_model.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  late DateTime _selectedDate;
  String? _selectedTimeSlot;
  bool _isBooking = false;
  bool _isLoadingSlots = false;
  late bool _isTodayAvailable;

  // Real time slots from backend
  Map<String, List<String>> _availabilityMap = {};

  @override
  void initState() {
    super.initState();
    _isTodayAvailable = true; // Default
    _selectedDate = DateTime.now();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoadingSlots = true);
    try {
      final slots = await ScheduleService().getDoctorAvailability(widget.doctor.id);
      final newMap = <String, List<String>>{};
      for (var slot in slots) {
        newMap.putIfAbsent(slot.date, () => []).add(slot.timeSlot);
      }
      setState(() {
        _availabilityMap = newMap;
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        _isTodayAvailable = _availabilityMap.containsKey(todayStr) && _availabilityMap[todayStr]!.isNotEmpty;
        
        // If today not available, select first available date in nextDays
        if (!_isTodayAvailable) {
           for (int i = 1; i < 7; i++) {
             final d = DateTime.now().add(Duration(days: i));
             final ds = DateFormat('yyyy-MM-dd').format(d);
             if (_availabilityMap.containsKey(ds) && _availabilityMap[ds]!.isNotEmpty) {
               _selectedDate = d;
               break;
             }
           }
        }
      });
    } catch (e) {
      debugPrint('Error loading availability: $e');
    } finally {
      setState(() => _isLoadingSlots = false);
    }
  }

  // Generate next 7 days
  List<DateTime> get _nextDays => List.generate(7, (index) => DateTime.now().add(Duration(days: index)));

  Future<void> _bookAppointment() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: AppColors.error,
        )
      );
      return;
    }

    setState(() => _isBooking = true);

    try {
      // Navigate to Summary Screen instead of direct booking
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSummaryScreen(
            doctor: widget.doctor,
            date: _selectedDate,
            time: _selectedTimeSlot!,
          ),
        ),
      );

      // We don't book here anymore, reset loading state
      setState(() => _isBooking = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isBooking = false);
    }
  }

  // Success dialog removed as it is now handled in Summary Screen
  /* void _showSuccessDialog() { ... } */

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 48),
            const SizedBox(height: 16),
            Text('Booking Confirmed!', style: AppTextStyles.h3),
          ],
        ),
        content: Text(
          'Your appointment with ${widget.doctor.name} is scheduled for ${DateFormat('MMM d').format(_selectedDate)} at $_selectedTimeSlot.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Go back
              },
              child: Text('Done', style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image
            Hero(
              tag: 'doctor_avatar_${widget.doctor.id}',
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: (widget.doctor.image.startsWith('http')) 
                        ? NetworkImage(widget.doctor.image) 
                        : AssetImage(widget.doctor.image) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                   decoration: BoxDecoration(
                     gradient: LinearGradient(
                       begin: Alignment.topCenter,
                       end: Alignment.bottomCenter,
                       colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                     ),
                   ),
                ),
              ),
            ),
            
            // Content
            Container(
              transform: Matrix4.translationValues(0, -32, 0),
              decoration: const BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Verification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text(widget.doctor.name, style: AppTextStyles.h2)),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: AppColors.primary, size: 20),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(widget.doctor.specialization, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
                            const SizedBox(height: 8),
                            // Clinic Info
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: AppColors.textHint, size: 16),
                                const SizedBox(width: 4),
                                Text('City General Hospital', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.warning, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              widget.doctor.rating.toString(),
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.warning),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Qualifications Section (New)
                  Text('Qualifications', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    'MBBS, MD - ${widget.doctor.specialization}, FACC', // Mock qualifications
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),

                  // About Section
                  Text('About', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    widget.doctor.about,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('Patients', '1.5K+'),
                      _buildStatItem('Experience', '${widget.doctor.experience} Yrs'),
                      _buildStatItem('Reviews', '${widget.doctor.reviews}+'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Availability
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select Date', style: AppTextStyles.h3),
                      if (!_isTodayAvailable)
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: AppColors.error.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Text(
                             'Not Available Today', 
                             style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)
                           ),
                         ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _nextDays.map((date) {
                         // Check if this date allows booking
                         final isToday = date.day == DateTime.now().day && date.month == DateTime.now().month;
                         final isDisabled = isToday && !_isTodayAvailable;
                         
                         final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                         
                         return GestureDetector(
                           onTap: isDisabled ? null : () => setState(() => _selectedDate = date),
                           child: Opacity(
                             opacity: isDisabled ? 0.5 : 1.0,
                             child: _buildDateChip(DateFormat('EEE, d').format(date), isSelected),
                           ),
                         );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text('Select Time', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  _isLoadingSlots 
                    ? const Center(child: CircularProgressIndicator())
                    : _availabilityMap[DateFormat('yyyy-MM-dd').format(_selectedDate)] == null || _availabilityMap[DateFormat('yyyy-MM-dd').format(_selectedDate)]!.isEmpty
                      ? Text('No slots available for this date', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))
                      : Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _availabilityMap[DateFormat('yyyy-MM-dd').format(_selectedDate)]!.map((slot) {
                            final isSelected = slot == _selectedTimeSlot;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedTimeSlot = slot),
                              child: _buildTimeChip(slot, isSelected),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
           color: Colors.white,
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.05),
               blurRadius: 10,
               offset: const Offset(0, -5),
             ),
           ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Consultation Price', style: AppTextStyles.caption),
                  Text('₹${widget.doctor.fee.toStringAsFixed(0)}', style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: PrimaryButton(
                  text: _isBooking ? 'Booking...' : 'Book Appointment',
                  onPressed: _isBooking ? () {} : _bookAppointment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Text(value, style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/models/availability_model.dart';

class AvailabilityManagerScreen extends StatefulWidget {
  const AvailabilityManagerScreen({super.key});

  @override
  State<AvailabilityManagerScreen> createState() => _AvailabilityManagerScreenState();
}

class _AvailabilityManagerScreenState extends State<AvailabilityManagerScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<String> _timeSlots = [
    '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'
  ];
  final Set<String> _selectedSlots = {};
  final Map<String, Set<String>> _scheduledSlots = {}; // date -> slots
  String? _validationError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() => _isLoading = true);
    try {
      final availability = await ScheduleService().getMyAvailability();
      setState(() {
        _scheduledSlots.clear();
        for (var slot in availability) {
          _scheduledSlots.putIfAbsent(slot.date, () => {}).add(slot.timeSlot);
        }
      });
    } catch (e) {
      debugPrint('Error loading availability: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _isPastDate(DateTime date) {
    final today = DateTime.now();
    return date.isBefore(DateTime(today.year, today.month, today.day));
  }

  bool _hasOverlap() {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final existingSlots = _scheduledSlots[dateKey] ?? {};
    return _selectedSlots.any((slot) => existingSlots.contains(slot));
  }

  Future<void> _validateAndSave() async {
    if (_isPastDate(_selectedDate)) {
      setState(() => _validationError = 'Cannot schedule slots for past dates');
      return;
    }
    
    if (_selectedSlots.isEmpty) {
      setState(() => _validationError = 'Please select at least one time slot');
      return;
    }

    if (_hasOverlap()) {
      setState(() => _validationError = 'Some slots are already scheduled for this date');
      return;
    }

    setState(() => _isLoading = true);
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    try {
      for (var slot in _selectedSlots) {
        await ScheduleService().addAvailability(dateKey, slot);
      }
      
      await _loadAvailability();
      setState(() {
        _selectedSlots.clear();
        _validationError = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Availability saved successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _validationError = 'Failed to save: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSlot(String dateKey, String slot) async {
    setState(() => _isLoading = true);
    try {
      final success = await ScheduleService().deleteAvailability(dateKey, slot);
      if (success) {
        await _loadAvailability();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Slot deleted'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error deleting slot: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final isPast = _isPastDate(_selectedDate);
    final existingSlots = _scheduledSlots[dateKey] ?? {};

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Manage Availability'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calendar Picker
            Text('Select Date', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedDate),
                        style: AppTextStyles.h3.copyWith(fontSize: 16),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 14,
                      itemBuilder: (context, index) {
                        final date = DateTime.now().add(Duration(days: index));
                        final isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);
                        final isPastDate = _isPastDate(date);
                        return GestureDetector(
                          onTap: isPastDate ? null : () {
                            setState(() {
                              _selectedDate = date;
                              _validationError = null;
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isPastDate ? AppColors.grey200 : 
                                     isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isPastDate ? AppColors.grey300 :
                                       isSelected ? AppColors.primary : AppColors.grey300,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getShortMonth(date.month),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isPastDate ? AppColors.textHint :
                                           isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  date.day.toString(),
                                  style: AppTextStyles.h3.copyWith(
                                    color: isPastDate ? AppColors.textHint :
                                           isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Validation Error
            if (_validationError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Time Slot Selection
            Text('Available Time Slots', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              isPast ? 'Cannot add slots for past dates' : 'Select time slots for ${DateFormat('MMM dd').format(_selectedDate)}',
              style: AppTextStyles.bodySmall.copyWith(color: isPast ? AppColors.error : AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _timeSlots.map((slot) {
                final isSelected = _selectedSlots.contains(slot);
                final isExisting = existingSlots.contains(slot);
                return GestureDetector(
                  onTap: isPast || isExisting ? null : () {
                    setState(() {
                       if (isSelected) {
                         _selectedSlots.remove(slot);
                       } else {
                         _selectedSlots.add(slot);
                       }
                       _validationError = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isExisting ? AppColors.grey200 :
                             isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isExisting ? AppColors.grey300 :
                               isSelected ? AppColors.primary : AppColors.grey300,
                      ),
                    ),
                    child: Text(
                      slot,
                      style: TextStyle(
                        color: isExisting ? AppColors.textHint :
                               isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
             const SizedBox(height: 24),
             
             if (!isPast)
             _isLoading 
               ? const Center(child: CircularProgressIndicator())
               : PrimaryButton(
                   text: 'Save Selected Slots',
                   onPressed: _selectedSlots.isEmpty ? null : _validateAndSave,
                 ),
             
             const SizedBox(height: 32),
             
             // Slot Preview
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 Text('Scheduled Slots', style: AppTextStyles.h3),
                 Text('${_scheduledSlots.values.expand((e) => e).length} total', 
                   style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
               ],
             ),
             const SizedBox(height: 16),
             
             if (_scheduledSlots.isEmpty)
               Center(
                 child: Padding(
                   padding: const EdgeInsets.all(40.0),
                   child: Column(
                     children: [
                       Icon(Icons.event_busy, size: 60, color: AppColors.grey300),
                       const SizedBox(height: 16),
                       Text(
                         'No slots scheduled yet',
                         style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                       ),
                     ],
                   ),
                 ),
               )
             else
               ListView.builder(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: _scheduledSlots.keys.length,
                 itemBuilder: (context, index) {
                   final dateKey = _scheduledSlots.keys.elementAt(index);
                   final slots = _scheduledSlots[dateKey]!.toList()..sort();
                   final date = DateTime.parse(dateKey);
                   
                   return Container(
                     margin: const EdgeInsets.only(bottom: 12),
                     child: AppCard(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             children: [
                               Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                               const SizedBox(width: 8),
                               Text(
                                 DateFormat('EEEE, MMM dd, yyyy').format(date),
                                 style: AppTextStyles.h3.copyWith(fontSize: 15),
                               ),
                             ],
                           ),
                           const SizedBox(height: 12),
                           Wrap(
                             spacing: 8,
                             runSpacing: 8,
                             children: slots.map((slot) {
                               return Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                 decoration: BoxDecoration(
                                   color: AppColors.success.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(6),
                                   border: Border.all(color: AppColors.success.withOpacity(0.3)),
                                 ),
                                 child: Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     Icon(Icons.access_time, size: 14, color: AppColors.success),
                                     const SizedBox(width: 4),
                                     Text(
                                       slot,
                                       style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                                     ),
                                     const SizedBox(width: 8),
                                     GestureDetector(
                                       onTap: () => _deleteSlot(dateKey, slot),
                                       child: const Icon(Icons.close, size: 14, color: AppColors.error),
                                     ),
                                   ],
                                 ),
                               );
                             }).toList(),
                           ),
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
  }
  
  String _getShortMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}

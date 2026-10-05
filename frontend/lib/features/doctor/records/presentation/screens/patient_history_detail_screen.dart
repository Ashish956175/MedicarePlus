import 'package:flutter/material.dart';
import 'package:medicare_plus/core/theme/app_colors.dart';
import 'package:medicare_plus/core/theme/app_text_styles.dart';
import 'package:medicare_plus/core/widgets/glass_card.dart';
import 'package:medicare_plus/core/services/doctor_service.dart';
import 'package:intl/intl.dart';

class PatientHistoryDetailScreen extends StatefulWidget {
  final int patientId;
  final String patientName;

  const PatientHistoryDetailScreen({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<PatientHistoryDetailScreen> createState() => _PatientHistoryDetailScreenState();
}

class _PatientHistoryDetailScreenState extends State<PatientHistoryDetailScreen> {
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = true;
  List<dynamic> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await _doctorService.getPatientHistory(widget.patientId);
      final prescriptions = history['prescriptions'] as List<dynamic>? ?? [];
      final records = history['medicalRecords'] as List<dynamic>? ?? [];

      // Merge and sort by date
      _historyItems = [
        ...prescriptions.map((p) => {
          ...Map<String, dynamic>.from(p),
          'type': 'prescription',
          'date_val': DateTime.parse(p['createdAt'])
        }),
        ...records.map((r) => {
          ...Map<String, dynamic>.from(r),
          'type': 'record',
          'date_val': DateTime.parse(r['uploadedAt'])
        }),
      ];

      _historyItems.sort((a, b) => (b['date_val'] as DateTime).compareTo(a['date_val'] as DateTime));

      setState(() {});
    } catch (e) {
      debugPrint('Error loading patient history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white60 : AppColors.textSecondary;
    final goldColor = isDark ? AppColors.liquidGold : AppColors.primary;
    final timelineLineColor = isDark ? Colors.white10 : AppColors.grey200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient History', style: TextStyle(color: textColor, fontSize: 18)),
            Text(widget.patientName, style: TextStyle(color: goldColor, fontSize: 14)),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: goldColor))
          : _historyItems.isEmpty
              ? _buildEmptyState(subTextColor)
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _historyItems.length,
                  itemBuilder: (context, index) {
                    final item = _historyItems[index];
                    return _buildTimelineItem(item, index == _historyItems.length - 1, textColor, subTextColor, timelineLineColor);
                  },
                ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item, bool isLast, Color textColor, Color subTextColor, Color lineColor) {
    final bool isPrescription = item['type'] == 'prescription';
    final DateTime date = item['date_val'];
    final dateStr = DateFormat('MMM dd, yyyy').format(date);
    final dotColor = isPrescription ? AppColors.success : AppColors.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Dot
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: lineColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isPrescription ? 'Prescription Issued' : 'Medical Record Uploaded',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: dotColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(dateStr, style: AppTextStyles.caption.copyWith(color: subTextColor)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPrescription ? (item['diagnosis'] ?? 'General Consultation') : item['title'],
                      style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.bold),
                    ),
                    if (!isPrescription && item['description'] != null) ...[
                      const SizedBox(height: 4),
                      Text(item['description'], style: AppTextStyles.bodySmall.copyWith(color: subTextColor)),
                    ],
                    if (isPrescription) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Medicines: ${item['medicines']}',
                        style: AppTextStyles.bodySmall.copyWith(color: subTextColor, fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppColors.liquidGold),
                        const SizedBox(width: 4),
                        Text(
                          'Trace Status: Stable', // In a real app, this would be computed or fetched
                          style: AppTextStyles.caption.copyWith(color: AppColors.liquidGold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color subTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: subTextColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No history found for this patient',
            style: AppTextStyles.h3.copyWith(color: subTextColor),
          ),
        ],
      ),
    );
  }
}

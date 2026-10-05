import 'package:flutter/material.dart';
import 'package:medicare_plus/core/theme/app_colors.dart';
import 'package:medicare_plus/core/theme/app_text_styles.dart';
import 'package:medicare_plus/core/widgets/glass_card.dart';
import 'package:medicare_plus/core/widgets/app_card.dart';
import 'package:medicare_plus/core/services/doctor_service.dart';

class PatientInsightScreen extends StatefulWidget {
  final int? patientId;
  final String? patientName;

  const PatientInsightScreen({
    super.key,
    this.patientId,
    this.patientName,
  });

  @override
  State<PatientInsightScreen> createState() => _PatientInsightScreenState();
}

class _PatientInsightScreenState extends State<PatientInsightScreen> {
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = true;
  Map<String, dynamic> _patientData = {};

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _loadInsights();
    } else {
      // Demo mode if no ID (though flow should always have ID)
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);
    try {
      final data = await _doctorService.getPatientInsights(widget.patientId!);
      setState(() {
        _patientData = data;
      });
    } catch (e) {
      debugPrint('Error loading insights: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final goldColor = isDark ? AppColors.liquidGold : AppColors.primary;
    final headerBgColor = isDark ? Colors.white.withOpacity(0.05) : AppColors.primary.withOpacity(0.05);

    final name = _patientData['name'] ?? widget.patientName ?? 'Unknown Patient';
    final pid = _patientData['id']?.toString() ?? 'N/A';
    final dob = _patientData['dob'] ?? 'N/A';
    final gender = _patientData['gender'] ?? 'N/A';
    final bloodGroup = _patientData['bloodGroup'] ?? 'N/A';
    final height = _patientData['height'] ?? '--';
    final weight = _patientData['weight'] ?? '--';
    
    final allergies = _patientData['allergies']?.toString() ?? 'None';
    final conditions = _patientData['chronicConditions']?.toString() ?? 'None';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Patient Health Insights', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: goldColor))
        : SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Profile Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: headerBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white12 : AppColors.grey200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: _patientData['profileImage'] != null 
                        ? NetworkImage(_patientData['profileImage']) 
                        : null,
                      child: _patientData['profileImage'] == null 
                        ? Text(name[0], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: goldColor))
                        : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: AppTextStyles.h3.copyWith(color: textColor)),
                          Text('PID: $pid | $gender | DOB: $dob', style: AppTextStyles.bodySmall.copyWith(color: subTextColor)),
                          const SizedBox(height: 4),
                          Text('Blood: $bloodGroup | Ht: $height | Wt: $weight', style: AppTextStyles.caption.copyWith(color: goldColor)),
                        ],
                      ),
                    ),
                    Icon(Icons.verified, color: goldColor),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Text('Health Alerts', style: AppTextStyles.h3.copyWith(color: textColor)),
              const SizedBox(height: 12),
              
              // Allergies & Chronic Conditions
              Row(
                children: [
                  Expanded(child: _buildAlertCard('Allergies', allergies, Icons.warning_amber_rounded, AppColors.error)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAlertCard('Chronic Conditions', conditions, Icons.medical_services_outlined, AppColors.warning)),
                ],
              ),
              
              const SizedBox(height: 32),
              Text('Medical History Timeline', style: AppTextStyles.h3.copyWith(color: textColor)),
              const SizedBox(height: 16),
              
              // Mock timeline for now, as real history logic is complex to merge here without more backend changes
              _buildTimelineItem(
                'Jan 15, 2026', 
                'Viral Fever - Follow up', 
                'Prescribed: Paracetamol, Vitamin C. Patient reported improvement.',
                Icons.medical_services_outlined,
                goldColor, textColor, subTextColor
              ),
              _buildTimelineItem(
                'Dec 22, 2025', 
                'Annual Health Checkup', 
                'All vitals normal. Blood test results: Normal range.',
                Icons.fact_check_outlined,
                goldColor, textColor, subTextColor
              ),
              
              const SizedBox(height: 32),
              Text('Recent Lab Reports', style: AppTextStyles.h3.copyWith(color: textColor)),
              const SizedBox(height: 16),
              
              _buildReportCard('Blood Glucose Report', 'Nov 2025', '110 mg/dL', context, textColor, subTextColor),
              _buildReportCard('Thyroid Profile', 'Oct 2025', 'TSH: 2.1 mIU/L', context, textColor, subTextColor),
            ],
          ),
        ),
    );
  }

  Widget _buildAlertCard(String title, String content, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(content, style: AppTextStyles.caption.copyWith(color: color.withOpacity(0.8)), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String date, String title, String description, IconData icon, Color accentColor, Color textColor, Color subTextColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            Container(width: 2, height: 60, color: accentColor.withOpacity(0.3)),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: AppTextStyles.caption.copyWith(color: accentColor)),
              Text(title, style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: AppTextStyles.bodySmall.copyWith(color: subTextColor)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(String title, String date, String result, BuildContext context, Color textColor, Color subTextColor) {
    return AppCard(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
              Text(date, style: AppTextStyles.caption.copyWith(color: subTextColor)),
            ],
          ),
          Text(result, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

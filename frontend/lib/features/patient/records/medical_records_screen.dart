import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildRecordItem(
            context,
            'Blood Test Report',
            'Feb 05, 2026',
            'City Lab Diagnostics',
            Icons.biotech_outlined,
            Colors.blue,
          ),
          _buildRecordItem(
            context,
            'General Prescription',
            'Jan 20, 2026',
            'Dr. Sarah Johnson',
            Icons.description_outlined,
            Colors.green,
          ),
          _buildRecordItem(
            context,
            'Dental Checkup',
            'Dec 15, 2025',
            'Smile Dental Care',
            Icons.medical_services_outlined,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(BuildContext context, String title, String date, String source, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                Text('$source • $date', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.download_outlined, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

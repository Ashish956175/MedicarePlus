import 'package:flutter/material.dart';
import 'package:medicare_plus/core/theme/app_colors.dart';
import 'package:medicare_plus/core/theme/app_text_styles.dart';
import 'package:medicare_plus/core/widgets/glass_card.dart';
import 'package:medicare_plus/core/widgets/app_card.dart';
import 'package:medicare_plus/core/services/doctor_service.dart';

class DoctorAnalyticsScreen extends StatefulWidget {
  const DoctorAnalyticsScreen({super.key});

  @override
  State<DoctorAnalyticsScreen> createState() => _DoctorAnalyticsScreenState();
}

class _DoctorAnalyticsScreenState extends State<DoctorAnalyticsScreen> {
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _doctorService.getStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      debugPrint('Error loading doctor stats: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final totalEarnings = _stats['totalEarnings'] ?? 0.0;
    final totalReviews = _stats['totalReviews']?.toString() ?? '0';
    final rating = _stats['rating']?.toString() ?? '0.0';
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final goldColor = isDark ? AppColors.liquidGold : AppColors.primary; // Gold pops on dark, Primary looks better on light

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Performance Analytics', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: goldColor),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: goldColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Revenue Overview', style: AppTextStyles.h2.copyWith(color: goldColor)),
              const SizedBox(height: 16),
              
              // Total Earnings Card
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Earnings', style: AppTextStyles.bodyMedium.copyWith(color: subTextColor)),
                        const Icon(Icons.account_balance_wallet_outlined, color: AppColors.success),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('₹$totalEarnings', style: AppTextStyles.h1.copyWith(color: textColor, fontSize: 36)),
                    const SizedBox(height: 8),
                    Text('Based on completed appointments', style: AppTextStyles.caption.copyWith(color: subTextColor)),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Text('Appointment Activity', style: AppTextStyles.h3.copyWith(color: textColor)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard('Completed', _stats['completedAppointments']?.toString() ?? '0', Icons.check_circle_outline, AppColors.success, textColor, subTextColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard('Pending', _stats['pendingAppointments']?.toString() ?? '0', Icons.pending_actions, AppColors.warning, textColor, subTextColor),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              Text('Patient Satisfaction', style: AppTextStyles.h3.copyWith(color: textColor)),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard('Total Reviews', totalReviews, Icons.star, AppColors.warning, textColor, subTextColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard('Avg. Rating', '$rating/5', Icons.favorite, AppColors.error, textColor, subTextColor),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              Text('Recent Feedback', style: AppTextStyles.caption.copyWith(color: subTextColor)),
              const SizedBox(height: 8),
              AppCard(
                color: Theme.of(context).cardColor,
                child: Column(
                  children: [
                    _buildReviewItem('Sarah J.', 'Excellent consultation! Very professional.', 5, textColor, subTextColor),
                    Divider(color: isDark ? Colors.white10 : AppColors.grey200),
                    _buildReviewItem('Mike R.', 'Prompt response and clear instructions.', 4, textColor, subTextColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color, Color textColor, Color subTextColor) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h3.copyWith(color: textColor)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption.copyWith(color: subTextColor)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String comment, int stars, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < stars ? AppColors.warning : AppColors.grey300)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(comment, style: AppTextStyles.bodySmall.copyWith(color: subTextColor)),
        ],
      ),
    );
  }
}

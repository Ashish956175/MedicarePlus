import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileCompletionCard extends StatelessWidget {
  final int completionPercentage;
  final VoidCallback? onCompleteProfile;

  const ProfileCompletionCard({
    super.key,
    required this.completionPercentage,
    this.onCompleteProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (completionPercentage >= 100) {
      return const SizedBox.shrink(); // Hide if profile is complete
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_circle_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Complete Your Profile',
                style: AppTextStyles.h3.copyWith(fontSize: 16, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completionPercentage / 100,
                    backgroundColor: AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$completionPercentage%',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Help us serve you better by completing your profile',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          if (onCompleteProfile != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onCompleteProfile,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Complete Now', style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

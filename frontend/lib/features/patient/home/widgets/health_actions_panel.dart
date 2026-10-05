import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

class HealthActionsPanel extends StatelessWidget {
  final VoidCallback onMyAppointmentsTap;
  final VoidCallback onSavedDoctorsTap;
  final VoidCallback onWellnessWalletTap;
  final VoidCallback onPharmacyTap;
  final VoidCallback onPharmacyOrdersTap;

  const HealthActionsPanel({
    super.key,
    required this.onMyAppointmentsTap,
    required this.onSavedDoctorsTap,
    required this.onWellnessWalletTap,
    required this.onPharmacyTap,
    required this.onPharmacyOrdersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.calendar_today_rounded,
                label: 'Appointments',
                color: AppColors.primary,
                onTap: onMyAppointmentsTap,
                isHighlighted: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.favorite_rounded,
                label: 'Saved',
                color: AppColors.error,
                onTap: onSavedDoctorsTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.account_balance_wallet_rounded,
                label: 'Wallet',
                color: AppColors.liquidGold,
                onTap: onWellnessWalletTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.medical_services_rounded,
                label: 'Pharmacy',
                color: AppColors.success,
                onTap: onPharmacyTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context: context,
                icon: Icons.history_rounded,
                label: 'My Orders',
                color: AppColors.primary,
                onTap: onPharmacyOrdersTap,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()), // Placeholder for balance
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      color: isHighlighted ? AppColors.primary.withOpacity(0.1) : Theme.of(context).cardColor,
      borderRadius: 20,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

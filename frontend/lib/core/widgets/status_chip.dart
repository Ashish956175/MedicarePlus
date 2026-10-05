import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum Status { booked, cancelled, pending, completed }

class StatusChip extends StatelessWidget {
  final Status status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;
    String label;

    switch (status) {
      case Status.booked:
        color = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        label = 'BOOKED';
        break;
      case Status.cancelled:
        color = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        label = 'CANCELLED';
        break;
      case Status.pending:
        color = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        label = 'PENDING';
        break;
      case Status.completed:
        color = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        label = 'COMPLETED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

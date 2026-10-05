import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double size;
  final bool showValue;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.reviewCount,
    this.size = 16,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, color: AppColors.warning, size: size);
          } else if (index < rating) {
            return Icon(Icons.star_half, color: AppColors.warning, size: size);
          } else {
            return Icon(Icons.star_border, color: AppColors.grey300, size: size);
          }
        }),
        if (showValue) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
        if (reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

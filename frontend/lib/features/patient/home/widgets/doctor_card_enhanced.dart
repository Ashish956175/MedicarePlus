import 'package:flutter/material.dart';
import '../../../../core/models/doctor_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/services/saved_doctors_service.dart';

import '../../../../core/constants/api_constants.dart';

class DoctorCardEnhanced extends StatefulWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  final bool isAvailableToday;
  final Function(bool isSaved)? onSaveStatusChanged;

  const DoctorCardEnhanced({
    super.key,
    required this.doctor,
    required this.onTap,
    this.isAvailableToday = false,
    this.onSaveStatusChanged,
  });

  @override
  State<DoctorCardEnhanced> createState() => _DoctorCardEnhancedState();
}

class _DoctorCardEnhancedState extends State<DoctorCardEnhanced> {
  final SavedDoctorsService _savedService = SavedDoctorsService();
  bool _isSaved = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    final saved = await _savedService.isDoctorSaved(widget.doctor.id);
    if (mounted) {
      setState(() {
        _isSaved = saved;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSaved() async {
    await _savedService.toggleSavedDoctor(widget.doctor.id);
    if (mounted) {
      setState(() {
        _isSaved = !_isSaved;
      });
      widget.onSaveStatusChanged?.call(_isSaved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: widget.onTap,
      padding: const EdgeInsets.all(14),
      borderRadius: 24,
      child: Row(
        children: [
          // Doctor Image with Availability Indicator
          Hero(
            tag: 'doctor_avatar_${widget.doctor.id}',
            child: Stack(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).brightness == Brightness.light ? AppColors.grey50 : Colors.white.withOpacity(0.05),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      image: widget.doctor.image.startsWith('http')
                          ? NetworkImage(widget.doctor.image)
                          : AssetImage(widget.doctor.image) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (widget.isAvailableToday)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.doctor.name,
                        style: AppTextStyles.h3.copyWith(fontSize: 17),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.isAvailableToday)
                       const Padding(
                         padding: EdgeInsets.only(left: 4),
                         child: Icon(Icons.verified, color: AppColors.primary, size: 18),
                       ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.doctor.specialization,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      widget.doctor.rating.toStringAsFixed(1),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '(${widget.doctor.id * 10}+ reviews)',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textHint),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Fee & Experience Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${widget.doctor.fee.toStringAsFixed(0)}',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${widget.doctor.experience} yrs',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Save/Bookmark Icon
          if (!_isLoading)
            Column(
              children: [
                IconButton(
                  onPressed: _toggleSaved,
                  icon: Icon(
                    _isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isSaved ? AppColors.error : AppColors.grey300,
                    size: 26,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 24,
                ),
                const SizedBox(height: 12),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.grey300),
              ],
            ),
        ],
      ),
    );
  }
}

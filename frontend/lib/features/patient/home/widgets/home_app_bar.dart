import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../../core/widgets/user_profile_menu.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;
  final String? profileImage;
  final String? role;

  const HomeAppBar({
    super.key,
    required this.userName,
    this.profileImage,
    this.role,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting,',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: AppTextStyles.h2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        UserProfileMenu(
          userName: userName,
          profileImage: profileImage,
          role: role,
        ),
      ],
    );
  }
}

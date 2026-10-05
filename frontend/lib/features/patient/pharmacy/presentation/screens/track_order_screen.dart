import 'package:flutter/material.dart';
import 'package:medicare_plus/core/theme/app_colors.dart';
import 'package:medicare_plus/core/theme/app_text_styles.dart';
import 'package:medicare_plus/core/widgets/glass_card.dart';
import 'package:intl/intl.dart';
import 'package:medicare_plus/core/widgets/entrance_animation.dart';

class TrackOrderScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const TrackOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = order['status'] ?? 'PENDING';
    final date = DateTime.parse(order['orderDate']);
    final formattedDate = DateFormat('MMM dd, yyyy • hh:mm a').format(date);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Track Order #${order['id']}', 
          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: EntranceAnimation(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfo(context, formattedDate),
              const SizedBox(height: 32),
              Text('Order Status', 
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.liquidGold : AppColors.primary
                )
              ),
              const SizedBox(height: 24),
              _buildStatusTimeline(context, status),
              const SizedBox(height: 40),
              _buildDeliveryDetails(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfo(BuildContext context, String date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.liquidGold : AppColors.primary).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined, 
              color: isDark ? AppColors.liquidGold : AppColors.primary
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Placed on', 
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? Colors.white54 : AppColors.textSecondary
                )
              ),
              Text(date, 
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary, 
                  fontWeight: FontWeight.bold
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context, String currentStatus) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.liquidGold : AppColors.primary;

    final statuses = [
      {'title': 'Order Placed', 'subtitle': 'We have received your order', 'key': 'PENDING'},
      {'title': 'Confirmed', 'subtitle': 'Pharmacist is preparing your order', 'key': 'CONFIRMED'},
      {'title': 'Shipped', 'subtitle': 'Your order is on the way', 'key': 'SHIPPED'},
      {'title': 'Delivered', 'subtitle': 'Order reached your destination', 'key': 'DELIVERED'},
    ];

    int currentIndex = statuses.indexWhere((s) => s['key'] == currentStatus);
    if (currentIndex == -1) {
      if (currentStatus == 'CANCELLED') currentIndex = -2;
      else currentIndex = 0;
    }

    return Column(
      children: List.generate(statuses.length, (index) {
        final bool isCompleted = index <= currentIndex;
        final bool isLast = index == statuses.length - 1;
        final status = statuses[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted ? accentColor : (isDark ? Colors.white10 : AppColors.grey200),
                    shape: BoxShape.circle,
                    boxShadow: isCompleted ? [
                      BoxShadow(
                        color: accentColor.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ] : [],
                    border: Border.all(
                      color: isCompleted ? accentColor.withOpacity(0.3) : (isDark ? Colors.white24 : AppColors.grey300),
                      width: 4,
                    ),
                  ),
                  child: isCompleted 
                    ? Icon(Icons.check, size: 10, color: isDark ? AppColors.royalNoir : Colors.white)
                    : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: isCompleted ? accentColor.withOpacity(0.5) : (isDark ? Colors.white10 : AppColors.grey200),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status['title']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isCompleted 
                        ? (isDark ? Colors.white : AppColors.textPrimary) 
                        : (isDark ? Colors.white38 : AppColors.textHint),
                      fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    status['subtitle']!,
                    style: AppTextStyles.caption.copyWith(
                      color: isCompleted 
                        ? (isDark ? Colors.white70 : AppColors.textSecondary) 
                        : (isDark ? Colors.white24 : AppColors.textHint.withOpacity(0.5)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDeliveryDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.liquidGold : AppColors.primary;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Text('Delivery Address', 
                style: AppTextStyles.bodyMedium.copyWith(
                  color: accentColor, 
                  fontWeight: FontWeight.bold
                )
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order['deliveryAddress'] ?? 'No address provided',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? Colors.white70 : AppColors.textSecondary
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.phone_outlined, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text('Contact', 
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success, 
                  fontWeight: FontWeight.bold
                )
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order['contactNumber'] ?? 'No contact provided',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? Colors.white70 : AppColors.textSecondary
            ),
          ),
        ],
      ),
    );
  }
}

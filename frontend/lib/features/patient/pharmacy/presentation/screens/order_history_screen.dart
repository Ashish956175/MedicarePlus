import 'package:flutter/material.dart';
import 'package:medicare_plus/core/theme/app_colors.dart';
import 'package:medicare_plus/core/theme/app_text_styles.dart';
import 'package:medicare_plus/core/widgets/glass_card.dart';
import 'package:medicare_plus/core/services/pharmacy_service.dart';
import 'package:intl/intl.dart';
import 'package:medicare_plus/features/patient/pharmacy/presentation/screens/track_order_screen.dart';
import 'package:medicare_plus/core/widgets/entrance_animation.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  bool _isLoading = true;
  List<dynamic> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _pharmacyService.getMyOrders();
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'My Orders',
          style: AppTextStyles.h2.copyWith(
            fontSize: 20,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.liquidGold : AppColors.primary,
              ),
            )
          : _orders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  color: AppColors.primary,
                  child: EntranceAnimation(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        return _buildOrderCard(_orders[index]);
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final date = DateTime.parse(order['orderDate']);
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final status = order['status'] ?? 'PENDING';
    final itemsCount = (order['items'] as List).length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order['id']}', 
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary, 
                    fontWeight: FontWeight.bold
                  )
                ),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 12),
            Text('$itemsCount items • Total: ₹${order['totalAmount']}', 
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? Colors.white70 : AppColors.textSecondary
              )
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: isDark ? AppColors.liquidGold.withOpacity(0.5) : AppColors.primary.withOpacity(0.5)),
                const SizedBox(width: 6),
                Text(formattedDate, 
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? Colors.white54 : AppColors.textHint
                  )
                ),
              ],
            ),
            Divider(
              color: isDark ? Colors.white10 : AppColors.grey200, 
              height: 24
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment: ${order['paymentStatus']}', 
                  style: AppTextStyles.caption.copyWith(
                    color: order['paymentStatus'] == 'PAID' ? AppColors.success : AppColors.warning
                  )
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrackOrderScreen(order: order),
                      ),
                    );
                  },
                  child: Text('TRACK ORDER', 
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.liquidGold : AppColors.primary, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'DELIVERED': color = AppColors.success; break;
      case 'SHIPPED': color = AppColors.primary; break;
      case 'CANCELLED': color = AppColors.error; break;
      default: color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, 
            size: 80, 
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.grey300
          ),
          const SizedBox(height: 16),
          Text('No orders found', 
            style: AppTextStyles.h3.copyWith(
              color: isDark ? Colors.white60 : AppColors.textSecondary
            )
          ),
          const SizedBox(height: 8),
          Text('Your medicine orders will appear here', 
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? Colors.white30 : AppColors.textHint
            )
          ),
        ],
      ),
    );
  }
}

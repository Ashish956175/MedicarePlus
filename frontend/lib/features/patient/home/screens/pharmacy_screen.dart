import 'package:flutter/material.dart';
import 'package:medicare_plus/core/theme/app_colors.dart';
import 'package:medicare_plus/core/theme/app_text_styles.dart';
import 'package:medicare_plus/core/widgets/glass_card.dart';
import 'package:medicare_plus/core/widgets/glass_button.dart';
import 'dart:convert';
import 'package:medicare_plus/features/patient/pharmacy/presentation/screens/checkout_screen.dart';
import 'package:medicare_plus/core/widgets/entrance_animation.dart';
import 'package:medicare_plus/core/theme/page_transitions.dart';

class PharmacyScreen extends StatefulWidget {
  final Map<String, dynamic>? initialPrescription;
  const PharmacyScreen({super.key, this.initialPrescription});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final List<Map<String, dynamic>> _pharmacyStock = [
    {'name': 'Paracetamol 500mg', 'price': 45.0, 'category': 'General'},
    {'name': 'Amoxicillin 250mg', 'price': 120.0, 'category': 'Antibiotic'},
    {'name': 'Cetrizine 10mg', 'price': 30.0, 'category': 'Anti-allergic'},
    {'name': 'Omeprazole 20mg', 'price': 85.0, 'category': 'Gastric'},
    {'name': 'Multivitamin', 'price': 250.0, 'category': 'Supplement'},
  ];

  Map<String, int> _cart = {}; // name: quantity

  @override
  void initState() {
    super.initState();
    if (widget.initialPrescription != null) {
      _autoPopulateFromPrescription();
    }
  }

  void _autoPopulateFromPrescription() {
    try {
      final List<dynamic> medicines = jsonDecode(widget.initialPrescription!['medicines']);
      for (var med in medicines) {
        final medName = med['name'].toString().split('-')[0].trim();
        // Check if we have this in stock (basic match)
        for (var stockMed in _pharmacyStock) {
          if (stockMed['name'].toLowerCase().contains(medName.toLowerCase())) {
            _addToCart(stockMed['name']);
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error auto-populating cart: $e');
    }
  }

  void _addToCart(String name) {
    setState(() {
      _cart[name] = (_cart[name] ?? 0) + 1;
    });
  }

  void _removeFromCart(String name) {
    setState(() {
      if (_cart.containsKey(name)) {
        if (_cart[name]! > 1) {
          _cart[name] = _cart[name]! - 1;
        } else {
          _cart.remove(name);
        }
      }
    });
  }

  double _calculateTotal() {
    double total = 0;
    _cart.forEach((name, qty) {
      final item = _pharmacyStock.firstWhere((element) => element['name'] == name);
      total += (item['price'] * qty);
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('MediCare Pharmacy', 
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
              if (widget.initialPrescription != null) _buildPrescriptionBanner(),
              const SizedBox(height: 24),
              Text('Available Medicines', 
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.liquidGold : AppColors.primary
                )
              ),
              const SizedBox(height: 16),
              ..._pharmacyStock.map((item) => _buildStockItem(item)).toList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCheckoutBar(),
    );
  }

  Widget _buildPrescriptionBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.verified_user, color: AppColors.success, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prescription Found', 
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary, 
                    fontWeight: FontWeight.bold
                  )
                ),
                Text('Order medicines from your latest consultation.', 
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textSecondary
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockItem(Map<String, dynamic> item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qty = _cart[item['name']] ?? 0;
    return GlassCard(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.liquidGold : AppColors.primary).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.medical_services, color: isDark ? AppColors.liquidGold : AppColors.primary),
        ),
        title: Text(item['name'], 
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary, 
            fontWeight: FontWeight.bold
          )
        ),
        subtitle: Text(item['category'], 
          style: AppTextStyles.caption.copyWith(
            color: isDark ? Colors.white54 : AppColors.textSecondary
          )
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('₹${item['price']}', 
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.liquidGold : AppColors.primary, 
                fontWeight: FontWeight.bold
              )
            ),
            const SizedBox(height: 4),
            qty == 0
                ? GestureDetector(
                    onTap: () => _addToCart(item['name']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.liquidGold : AppColors.primary).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: (isDark ? AppColors.liquidGold : AppColors.primary).withOpacity(0.3)),
                      ),
                      child: Text('ADD', 
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.liquidGold : AppColors.primary, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    ),
                   )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildQtyBtn(Icons.remove, () => _removeFromCart(item['name'])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('$qty', 
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textPrimary, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                      _buildQtyBtn(Icons.add, () => _addToCart(item['name'])),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.liquidGold : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _buildCheckoutBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = _calculateTotal();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount', 
                  style: AppTextStyles.caption.copyWith(
                    color: isDark ? Colors.white60 : AppColors.textSecondary
                  )
                ),
                Text('₹${total.toStringAsFixed(2)}', 
                  style: AppTextStyles.h2.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary
                  )
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: GlassButton(
                text: 'CHECKOUT',
                onPressed: total > 0 ? () {
                  final List<Map<String, dynamic>> cartItems = [];
                  _cart.forEach((name, qty) {
                    final stockItem = _pharmacyStock.firstWhere((element) => element['name'] == name);
                    cartItems.add({
                      'medicineName': name,
                      'quantity': qty,
                      'price': stockItem['price'],
                    });
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(
                        items: cartItems,
                        totalAmount: total,
                      ),
                    ),
                  );
                } : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

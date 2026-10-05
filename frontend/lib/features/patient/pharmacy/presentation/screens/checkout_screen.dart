import 'package:flutter/material.dart';
import 'package:medicare_plus/core/theme/app_colors.dart';
import 'package:medicare_plus/core/theme/app_text_styles.dart';
import 'package:medicare_plus/core/widgets/glass_card.dart';
import 'package:medicare_plus/core/widgets/glass_button.dart';
import 'package:medicare_plus/core/services/payment_service.dart';
import 'package:medicare_plus/core/services/pharmacy_service.dart';
import 'package:medicare_plus/core/services/auth_service.dart';
import 'package:medicare_plus/features/patient/pharmacy/presentation/screens/order_history_screen.dart';
import 'package:medicare_plus/core/widgets/entrance_animation.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PaymentService _paymentService = PaymentService();
  final PharmacyService _pharmacyService = PharmacyService();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _paymentService.onSuccess = _handlePaymentSuccess;
    _paymentService.onFailure = _handlePaymentFailure;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final phone = await AuthService().getEmail(); // Using email as placeholder for contact
    final name = await AuthService().getName();
    setState(() {
      _phoneController.text = ""; // Should be fetched from profile in real app
    });
  }

  void _handlePaymentSuccess(MediCarePaymentSuccess success) async {
    try {
      final order = await _pharmacyService.placeOrder(
        totalAmount: widget.totalAmount,
        items: widget.items,
        address: _addressController.text,
        contactNumber: _phoneController.text,
        paymentStatus: 'PAID',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        );
      }
    } catch (e) {
      _showError('Failed to save order after payment. Please contact support.');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _handlePaymentFailure(MediCarePaymentFailure failure) {
    setState(() => _isProcessing = false);
    _showError('Payment failed: ${failure.message}');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _startPayment() async {
    if (_addressController.text.isEmpty || _phoneController.text.isEmpty) {
      _showError('Please fill in all details');
      return;
    }

    setState(() => _isProcessing = true);
    
    final name = await AuthService().getName() ?? 'User';
    final email = await AuthService().getEmail() ?? '';

    _paymentService.openCheckout(
      amount: widget.totalAmount,
      name: 'Pharmacy Order',
      description: 'Medicines Order from MediCarePlus',
      email: email,
      contact: _phoneController.text,
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Checkout', 
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
              _buildOrderSummary(),
              const SizedBox(height: 32),
              Text('Delivery Details', 
                style: AppTextStyles.h3.copyWith(
                  color: isDark ? AppColors.liquidGold : AppColors.primary
                )
              ),
              const SizedBox(height: 16),
              _buildTextField('Shipping Address', _addressController, Icons.location_on, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField('Contact Number', _phoneController, Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 40),
              if (_isProcessing)
                Center(child: CircularProgressIndicator(color: isDark ? AppColors.liquidGold : AppColors.primary))
              else
                GlassButton(
                  text: 'PAY ₹${widget.totalAmount.toStringAsFixed(2)}',
                  onPressed: _startPayment,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary', 
            style: AppTextStyles.h3.copyWith(
              color: isDark ? Colors.white : AppColors.textPrimary
            )
          ),
          Divider(color: isDark ? Colors.white10 : AppColors.grey200, height: 24),
          ...widget.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${item['medicineName']} x${item['quantity']}', 
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textSecondary
                  )
                ),
                Text('₹${(item['price'] * item['quantity']).toStringAsFixed(2)}', 
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? Colors.white : AppColors.textPrimary
                  )
                ),
              ],
            ),
          )),
          Divider(color: isDark ? Colors.white10 : AppColors.grey200, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', 
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary, 
                  fontWeight: FontWeight.bold
                )
              ),
              Text('₹${widget.totalAmount.toStringAsFixed(2)}', 
                style: AppTextStyles.h2.copyWith(
                  color: isDark ? AppColors.liquidGold : AppColors.primary
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.liquidGold : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: accentColor.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: accentColor),
          filled: true,
          fillColor: accentColor.withOpacity(0.05),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accentColor.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: accentColor),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

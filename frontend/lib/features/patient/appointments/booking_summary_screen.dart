import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/models/doctor_model.dart';
import '../home/user_dashboard.dart'; // For navigation back home
import 'widgets/success_animation.dart';
import '../../../core/services/appointment_service.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/services/auth_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BookingSummaryScreen extends StatefulWidget {
  final Doctor doctor;
  final DateTime date;
  final String time;

  const BookingSummaryScreen({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  bool _isConfirming = false;
  bool _isSuccess = false;
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService();
    _paymentService.onSuccess = _handlePaymentSuccess;
    _paymentService.onFailure = _handlePaymentFailure;
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(MediCarePaymentSuccess response) {
    // Transaction successful, now book with backend
    _finalizeBooking();
  }

  void _handlePaymentFailure(MediCarePaymentFailure response) {
    setState(() => _isConfirming = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _confirmBooking() async {
    setState(() => _isConfirming = true);

    // Get user details for prefill
    final email = await AuthService().getEmail();

    _paymentService.openCheckout(
      amount: widget.doctor.fee,
      name: widget.doctor.name,
      description: 'Consultation with ${widget.doctor.name}',
      email: email ?? '',
      contact: '9999999999', // Mock contact
    );
  }

  Future<void> _finalizeBooking() async {
    try {
      final dateStr = widget.date.toIso8601String().split('T')[0];
      final success = await AppointmentService().bookAppointment(widget.doctor.id, dateStr, widget.time);

      if (!mounted) return;

      if (success) {
        setState(() => _isSuccess = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to confirm booking. Please try again.')),
        );
        setState(() => _isConfirming = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isConfirming = false);
    }
  }

  void _onAnimationComplete() {
    // Navigate to Home or Appointments tab
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => UserDashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SuccessAnimation(onAnimationComplete: _onAnimationComplete),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Review Application'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Step Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStep(1, 'Select', true),
                _buildConnector(true),
                _buildStep(2, 'Review', true),
                _buildConnector(false),
                _buildStep(3, 'Done', false),
              ],
            ),
            const SizedBox(height: 32),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: widget.doctor.image.startsWith('http')
                            ? NetworkImage(widget.doctor.image)
                            : AssetImage(widget.doctor.image) as ImageProvider,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.doctor.name, style: AppTextStyles.h3),
                          Text(widget.doctor.specialization, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildSummaryRow(Icons.calendar_today, 'Date', '${widget.date.year}-${widget.date.month}-${widget.date.day}'), // Simple format
                  const SizedBox(height: 16),
                  _buildSummaryRow(Icons.access_time_rounded, 'Time', widget.time),
                  const SizedBox(height: 16),
                  _buildSummaryRow(Icons.currency_rupee_rounded, 'Consultation Fee', '₹${widget.doctor.fee.toStringAsFixed(0)}'),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Confirm Button
            PrimaryButton(
              text: _isConfirming ? 'Waiting for Payment...' : 'Pay & Confirm (₹${widget.doctor.fee.toStringAsFixed(0)})',
              onPressed: _isConfirming ? () {} : _confirmBooking,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.grey300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal
        )),
      ],
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 15), // align with circle center roughly
      color: isActive ? AppColors.primary : AppColors.grey300,
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Text(value, style: AppTextStyles.h3),
      ],
    );
  }
}

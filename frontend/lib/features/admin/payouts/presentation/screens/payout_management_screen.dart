import 'package:flutter/material.dart';
import 'package:medicare_plus/core/theme/app_colors.dart';
import 'package:medicare_plus/core/theme/app_text_styles.dart';
import 'package:medicare_plus/core/widgets/glass_card.dart';
import 'package:medicare_plus/core/services/admin_service.dart';
import 'package:medicare_plus/core/widgets/entrance_animation.dart';
import 'package:intl/intl.dart';

class PayoutManagementScreen extends StatefulWidget {
  const PayoutManagementScreen({super.key});

  @override
  State<PayoutManagementScreen> createState() => _PayoutManagementScreenState();
}

class _PayoutManagementScreenState extends State<PayoutManagementScreen> with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late TabController _tabController;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingPayouts = [];
  List<Map<String, dynamic>> _payoutHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final pending = await _adminService.getPendingPayouts();
      final history = await _adminService.getPayoutHistory();
      if (mounted) {
        setState(() {
          _pendingPayouts = pending;
          _payoutHistory = history;
        });
      }
    } catch (e) {
      debugPrint('Error loading payouts: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showProcessDialog(Map<String, dynamic> payout) {
    showDialog(
      context: context,
      builder: (context) => ProcessPayoutDialog(
        payout: payout,
        onProcessed: _loadData,
      ),
    );
  }

  void _showBreakdown(Map<String, dynamic> payout) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allow taller modal
      builder: (context) => PayoutBreakdownModal(
        doctorId: payout['doctorId'],
        doctorName: payout['doctorName'] ?? 'Unknown Doctor',
        totalAmount: (payout['amount'] as num).toDouble(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white54 : AppColors.textSecondary;
    final goldColor = isDark ? AppColors.liquidGold : AppColors.primary;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Payout Management', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        bottom: TabBar(
          controller: _tabController,
          labelColor: goldColor,
          unselectedLabelColor: subTextColor,
          indicatorColor: goldColor,
          tabs: const [
            Tab(text: 'Pending Settlements'),
            Tab(text: 'Payment History'),
          ],
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: goldColor))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildPendingList(textColor, subTextColor, goldColor),
              _buildHistoryList(textColor, subTextColor, goldColor),
            ],
          ),
    );
  }

  Widget _buildPendingList(Color textColor, Color subTextColor, Color accentColor) {
    if (_pendingPayouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: subTextColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No pending payouts', style: AppTextStyles.h3.copyWith(color: subTextColor)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: accentColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _pendingPayouts.length,
        itemBuilder: (context, index) {
          return EntranceAnimation(
            delay: Duration(milliseconds: 50 * index),
            child: _buildPendingCard(_pendingPayouts[index], textColor, subTextColor, accentColor),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList(Color textColor, Color subTextColor, Color accentColor) {
    if (_payoutHistory.isEmpty) {
      return Center(
        child: Text('No payment history found', style: AppTextStyles.bodyMedium.copyWith(color: subTextColor)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: accentColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _payoutHistory.length,
        itemBuilder: (context, index) {
          return EntranceAnimation(
            delay: Duration(milliseconds: 50 * index),
            child: _buildHistoryCard(_payoutHistory[index], textColor, subTextColor, accentColor),
          );
        },
      ),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> payout, Color textColor, Color subTextColor, Color accentColor) {
    final doctorName = payout['doctorName'] ?? 'Unknown Doctor';
    final amount = (payout['amount'] as num).toDouble();
    final count = payout['appointmentCount'] ?? 0;
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.2)),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctorName, style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.bold)),
                      Text('$count Appointments', style: AppTextStyles.caption.copyWith(color: subTextColor)),
                    ],
                  ),
                ),
                Text('₹${amount.toStringAsFixed(2)}', style: AppTextStyles.h3.copyWith(color: textColor)),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? Colors.white10 : AppColors.grey200),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (payout['bankAccount'] != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bank: ${payout['bankAccount']}', style: AppTextStyles.caption.copyWith(color: subTextColor, fontSize: 10)),
                        Text('IFSC: ${payout['ifsc']}', style: AppTextStyles.caption.copyWith(color: subTextColor, fontSize: 10)),
                      ],
                    ),
                  )
                else
                  Text('No Bank Info', style: AppTextStyles.caption.copyWith(color: AppColors.error, fontSize: 11)),
                
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _showBreakdown(payout),
                      child: Text('Breakdown', style: TextStyle(color: subTextColor, fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showProcessDialog(payout),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      child: const Text('PAY NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> payout, Color textColor, Color subTextColor, Color accentColor) {
    final amount = (payout['amount'] as num).toDouble();
    final method = payout['paymentMethod'] ?? 'Unknown';
    final ref = payout['transactionReference'] ?? 'N/A';
    final date = payout['processedAt'] != null 
        ? DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(payout['processedAt']))
        : 'N/A';
    final cardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.grey200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: AppColors.success, size: 20),
        ),
        title: Text('Paid ₹${amount.toStringAsFixed(2)}', style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Via $method • Ref: $ref', style: AppTextStyles.caption.copyWith(color: subTextColor)),
            Text(date, style: AppTextStyles.caption.copyWith(color: subTextColor, fontSize: 10)),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: subTextColor),
      ),
    );
  }
}

class ProcessPayoutDialog extends StatefulWidget {
  final Map<String, dynamic> payout;
  final VoidCallback onProcessed;

  const ProcessPayoutDialog({super.key, required this.payout, required this.onProcessed});

  @override
  State<ProcessPayoutDialog> createState() => _ProcessPayoutDialogState();
}

class _ProcessPayoutDialogState extends State<ProcessPayoutDialog> {
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  final AdminService _adminService = AdminService();
  String _selectedMethod = 'BANK_TRANSFER';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final amount = widget.payout['amount'];
    
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Process Payout', style: AppTextStyles.h3.copyWith(color: textColor)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount to Pay', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            Text('₹$amount', style: AppTextStyles.h2.copyWith(color: AppColors.liquidGold)),
            const SizedBox(height: 20),
            
            Text('Payment Method', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              dropdownColor: Theme.of(context).cardColor,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: ['BANK_TRANSFER', 'UPI', 'CASH', 'CHEQUE'].map((m) => 
                DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (v) => setState(() => _selectedMethod = v!),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _referenceController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Transaction Reference / UTR',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _notesController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isProcessing 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Confirm Payment'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (_referenceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter transaction reference')));
      return;
    }

    setState(() => _isProcessing = true);
    final success = await _adminService.processPayout(
      widget.payout['doctorId'], 
      (widget.payout['amount'] as num).toDouble(),
      method: _selectedMethod,
      reference: _referenceController.text,
      notes: _notesController.text,
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      if (success) {
        Navigator.pop(context);
        widget.onProcessed();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payout processed successfully!'), backgroundColor: AppColors.success));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to process payout'), backgroundColor: AppColors.error));
      }
    }
  }
}

class PayoutBreakdownModal extends StatefulWidget {
  final int doctorId;
  final String doctorName;
  final double totalAmount;

  const PayoutBreakdownModal({
    super.key, 
    required this.doctorId, 
    required this.doctorName, 
    required this.totalAmount
  });

  @override
  State<PayoutBreakdownModal> createState() => _PayoutBreakdownModalState();
}

class _PayoutBreakdownModalState extends State<PayoutBreakdownModal> {
  final AdminService _adminService = AdminService();
  bool _isLoading = true;
  List<dynamic> _appointments = []; // Using dynamic to handle potential model mismatches safely

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details = await _adminService.getPendingPayoutDetails(widget.doctorId);
      if (mounted) {
        setState(() {
          _appointments = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading breakdown: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white54 : AppColors.textSecondary;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payout Breakdown', style: AppTextStyles.h3.copyWith(color: textColor)),
                  Text(widget.doctorName, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ],
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close, color: subTextColor)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.liquidGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.liquidGold.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Settlement', style: TextStyle(color: textColor)),
                Text('₹${widget.totalAmount}', style: AppTextStyles.h3.copyWith(color: AppColors.liquidGold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Included Appointments', style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _appointments.isEmpty
                ? Center(child: Text('No details found', style: TextStyle(color: subTextColor)))
                : ListView.builder(
                    itemCount: _appointments.length,
                    itemBuilder: (context, index) {
                      final appt = _appointments[index];
                      // Handle both Appointment model or raw JSON if updated
                      final date = appt.date;
                      final time = appt.timeSlot;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 16, color: subTextColor),
                            const SizedBox(width: 8),
                            Text('$date  •  $time', style: TextStyle(color: textColor, fontSize: 13)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

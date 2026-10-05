import 'package:flutter/material.dart';
import 'package:medicare_plus/core/theme/app_colors.dart';
import 'package:medicare_plus/core/theme/app_text_styles.dart';
import 'package:medicare_plus/core/widgets/glass_card.dart';
import 'package:medicare_plus/core/widgets/glass_button.dart';
import 'package:medicare_plus/core/widgets/glass_container.dart';

class CreateReferralScreen extends StatefulWidget {
  const CreateReferralScreen({super.key});

  @override
  State<CreateReferralScreen> createState() => _CreateReferralScreenState();
}

class _CreateReferralScreenState extends State<CreateReferralScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedTestType;
  final _notesController = TextEditingController();
  final _patientIdController = TextEditingController();
  bool _isLoading = false;

  final List<String> _testTypes = [
    'Complete Blood Count (CBC)',
    'Blood Glucose Test',
    'Liver Function Test',
    'Lipid Profile',
    'X-Ray Chest',
    'MRI Scan',
    'CT Scan',
    'ECG',
    'Urinalysis'
  ];

  void _submitReferral() async {
    if (!_formKey.currentState!.validate() || _selectedTestType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referral issued successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white60 : AppColors.textSecondary;
    final goldColor = isDark ? AppColors.liquidGold : AppColors.primary;
    final hintColor = isDark ? Colors.white.withOpacity(0.5) : AppColors.textHint;
    final inputFillColor = isDark ? Colors.white.withOpacity(0.1) : AppColors.grey100;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('New Lab Referral', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Issue Digital Referral', style: AppTextStyles.h2.copyWith(color: goldColor)),
              const SizedBox(height: 8),
              Text('Issued referrals will appear in patient\'s Wellness Wallet', 
                style: AppTextStyles.bodySmall.copyWith(color: subTextColor)),
              const SizedBox(height: 32),
              
              Text('Patient Details', style: AppTextStyles.h3.copyWith(color: textColor)),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _patientIdController,
                hint: 'Enter Patient ID or Name',
                icon: Icons.person_search_outlined,
                textColor: textColor,
                hintColor: hintColor,
                fillColor: inputFillColor,
                iconColor: goldColor,
              ),
              
              const SizedBox(height: 32),
              Text('Select Diagnostic Test', style: AppTextStyles.h3.copyWith(color: textColor)),
              const SizedBox(height: 12),
              _buildDropdown(textColor, hintColor, inputFillColor, goldColor, isDark),
              
              const SizedBox(height: 32),
              Text('Clinical Notes', style: AppTextStyles.h3.copyWith(color: textColor)),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _notesController,
                hint: 'Reason for referral or special instructions...',
                icon: Icons.note_alt_outlined,
                maxLines: 4,
                textColor: textColor,
                hintColor: hintColor,
                fillColor: inputFillColor,
                iconColor: goldColor,
              ),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  text: 'Issue & Send Referral',
                  icon: Icons.send_rounded,
                  color: goldColor,
                  isLoading: _isLoading,
                  onPressed: _submitReferral,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color textColor,
    required Color hintColor,
    required Color fillColor,
    required Color iconColor,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        cursorColor: iconColor,
        decoration: InputDecoration(
          icon: Icon(icon, color: iconColor),
          hintText: hint,
          hintStyle: TextStyle(color: hintColor),
          border: InputBorder.none,
        ),
        validator: (val) => val!.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildDropdown(Color textColor, Color hintColor, Color fillColor, Color iconColor, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTestType,
          hint: Text('Select Test Type', style: TextStyle(color: hintColor)),
          isExpanded: true,
          dropdownColor: isDark ? AppColors.royalNoir : Colors.white,
          icon: Icon(Icons.keyboard_arrow_down, color: iconColor),
          items: _testTypes.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: textColor, fontSize: 16)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedTestType = newValue;
            });
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/services/prescription_service.dart';

class PrescriptionBuilderScreen extends StatefulWidget {
  final int appointmentId;
  final int patientId;

  const PrescriptionBuilderScreen({
    super.key,
    required this.appointmentId,
    required this.patientId,
  });

  @override
  State<PrescriptionBuilderScreen> createState() => _PrescriptionBuilderScreenState();
}

class _PrescriptionBuilderScreenState extends State<PrescriptionBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _adviceController = TextEditingController();
  final _privateNotesController = TextEditingController();
  final List<Map<String, String>> _medicines = [
    {'name': '', 'dosage': ''}
  ];
  bool _isLoading = false;
  bool _showPrivateNotes = false;

  void _addMedicine() {
    setState(() {
      _medicines.add({'name': '', 'dosage': ''});
    });
  }

  void _removeMedicine(int index) {
    if (_medicines.length > 1) {
      setState(() {
        _medicines.removeAt(index);
      });
    }
  }

  Future<void> _submitPrescription() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await PrescriptionService().createPrescription(
        appointmentId: widget.appointmentId,
        patientId: widget.patientId,
        diagnosis: _diagnosisController.text,
        medicines: _medicines,
        advice: _adviceController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription saved successfully'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final accentColor = isDark ? AppColors.liquidGold : AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.royalNoir : AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('New Prescription', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Diagnosis', style: AppTextStyles.h3.copyWith(color: accentColor)),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _diagnosisController,
                hint: 'Enter diagnosis details...',
                maxLines: 2,
                isDark: isDark,
              ),
              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Medications', style: AppTextStyles.h3.copyWith(color: accentColor)),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.success),
                    onPressed: _addMedicine,
                    tooltip: 'Add Medicine',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._medicines.asMap().entries.map((entry) {
                int index = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: isDark 
                    ? GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: _buildMedicineRow(index, isDark),
                      )
                    : AppCard(
                        padding: const EdgeInsets.all(12),
                        child: _buildMedicineRow(index, isDark),
                      ),
                );
              }),
              
              const SizedBox(height: 32),
              Text('Advice / Notes', style: AppTextStyles.h3.copyWith(color: accentColor)),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _adviceController,
                hint: 'Special instructions for the patient...',
                maxLines: 4,
                isDark: isDark,
              ),
              const SizedBox(height: 32),

              // Private Clinical Notes Toggle
              InkWell(
                onTap: () => setState(() => _showPrivateNotes = !_showPrivateNotes),
                child: Row(
                  children: [
                    Icon(
                      _showPrivateNotes ? Icons.visibility_off_outlined : Icons.visibility_outlined, 
                      color: AppColors.primary, 
                      size: 20
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _showPrivateNotes ? 'Hide Private Notes' : 'Add Private Clinical Notes',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (_showPrivateNotes) ...[
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _privateNotesController,
                  hint: 'Internal notes only - not visible to patient...',
                  maxLines: 3,
                  isDark: isDark,
                ),
              ],
              const SizedBox(height: 48),
              
              SizedBox(
                width: double.infinity,
                child: isDark 
                  ? GlassButton(
                      text: 'Save & Issue Prescription',
                      icon: Icons.send_rounded,
                      color: AppColors.liquidGold,
                      isLoading: _isLoading,
                      onPressed: _submitPrescription,
                    )
                  : ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitPrescription,
                      icon: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                          : const Icon(Icons.send_rounded),
                      label: Text(_isLoading ? 'Processing...' : 'Save & Issue Prescription'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineRow(int index, bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildSmallTextField(
            hint: 'Medicine Name',
            onChanged: (val) => _medicines[index]['name'] = val,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSmallTextField(
            hint: 'Dosage',
            onChanged: (val) => _medicines[index]['dosage'] = val,
            isDark: isDark,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
          onPressed: () => _removeMedicine(index),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    required bool isDark,
  }) {
    if (isDark) {
      return GlassContainer(
        opacity: 0.1,
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
          cursorColor: AppColors.liquidGold,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            border: InputBorder.none,
          ),
          validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint),
            border: InputBorder.none,
          ),
          validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
        ),
      );
    }
  }

  Widget _buildSmallTextField({
    required String hint,
    required Function(String) onChanged,
    required bool isDark,
  }) {
    return TextFormField(
      style: TextStyle(
        color: isDark ? AppColors.primary : AppColors.textPrimary, 
        fontSize: 14, 
        fontWeight: FontWeight.w500
      ),
      cursorColor: isDark ? AppColors.liquidGold : AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.3) : AppColors.textHint, 
          fontSize: 13
        ),
        isDense: true,
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.grey300
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.grey300
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? AppColors.liquidGold : AppColors.primary
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

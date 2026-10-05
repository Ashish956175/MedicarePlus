import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How can we help?', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            _buildSearchBox(),
            const SizedBox(height: 32),
            Text('Popular FAQs', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _buildFAQItem(context, 'How to book an appointment?'),
            _buildFAQItem(context, 'Can I cancel my booking?'),
            _buildFAQItem(context, 'How to view medical records?'),
            const SizedBox(height: 32),
            Text('Contact Us', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _buildContactItem(context, 'Live Chat', Icons.chat_bubble_outline, AppColors.info),
            _buildContactItem(context, 'Email Support', Icons.mail_outline, AppColors.success),
            _buildContactItem(context, 'Call Us', Icons.phone_outlined, AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search for articles...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        title: Text(question, style: AppTextStyles.bodyMedium),
        trailing: const Icon(Icons.add, size: 20),
        onTap: () {},
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Text(label, style: AppTextStyles.h3.copyWith(fontSize: 16, color: color)),
          const Spacer(),
          Icon(Icons.arrow_forward, color: color, size: 20),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/services/user_service.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/entrance_animation.dart';
import '../../../core/theme/page_transitions.dart';
import '../doctor/doctor_detail_screen.dart';
import '../home/widgets/doctor_card_enhanced.dart';
import '../../../core/widgets/responsive_web_container.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;
  final IconData icon;
  final Color themeColor;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
    required this.icon,
    required this.themeColor,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<List<Doctor>> _doctorsFuture;

  final Map<String, List<String>> _healthInsights = {
    'Cardiology': [
      'Maintain a healthy weight and exercise regularly for heart health.',
      'Monitor your blood pressure and cholesterol levels frequently.',
      'Adopt a balanced diet rich in fruits, vegetables, and whole grains.',
    ],
    'General': [
      'Stay hydrated and aim for at least 8 glasses of water a day.',
      'Get 7-9 hours of quality sleep every night for better immunity.',
      'Practice good hygiene, including regular handwashing.',
    ],
    'Dentist': [
      'Brush your teeth at least twice a day with fluoride toothpaste.',
      'Floss daily to remove plaque from between your teeth.',
      'Limit sugary snacks and drinks to prevent tooth decay.',
    ],
    'Neurology': [
      'Engage in activities that challenge your brain, like puzzles or reading.',
      'Manage stress through meditation or deep breathing exercises.',
      'Protect your head from injury by wearing helmets during sports.',
    ],
    'Pediatric': [
      'Ensure children receive their recommended vaccinations on schedule.',
      'Provide a safe environment for play and exploration.',
      'Encourage regular physical activity and healthy eating habits early.',
    ],
  };

  @override
  void initState() {
    super.initState();
    _doctorsFuture = UserService().getAllDoctors().then((all) {
      return all.where((doc) => 
        doc.specialization.toLowerCase() == widget.categoryName.toLowerCase()
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final insights = _healthInsights[widget.categoryName] ?? [
      'Consult with a specialist for personalized health advice.',
      'Regular check-ups are key to early detection and prevention.',
      'Maintain a healthy lifestyle through diet and exercise.',
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.categoryName, style: AppTextStyles.h2.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ResponsiveWebContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Category Header & Insights
              EntranceAnimation(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [widget.themeColor, widget.themeColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: widget.themeColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 40),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Health Insights',
                              style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 22),
                            ),
                            Text(
                              'Stay healthy with ${widget.categoryName.toLowerCase()} tips',
                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.9)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 2. Insight List
              EntranceAnimation(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Important Tips', style: AppTextStyles.h3),
                    const SizedBox(height: 16),
                    ...insights.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded, color: widget.themeColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. Recommended Doctors
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Related Doctors', style: AppTextStyles.h3),
                  TextButton(
                    onPressed: () {
                      // Could link to filtered search
                    },
                    child: Text(
                      'Search All',
                      style: TextStyle(color: widget.themeColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Doctor>>(
                future: _doctorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const ErrorState(message: 'Failed to find doctors');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(Icons.person_search, size: 48, color: AppColors.grey300),
                          const SizedBox(height: 12),
                          Text(
                            'No doctors recommended yet',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  final doctors = snapshot.data!;
                  return Column(
                    children: doctors.map((doctor) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: EntranceAnimation(
                        child: DoctorCardEnhanced(
                          doctor: doctor,
                          onTap: () => Navigator.push(
                            context,
                            FadePageRoute(child: DoctorDetailScreen(doctor: doctor)),
                          ),
                          isAvailableToday: true,
                        ),
                      ),
                    )).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

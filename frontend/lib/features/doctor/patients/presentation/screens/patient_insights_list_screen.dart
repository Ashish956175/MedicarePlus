import 'package:flutter/material.dart';
import 'package:medicare_plus/core/theme/app_colors.dart';
import 'package:medicare_plus/core/theme/app_text_styles.dart';
import 'package:medicare_plus/core/widgets/glass_card.dart';
import 'package:medicare_plus/core/services/doctor_service.dart';
import 'patient_insight_screen.dart';

class PatientInsightsListScreen extends StatefulWidget {
  const PatientInsightsListScreen({super.key});

  @override
  State<PatientInsightsListScreen> createState() => _PatientInsightsListScreenState();
}

class _PatientInsightsListScreenState extends State<PatientInsightsListScreen> {
  final DoctorService _doctorService = DoctorService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allPatients = [];
  List<dynamic> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final patients = await _doctorService.getDoctorPatients();
      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
      });
    } catch (e) {
      debugPrint('Error loading patients: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterPatients(String query) {
    setState(() {
      _filteredPatients = _allPatients.where((p) {
        final name = p['name'].toString().toLowerCase();
        final email = p['email'].toString().toLowerCase();
        return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white60 : AppColors.textSecondary;
    final goldColor = isDark ? AppColors.liquidGold : AppColors.primary;
    final searchFillColor = isDark ? Colors.white.withOpacity(0.05) : AppColors.grey100;
    final searchHintColor = isDark ? Colors.white.withOpacity(0.5) : AppColors.textHint;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Select Patient', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPatients,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search patient for insights...',
                hintStyle: TextStyle(color: searchHintColor),
                prefixIcon: Icon(Icons.search, color: goldColor),
                filled: true,
                fillColor: searchFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: goldColor))
                : _filteredPatients.isEmpty
                    ? _buildEmptyState(textColor, subTextColor)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return _buildPatientCard(patient, textColor, subTextColor, goldColor);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient, Color textColor, Color subTextColor, Color goldColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PatientInsightScreen(
                patientId: patient['id'],
                patientName: patient['name'],
              ),
            ),
          );
        },
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                patient['name'][0].toUpperCase(),
                style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient['name'], style: AppTextStyles.h3.copyWith(color: textColor)),
                  const SizedBox(height: 4),
                  Text('Tap to view health insights', style: AppTextStyles.caption.copyWith(color: goldColor)),
                ],
              ),
            ),
            Icon(Icons.analytics_outlined, color: subTextColor),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: goldColor),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color textColor, Color subTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined, size: 80, color: subTextColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No patients found',
            style: AppTextStyles.h3.copyWith(color: subTextColor),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/services/vault_service.dart';
import '../../../core/services/prescription_service.dart';
import '../../../core/services/auth_service.dart';
import '../home/screens/pharmacy_screen.dart';
import 'package:medicare_plus/core/widgets/entrance_animation.dart';

class WellnessWalletScreen extends StatefulWidget {
  const WellnessWalletScreen({super.key});

  @override
  State<WellnessWalletScreen> createState() => _WellnessWalletScreenState();
}

class _WellnessWalletScreenState extends State<WellnessWalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VaultService _vaultService = VaultService();
  final PrescriptionService _prescriptionService = PrescriptionService();
  
  bool _isLoading = true;
  List<dynamic> _records = [];
  List<dynamic> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = await AuthService().getUserId();
      if (userId != null) {
        final records = await _vaultService.getMyRecords(); // Use standard method
        final prescriptions = await _prescriptionService.getPatientPrescriptions(userId);
        setState(() {
          _records = records;
          _prescriptions = prescriptions;
        });
      }
    } catch (e) {
      debugPrint('Error loading wellness data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


void _showPrescriptionDetails(Map<String, dynamic> prescription) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Prescription', 
                    style: AppTextStyles.h2.copyWith(
                      color: isDark ? AppColors.liquidGold : AppColors.primary
                    )
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? Colors.white54 : AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: isDark ? Colors.white10 : AppColors.grey200),
              const SizedBox(height: 16),
              Text('DIAGNOSIS:', 
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? Colors.white60 : AppColors.textSecondary
                )
              ),
              Text(prescription['diagnosis'] ?? 'General Consultation', 
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary, 
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 16),
              Text('MEDICINES:', 
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? Colors.white60 : AppColors.textSecondary
                )
              ),
              const SizedBox(height: 8),
              ..._buildMedicineList(context, prescription['medicines']),
              const SizedBox(height: 16),
              Text('ADVICE:', 
                style: AppTextStyles.caption.copyWith(
                  color: isDark ? Colors.white60 : AppColors.textSecondary
                )
              ),
              Text(prescription['advice'] ?? 'Take rest and drink plenty of water.', 
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textSecondary
                )
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: GlassButton(
                  text: 'ORDER MEDICINES',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PharmacyScreen(initialPrescription: prescription),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMedicineList(BuildContext context, String? medicinesJson) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.liquidGold : AppColors.primary;
    
    if (medicinesJson == null || medicinesJson.isEmpty) {
      return [Text('No medicines prescribed.', 
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? Colors.white : AppColors.textPrimary
        )
      )];
    }
    
    try {
      final List<dynamic> medicines = jsonDecode(medicinesJson);
      return medicines.map((m) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Icon(Icons.circle, size: 6, color: accentColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text('${m['name']} - ${m['dosage']}', 
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary
                )
              ),
            ),
          ],
        ),
      )).toList();
    } catch (e) {
      return [Text('Error parsing medicines.', 
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? Colors.white : AppColors.textPrimary
        )
      )];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.liquidGold : AppColors.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? AppColors.royalNoir : AppColors.primary,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Wellness Wallet', 
                style: AppTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)]
                )
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [AppColors.royalNoir, AppColors.royalNoir.withOpacity(0.8)]
                      : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.account_balance_wallet_outlined, 
                    size: 80, 
                    color: Colors.white.withOpacity(0.1)
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: EntranceAnimation(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: accentColor,
                      indicatorWeight: 3,
                      labelColor: accentColor,
                      unselectedLabelColor: isDark ? Colors.white.withOpacity(0.4) : AppColors.textSecondary.withOpacity(0.5),
                      tabs: const [
                        Tab(text: 'Medical Records'),
                        Tab(text: 'Prescriptions'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRecordsList(context),
                          _buildPrescriptionsList(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add logic to upload record
        },
        backgroundColor: accentColor,
        child: Icon(Icons.add, color: isDark ? AppColors.royalNoir : Colors.white),
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.liquidGold : AppColors.primary;

    if (_isLoading) return Center(child: CircularProgressIndicator(color: accentColor));
    if (_records.isEmpty) return _buildEmptyState(context, 'No medical records found', Icons.description_outlined);

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return GlassCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.file_present_rounded, color: accentColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record['title'] ?? 'Record', 
                      style: AppTextStyles.h3.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary, 
                        fontSize: 16
                      )
                    ),
                    Text(record['description'] ?? 'No description provided', 
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? Colors.white.withOpacity(0.5) : AppColors.textSecondary
                      )
                    ),
                    Text(record['recordType'] ?? 'General', 
                      style: AppTextStyles.caption.copyWith(
                        color: accentColor.withOpacity(0.7)
                      )
                    ),
                  ],
                ),
              ),
              Icon(Icons.download_rounded, color: isDark ? Colors.white : AppColors.textSecondary, size: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionsList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.liquidGold : AppColors.primary;

    if (_isLoading) return Center(child: CircularProgressIndicator(color: accentColor));
    if (_prescriptions.isEmpty) return _buildEmptyState(context, 'No prescriptions available yet', Icons.medication_outlined);

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = _prescriptions[index];
        return GlassCard(
          child: InkWell(
            onTap: () => _showPrescriptionDetails(prescription),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medical_services_outlined, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(prescription['diagnosis'] ?? 'Consultation', 
                          style: AppTextStyles.h3.copyWith(
                            color: isDark ? Colors.white : AppColors.textPrimary, 
                            fontSize: 16
                          )
                        ),
                        Text('By Doctor #${prescription['doctorId']}', 
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? Colors.white.withOpacity(0.4) : AppColors.textSecondary
                          )
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: accentColor.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Text('Jan 24, 2026', 
                              style: AppTextStyles.caption.copyWith(
                                color: accentColor.withOpacity(0.6)
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Text('VIEW', 
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.success, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, 
            size: 64, 
            color: isDark ? Colors.white.withOpacity(0.2) : AppColors.textSecondary.withOpacity(0.2)
          ),
          const SizedBox(height: 16),
          Text(message, 
            style: TextStyle(
              color: isDark ? Colors.white.withOpacity(0.5) : AppColors.textSecondary
            )
          ),
        ],
      ),
    );
  }
}

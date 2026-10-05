import 'package:flutter/material.dart';
import 'dart:async';
import 'package:medicare_plus/core/theme/app_colors.dart';
import 'package:medicare_plus/core/theme/app_text_styles.dart';
import 'package:medicare_plus/core/widgets/glass_card.dart';
import 'package:medicare_plus/core/widgets/app_card.dart';
import 'package:medicare_plus/core/widgets/status_chip.dart';

class SystemStatusScreen extends StatefulWidget {
  const SystemStatusScreen({super.key});

  @override
  State<SystemStatusScreen> createState() => _SystemStatusScreenState();
}

class _SystemStatusScreenState extends State<SystemStatusScreen> {
  late Timer _timer;
  double _cpuUsage = 0.25;
  double _ramUsage = 0.45;
  int _activeUsers = 124;
  int _latency = 115;
  
  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Backend API',
      'status': 'Online',
      'uptime': '14d 6h 22m',
      'version': 'v2.1.0-stable',
      'endpoint': 'https://api.medicareplus.com',
      'latency': '45ms',
      'icon': Icons.dns_outlined,
    },
    {
      'name': 'Primary Database',
      'status': 'Online',
      'uptime': '45d 12h 05m',
      'type': 'PostgreSQL 15',
      'connections': '18/100',
      'latency': '12ms',
      'icon': Icons.storage_outlined,
    },
    {
      'name': 'Secure Vault',
      'status': 'Online',
      'uptime': '124d 0h 0m',
      'storage': '1.2TB / 5TB',
      'encryption': 'AES-256-GCM',
      'icon': Icons.enhanced_encryption_outlined,
    },
    {
      'name': 'Payment Gateway',
      'status': 'Online',
      'provider': 'Razorpay',
      'mode': 'Live',
      'last_check': 'now',
      'icon': Icons.payments_outlined,
    },
  ];

  final List<String> _errorLogs = [
    '[09:42:15] CRITICAL: Database connection pool nearly full (92%)',
    '[09:38:02] WARNING: User 8821 payment timeout after 3 retries',
    '[09:25:44] INFO: New version of Pharmacy Service deployed',
    '[09:12:10] INFO: Daily backup completed successfully',
  ];

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _cpuUsage = 0.2 + (DateTime.now().second % 10) / 100;
          _ramUsage = 0.45 + (DateTime.now().second % 5) / 200;
          _latency = 110 + (DateTime.now().second % 20);
          _activeUsers = 120 + (DateTime.now().second % 15);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subTextColor = isDark ? Colors.white60 : AppColors.textSecondary;
    final cardColor = Theme.of(context).cardColor;
    final glassColor = isDark ? Colors.white.withOpacity(0.1) : AppColors.primary.withOpacity(0.05);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('System Health Monitor', style: TextStyle(color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.liquidGold),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRealTimeRow(textColor, subTextColor, glassColor),
            const SizedBox(height: 32),
            
            Text('Service Heartbeat (Live)', style: AppTextStyles.h3.copyWith(color: AppColors.liquidGold)),
            const SizedBox(height: 16),
            ..._services.map((s) => _buildServiceCard(s, cardColor, textColor, subTextColor)).toList(),
            
            const SizedBox(height: 32),
            _buildResourceMetrics(textColor, glassColor),
            
            const SizedBox(height: 32),
            Text('Live System Events', style: AppTextStyles.h3.copyWith(color: textColor)),
            const SizedBox(height: 16),
            _buildErrorTicker(cardColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildRealTimeRow(Color textColor, Color subTextColor, Color glassColor) {
    return Row(
      children: [
        Expanded(
          child: _buildLiveMetric('Latency', '$_latency ms', Icons.bolt, AppColors.success, textColor, subTextColor, glassColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLiveMetric('Active Users', '$_activeUsers', Icons.group, AppColors.primary, textColor, subTextColor, glassColor),
        ),
      ],
    );
  }

  Widget _buildLiveMetric(String label, String value, IconData icon, Color color, Color textColor, Color subTextColor, Color glassColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h2.copyWith(color: textColor)),
          Text(label, style: AppTextStyles.caption.copyWith(color: subTextColor)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service, Color cardColor, Color textColor, Color subTextColor) {
    return AppCard(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(service['icon'], color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service['name'], style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.bold)),
                    Text(service['endpoint'] ?? service['provider'] ?? 'Internal Cluster', 
                      style: AppTextStyles.caption.copyWith(color: subTextColor)),
                  ],
                ),
              ),
              StatusChip(status: Status.completed),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: subTextColor.withOpacity(0.1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildServiceInfo('Uptime', service['uptime'] ?? 'N/A', subTextColor),
              _buildServiceInfo('Latency', service['latency'] ?? '8ms', subTextColor),
              _buildServiceInfo('Load', 'Normal', subTextColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo(String label, String value, Color subTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: subTextColor)),
        Text(value, style: AppTextStyles.bodySmall.copyWith(color: AppColors.liquidGold, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildResourceMetrics(Color textColor, Color glassColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resources', style: AppTextStyles.h3.copyWith(color: textColor)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildUsageGauge('CPU Load', _cpuUsage, AppColors.secondary, textColor, glassColor)),
            const SizedBox(width: 16),
            Expanded(child: _buildUsageGauge('RAM Usage', _ramUsage, AppColors.warning, textColor, glassColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildUsageGauge(String label, double value, Color color, Color textColor, Color glassColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.grey200),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: value,
                  backgroundColor: color.withOpacity(0.1),
                  color: color,
                  strokeWidth: 8,
                ),
              ),
              Text('${(value * 100).toInt()}%', style: AppTextStyles.bodyMedium.copyWith(color: textColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(label, style: AppTextStyles.caption.copyWith(color: textColor.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildErrorTicker(Color cardColor, Color textColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : AppColors.grey300),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _errorLogs.length,
        itemBuilder: (context, index) {
          final log = _errorLogs[index];
          final isError = log.contains('CRITICAL') || log.contains('ERROR');
          final isWarning = log.contains('WARNING');
          
          Color logColor = textColor;
          if (isError) logColor = AppColors.error;
          if (isWarning) logColor = AppColors.warning;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, size: 6, color: logColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    log,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      color: logColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

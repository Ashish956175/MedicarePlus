import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/glass_button.dart';

class ConsultationScreen extends StatefulWidget {
  final int appointmentId;
  final int patientId;

  const ConsultationScreen({
    super.key,
    required this.appointmentId,
    required this.patientId,
  });

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Video Feed (Placeholder)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1551076805-e1869033e561?q=80&w=2070&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_off, color: Colors.white54, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Patient ID: ${widget.patientId}',
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                      Text(
                        'Waiting for connection...',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Self View (PIP)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
                image: const DecorationImage(
                  image: NetworkImage('https://i.pravatar.cc/150?img=12'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    _isVideoOff ? Icons.videocam_off : Icons.videocam,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),

          // Top Header (Patient Info)
          Positioned(
            top: 50,
            left: 20,
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: 20,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Patient #${widget.patientId}',
                        style: AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        'General Checkup',
                        style: AppTextStyles.caption.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Control Bar
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildControlCircle(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      color: _isMuted ? AppColors.error : Colors.white24,
                      onTap: () => setState(() => _isMuted = !_isMuted),
                    ),
                    const SizedBox(width: 20),
                    _buildControlCircle(
                      icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                      color: _isVideoOff ? AppColors.error : Colors.white24,
                      onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                    ),
                    const SizedBox(width: 20),
                    _buildControlCircle(
                      icon: Icons.call_end,
                      color: AppColors.error,
                      size: 70,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 20),
                    _buildControlCircle(
                      icon: Icons.chat_bubble_outline,
                      color: Colors.white24,
                      onTap: () {
                        // Open Chat overlay
                      },
                    ),
                    const SizedBox(width: 20),
                    _buildControlCircle(
                      icon: Icons.more_vert,
                      color: Colors.white24,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCircle({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 56,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}

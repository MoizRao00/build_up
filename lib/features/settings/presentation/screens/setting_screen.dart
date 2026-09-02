import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../step_tracking/presentation/providers/step_provider.dart';
import '../../../../core/utils/export_service.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/native_health_service.dart';
import '../../../step_tracking/presentation/widgets/glass_step_card.dart';
import 'scheduler_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepState = ref.watch(stepNotifierProvider);
    final exportService = ExportService();
    final authController = ref.watch(authControllerProvider);
    
    // Watch the live profile data from Firestore
    final profileAsync = ref.watch(userProfileProvider);
    final profile = profileAsync.value;
    
    final displayName = profile?['name'] ?? profile?['displayName'] ?? 'Build Up User';
    final avatar = profile?['avatarUrl'] ?? '👦';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E293B),
                        border: Border.all(
                          color: AppColors.primaryEmerald,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          avatar,
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: GoogleFonts.sora(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: AppColors.primaryEmerald),
                  ),
                  title: Text(
                    'Edit Profile',
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Avatar, Name, Step Goal',
                    style: GoogleFonts.sora(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const ConditionalHealthNotice(),
              const SizedBox(height: 24),
              const Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications, color: AppColors.primaryEmerald),
                      title: const Text('Stand Alerts', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: Switch(
                        value: true,
                        onChanged: (bool value) {},
                        activeColor: AppColors.primaryEmerald,
                      ),
                    ),
                    const Divider(color: Colors.white24),
                    ListTile(
                      leading: const Icon(Icons.timer, color: AppColors.primaryEmerald),
                      title: const Text('Daily Walk Scheduler', style: TextStyle(color: AppColors.textPrimary)),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WalkSchedulerScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.white24),
                    ListTile(
                      leading: const Icon(Icons.picture_as_pdf, color: AppColors.primaryEmerald),
                      title: const Text('Export PDF Report', style: TextStyle(color: AppColors.textPrimary)),
                      onTap: () {
                        exportService.exportToPdf(
                          stepState.currentSteps,
                          stepState.calories,
                          stepState.distanceKm,
                        );
                      },
                    ),
                    const Divider(color: Colors.white24),
                    ListTile(
                      leading: const Icon(Icons.table_chart, color: AppColors.primaryEmerald),
                      title: const Text('Export CSV Data', style: TextStyle(color: AppColors.textPrimary)),
                      onTap: () {
                        exportService.exportToCsv(
                          stepState.currentSteps,
                          stepState.calories,
                          stepState.distanceKm,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.orangeAccent),
                  title: const Text('Sign Out', style: TextStyle(color: AppColors.textPrimary)),
                  onTap: () async {
                    await authController.signOut();
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'DANGER ZONE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text('Wipe All Data', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class ConditionalHealthNotice extends ConsumerWidget {
  const ConditionalHealthNotice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nativeHealth = ref.read(nativeHealthProvider);

    return FutureBuilder<int>(
      future: nativeHealth.getAndroidApiLevel(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data! < 34) {
          return const HealthConnectNotice();
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class HealthConnectNotice extends StatelessWidget {
  const HealthConnectNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryEmerald.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryEmerald,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Improve Step Accuracy',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'For the most precise step tracking experience, download the Google Health Connect application from the Play Store.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../step_tracking/presentation/providers/step_provider.dart';
import '../../../../core/utils/export_service.dart';
import '../../../step_tracking/presentation/widgets/glass_step_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/native_health_service.dart';
import 'scheduler_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepState = ref.watch(stepNotifierProvider);
    final exportService = ExportService();
    final authController = ref.watch(authControllerProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SETTINGS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const ConditionalHealthNotice(),
              const SizedBox(height: 24),
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
                    const Divider(color: AppColors.glassCardBorder),
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
                    const Divider(color: AppColors.glassCardBorder),
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
                    const Divider(color: AppColors.glassCardBorder),
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
        color: AppColors.glassCardBackground,
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
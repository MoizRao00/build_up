import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/step_provider.dart';
import '../providers/active_duration_provider.dart';
import '../widgets/glass_step_card.dart';
import '../widgets/metric_glass_card.dart';
import '../widgets/rest_mode_card.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(stepNotifierProvider.notifier).initializeTracking();
      ref.read(activeDurationProvider.notifier).startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stepState = ref.watch(stepNotifierProvider);
    final durationState = ref.watch(activeDurationProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUILD UP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Daily Movement',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                GlassCard(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: const [
                      Icon(Icons.bolt, color: AppColors.primaryEmerald, size: 18),
                      SizedBox(width: 4),
                      Text(
                        '120 Coins',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const RestModeCard(),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${stepState.currentSteps}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Target: ${stepState.goalSteps} steps',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: stepState.goalSteps > 0
                          ? (stepState.currentSteps / stepState.goalSteps)
                          .clamp(0.0, 1.0)
                          : 0.0,
                      minHeight: 12,
                      backgroundColor: AppColors.glassCardBackground,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryEmerald),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MetricGlassCard(
                    label: 'Calories',
                    value: stepState.calories.toStringAsFixed(1),
                    unit: 'kcal',
                    icon: Icons.local_fire_department,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricGlassCard(
                    label: 'Distance',
                    value: stepState.distanceKm.toStringAsFixed(1),
                    unit: 'km',
                    icon: Icons.map,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MetricGlassCard(
              label: 'Active Duration',
              value: durationState.formattedDuration,
              unit: '',
              icon: Icons.timer,
            ),
          ],
        ),
      ),
    );
  }
}
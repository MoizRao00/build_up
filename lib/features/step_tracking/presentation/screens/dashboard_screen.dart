import 'package:build_up/features/step_tracking/presentation/screens/route_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/step_provider.dart';
import '../providers/active_duration_provider.dart';
import '../widgets/glass_step_card.dart';
import '../widgets/metric_glass_card.dart';
import '../widgets/rest_mode_card.dart';
import '../../../gamification/presentation/widgets/daily_quote_card.dart';
import 'gps_tracking_screen.dart';

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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
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
                          fontWeight: FontWeight.w700,
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
                        Icon(Icons.bolt,
                            color: AppColors.primaryEmerald, size: 18),
                        SizedBox(width: 4),
                        Text(
                          '120 Coins',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      '${stepState.currentSteps}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
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
                  const SizedBox(width: 16),
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
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: MetricGlassCard(
                      label: 'Active Time',
                      value: stepState.activeDuration,
                      unit: '',
                      icon: Icons.timer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MetricGlassCard(
                      label: 'Goal Progress',
                      value: stepState.goalSteps > 0
                          ? ((stepState.currentSteps / stepState.goalSteps) * 100)
                          .clamp(0, 100)
                          .toStringAsFixed(0)
                          : '0',
                      unit: '%',
                      icon: Icons.flag,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RouteHistoryScreen()),
                  );
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryEmerald.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.history,
                          color: AppColors.primaryEmerald,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workout History',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'View past routes and records',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const DailyQuoteSwiper(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GpsTrackingScreen()),
          );
        },
        backgroundColor: AppColors.primaryEmerald,
        child: const Icon(Icons.location_on, color: Colors.white),
      ),
    );
  }
}
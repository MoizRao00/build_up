import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/step_provider.dart';
import 'glass_step_card.dart';


class RestModeCard extends ConsumerWidget {
  const RestModeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepState = ref.watch(stepNotifierProvider);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                stepState.isRestMode ? Icons.bedtime : Icons.directions_run,
                color: AppColors.primaryEmerald,
                size: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rest and Recovery',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    stepState.isRestMode
                        ? 'Streak protected for today'
                        : 'Active movement enabled',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: stepState.isRestMode,
            activeColor: AppColors.primaryEmerald,
            onChanged: (value) {
              ref.read(stepNotifierProvider.notifier).toggleRestMode();
            },
          ),
        ],
      ),
    );
  }
}
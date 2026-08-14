import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/premium_provider.dart';

class BannerAdPlaceholder extends ConsumerWidget {
  const BannerAdPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumProvider);

    if (premiumState.isPremium) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassCardBackground,
        border: Border.all(color: AppColors.glassCardBorder),
      ),
      child: const Center(
        child: Text(
          'ADVERTISEMENT',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}
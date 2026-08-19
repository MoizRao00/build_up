import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../step_tracking/presentation/widgets/glass_step_card.dart';
import '../../../step_tracking/presentation/providers/step_provider.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepState = ref.watch(stepNotifierProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'STORE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.2,
                  ),
                ),
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [ // Removed const from this Row
                      const Icon(Icons.bolt, color: AppColors.primaryEmerald, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${stepState.coins} Coins',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  StoreItemCard(
                    title: 'Neon Mint Theme',
                    price: 500,
                    icon: Icons.palette,
                  ),
                  StoreItemCard(
                    title: 'Pro Avatar Frame',
                    price: 300,
                    icon: Icons.account_circle,
                  ),
                  StoreItemCard(
                    title: 'Dark App Icon',
                    price: 150,
                    icon: Icons.apps,
                  ),
                  StoreItemCard(
                    title: 'Premium Analytics',
                    price: 1000,
                    icon: Icons.analytics,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StoreItemCard extends StatelessWidget {
  final String title;
  final int price;
  final IconData icon;

  const StoreItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryEmerald, size: 40),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryEmerald.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$price Coins',
              style: const TextStyle(
                color: AppColors.primaryEmerald,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
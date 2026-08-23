import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../step_tracking/presentation/widgets/glass_step_card.dart';
import '../../../step_tracking/presentation/providers/step_provider.dart';
import '../providers/theme_provider.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  static const Color neonGreen = Color(0xFF1DE9B6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepState = ref.watch(stepNotifierProvider);
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    final shopItems = [
      {'id': 'neon', 'title': 'Neon Mint Theme', 'price': 500, 'icon': Icons.palette},
      {'id': 'ocean', 'title': 'Ocean Blue Theme', 'price': 100, 'icon': Icons.water_drop},
      {'id': 'sunset', 'title': 'Sunset Orange Theme', 'price': 200, 'icon': Icons.wb_sunny},
      {'id': 'amethyst', 'title': 'Amethyst Purple Theme', 'price': 300, 'icon': Icons.auto_awesome},
      {'id': 'avatar_pro', 'title': 'Pro Avatar Frame', 'price': 300, 'icon': Icons.account_circle},
      {'id': 'icon_dark', 'title': 'Dark App Icon', 'price': 150, 'icon': Icons.apps},
      {'id': 'analytics', 'title': 'Premium Analytics', 'price': 1000, 'icon': Icons.analytics},
    ];

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
                  'SHOP',
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
                    children: [
                      const Icon(Icons.bolt, color: neonGreen, size: 18),
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
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: shopItems.length,
                itemBuilder: (context, index) {
                  final item = shopItems[index];
                  final String id = item['id'] as String;

                  final bool isPurchased = themeState.purchasedThemes.contains(id);
                  final bool isEquipped = themeState.activeThemeId == id;
                  final Color itemThemeColor = themeNotifier.themeColors[id] ?? neonGreen;

                  return GestureDetector(
                    onTap: () {
                      if (!isPurchased) {
                        themeNotifier.purchaseTheme(id, item['price'] as int);
                      } else if (!isEquipped) {
                        themeNotifier.setActiveTheme(id);
                      }
                    },
                    child: ShopItemCard(
                      title: item['title'] as String,
                      price: item['price'] as int,
                      icon: item['icon'] as IconData,
                      isPurchased: isPurchased,
                      isEquipped: isEquipped,
                      activeColor: itemThemeColor,
                      primaryAppColor: themeState.primaryColor,
                      iconColor: neonGreen,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShopItemCard extends StatelessWidget {
  final String title;
  final int price;
  final IconData icon;
  final bool isPurchased;
  final bool isEquipped;
  final Color activeColor;
  final Color primaryAppColor;
  final Color iconColor;

  const ShopItemCard({
    super.key,
    required this.title,
    required this.price,
    required this.icon,
    required this.isPurchased,
    required this.isEquipped,
    required this.activeColor,
    required this.primaryAppColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final String statusText = isEquipped ? 'Equipped' : (isPurchased ? 'Equip' : '$price Coins');

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 40),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isEquipped ? activeColor.withOpacity(0.2) : Colors.transparent,
              border: Border.all(
                color: isEquipped ? activeColor : primaryAppColor.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: isEquipped ? activeColor : AppColors.textPrimary,
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
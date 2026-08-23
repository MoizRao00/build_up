import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../shop/presentation/providers/theme_provider.dart';
import '../../../step_tracking/presentation/widgets/glass_step_card.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'LEADERBOARD',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: leaderboardAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    return const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final isTopThree = index < 3;

                      Color rankColor;
                      if (index == 0) {
                        rankColor = const Color(0xFFFFD700);
                      } else if (index == 1) {
                        rankColor = const Color(0xFFC0C0C0);
                      } else if (index == 2) {
                        rankColor = const Color(0xFFCD7F32);
                      } else {
                        rankColor = themeState.primaryColor;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isTopThree ? rankColor.withOpacity(0.2) : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isTopThree ? rankColor : AppColors.glassCardBorder,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isTopThree ? rankColor : AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: themeState.primaryColor.withOpacity(0.2),
                                backgroundImage: user.avatarUrl.isNotEmpty
                                    ? NetworkImage(user.avatarUrl)
                                    : null,
                                child: user.avatarUrl.isEmpty
                                    ? Icon(Icons.person, color: themeState.primaryColor)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${user.totalSteps} Steps',
                                      style: TextStyle(
                                        color: themeState.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isTopThree)
                                Icon(
                                  Icons.emoji_events,
                                  color: rankColor,
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(color: themeState.primaryColor),
                ),
                error: (error, stack) => Center(
                  child: Text(
                    'Error loading leaderboard',
                    style: TextStyle(color: themeState.primaryColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
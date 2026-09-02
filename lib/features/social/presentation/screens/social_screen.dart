import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../shop/presentation/providers/theme_provider.dart';
import '../providers/leaderboard_provider.dart';


class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Center(
                child: Text(
                          'LeaderBoard',
                          style: GoogleFonts.sora(
                            fontSize: size.width * 0.06,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            letterSpacing: 1.2,

                          ),
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
                      // Inside your ListView.builder
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.glassCardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassCardBorder),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primaryEmerald.withOpacity(0.2),
                              backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
                              child: user.avatarUrl.isEmpty
                                  ? const Icon(Icons.person, color: AppColors.primaryEmerald)
                                  : null,
                            ),
                            title: Text(
                              user.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${user.monthlyHighScore}',
                                  style: const TextStyle(
                                    color: AppColors.primaryEmerald,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Text(
                                  'High Score',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
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
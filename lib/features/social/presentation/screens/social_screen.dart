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
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final bool isImageUrl = user.avatarUrl.startsWith('http');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.glassCardBackground.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryEmerald,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: const Color(0xFF1E293B),
                                backgroundImage: isImageUrl ? NetworkImage(user.avatarUrl) : null,
                                child: !isImageUrl && user.avatarUrl.isNotEmpty
                                    ? Text(user.avatarUrl, style: const TextStyle(fontSize: 24))
                                    : (user.avatarUrl.isEmpty 
                                        ? const Icon(Icons.person, color: AppColors.primaryEmerald)
                                        : null),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user.name,
                                    style: GoogleFonts.sora(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'HIGH SCORE',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${user.monthlyHighScore}',
                              style: GoogleFonts.sora(
                                color: AppColors.primaryEmerald,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                          ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/challenge_provider.dart';
import 'challenge_card.dart';

class AllChallengesScreen extends ConsumerWidget {
  const AllChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengeProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'ALL CHALLENGES',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: challenges.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return ChallengeCard(challenge: challenges[index]);
        },
      ),
    );
  }
}
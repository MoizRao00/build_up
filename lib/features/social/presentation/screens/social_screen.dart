import 'package:build_up/features/social/presentation/screens/all_challenges_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../shop/presentation/providers/theme_provider.dart';
import '../../../step_tracking/presentation/providers/step_provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/leaderboard_provider.dart';
import 'challenge_card.dart';

class StepChallenge {
  final String id;
  final String title;
  final String subtitle;
  final String rewardText;
  final int targetSteps;
  final bool isActive;
  final double progress;

  const StepChallenge({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.rewardText,
    required this.targetSteps,
    required this.isActive,
    required this.progress,
  });
}

final demoChallenges = [
  const StepChallenge(
    id: '1',
    title: 'Starter Sprint',
    subtitle: 'Walk 1,000 steps today',
    rewardText: '+15 Coins',
    targetSteps: 1000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '2',
    title: 'Morning Stroll',
    subtitle: 'Walk 3,000 steps',
    rewardText: '+45 Coins',
    targetSteps: 3000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '3',
    title: 'Daily Dash',
    subtitle: 'Walk 5,000 steps in 24 hours',
    rewardText: '+75 Coins',
    targetSteps: 5000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '4',
    title: 'Step Master',
    subtitle: 'Walk 8,000 steps',
    rewardText: '+120 Coins',
    targetSteps: 8000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '5',
    title: '10K Milestone',
    subtitle: 'Walk 10,000 steps in one day',
    rewardText: '+150 Coins',
    targetSteps: 10000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '6',
    title: 'Lunchtime Loop',
    subtitle: 'Walk 12,000 steps',
    rewardText: '+180 Coins',
    targetSteps: 12000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '7',
    title: 'Weekend Hiker',
    subtitle: 'Walk 15,000 steps this weekend',
    rewardText: '+225 Coins',
    targetSteps: 15000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '8',
    title: 'Double Dash',
    subtitle: 'Walk 20,000 steps in 2 days',
    rewardText: '+300 Coins',
    targetSteps: 20000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '9',
    title: 'City Sprinter',
    subtitle: 'Walk 26,000 steps (20km)',
    rewardText: '+390 Coins',
    targetSteps: 26000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '10',
    title: 'Marathon Walker',
    subtitle: 'Walk 40,000 steps in a week',
    rewardText: '+600 Coins',
    targetSteps: 40000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '11',
    title: 'Weekly Warrior',
    subtitle: 'Walk 50,000 steps in 7 days',
    rewardText: '+750 Coins',
    targetSteps: 50000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '12',
    title: 'Ultra Explorer',
    subtitle: 'Walk 75,000 steps in 10 days',
    rewardText: '+1,125 Coins',
    targetSteps: 75000,
    isActive: false,
    progress: 0.0,
  ),
  const StepChallenge(
    id: '13',
    title: 'Century Club',
    subtitle: 'Walk 100,000 steps this month',
    rewardText: '+1,500 Coins',
    targetSteps: 100000,
    isActive: false,
    progress: 0.0,
  ),
];

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final size = MediaQuery.of(context).size;
    final challenges = ref.watch(challengeProvider);
    final stepState = ref.watch(stepNotifierProvider);
    Color currentTierColor = stepState.currentLeague.color;
    final double horizontalPadding = size.width * 0.05;
    final double verticalSpacing = size.height * 0.02;
    final double titleFontSize = size.width * 0.06;
    final double buttonFontSize = size.width * 0.035;

    final activeList = challenges.where((c) => c.isActive && !c.isCompleted).toList();
    final displayList = [...activeList.take(2)];

    if (displayList.length < 2) {
      final fallbackList = challenges
          .where((c) => !c.isActive && !c.isCompleted && !displayList.contains(c))
          .toList();
      displayList.addAll(fallbackList.take(2 - displayList.length));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: size.height * 0.025),
                child: Center(
                  child: Text(
                    'CHALLENGES',
                    style: GoogleFonts.inter(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: displayList.map((c) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: verticalSpacing),
                      child: ChallengeCard(challenge: c),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: size.height * 0.00),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllChallengesScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'VIEW ALL CHALLENGES   ',
                    style: GoogleFonts.inter(
                      color: AppColors.primaryEmerald,
                      fontWeight: FontWeight.w700,
                      fontSize: buttonFontSize,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.001),
              Text(
                'STEP RACE',
                style: GoogleFonts.inter(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: verticalSpacing),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: leaderboardAsync.when(
                  data: (users) {
                    if (users.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No data available',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final bool isImageUrl = user.avatarUrl.startsWith('http');
                        final double avatarSize = size.width * 0.12;

                        return Container(
                          margin: EdgeInsets.only(bottom: size.height * 0.015),
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.02,
                          ),
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
                                width: avatarSize,
                                height: avatarSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: currentTierColor,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: const Color(0xFF1E293B),
                                  backgroundImage: isImageUrl ? NetworkImage(user.avatarUrl) : null,
                                  child: !isImageUrl && user.avatarUrl.isNotEmpty
                                      ? Text(user.avatarUrl, style: TextStyle(fontSize: size.width * 0.06))
                                      : (user.avatarUrl.isEmpty
                                      ? Icon(Icons.person, color: AppColors.primaryEmerald, size: size.width * 0.06)
                                      : null),
                                ),
                              ),
                              SizedBox(width: size.width * 0.04),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      user.name,
                                      style: GoogleFonts.inter(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: size.width * 0.04,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.005),
                                    Text(
                                      'HIGH SCORE',
                                      style: GoogleFonts.inter(
                                        color: AppColors.textSecondary,
                                        fontSize: size.width * 0.028,
                                        letterSpacing: 1.2,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${user.monthlyHighScore}',
                                style: GoogleFonts.inter(
                                  color: AppColors.primaryEmerald,
                                  fontWeight: FontWeight.w700,
                                  fontSize: size.width * 0.05,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: themeState.primaryColor),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error loading leaderboard',
                        style: TextStyle(color: themeState.primaryColor),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
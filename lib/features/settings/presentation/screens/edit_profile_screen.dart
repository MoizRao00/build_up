import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../app/theme/app_colors.dart';

import '../../../step_tracking/presentation/providers/step_provider.dart';
import '../../../step_tracking/presentation/widgets/glass_step_card.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController goalController;
  String selectedAvatar = '🤖';
  bool _isSaving = false;

  final List<String> avatars = [
    '🤖', '👦', '👧', '👨', '👩', '🧔', '👱‍♀️', '👾', '🦊', '🦁', '🐯', '🐼', '🐨', '🦖', '🏀', '⚽', '🎮', '🎧', '🚀', '🌈'
  ];

  @override
  void initState() {
    super.initState();
    final stepState = ref.read(stepNotifierProvider);
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Build Up User';

    nameController = TextEditingController(text: displayName);
    goalController = TextEditingController(text: stepState.goalSteps.toString());
    
    // Load current avatar from Firestore
    _loadUserAvatar();
  }

  Future<void> _loadUserAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()?['avatarUrl'] != null) {
          final savedAvatar = doc.data()?['avatarUrl'];
          if (avatars.contains(savedAvatar)) {
            setState(() {
              selectedAvatar = savedAvatar;
            });
          }
        }
      } catch (e) {
        debugPrint('Error loading avatar: $e');
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    goalController.dispose();
    super.dispose();
  }

  void saveProfile() async {
    if (_isSaving) return;

    final newName = nameController.text.trim();
    final newGoal = int.tryParse(goalController.text) ?? 10000;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && newName.isNotEmpty) {
        // 1. Update Firebase Display Name
        await user.updateDisplayName(newName);

        // 2. Sync Name and Avatar to Firestore for Social Screen
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': newName,
          'avatarUrl': selectedAvatar,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // 3. Update Step Goal
      ref.read(stepNotifierProvider.notifier).updateGoal(newGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PROFILE UPDATED',
              textAlign: TextAlign.center,
              style: GoogleFonts.sora(
                color: AppColors.backgroundDark,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            backgroundColor: AppColors.primaryEmerald,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            duration: const Duration(seconds: 2),
          ),
        );
        
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'EDIT PROFILE',
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: .1,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'SELECT AVATAR',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  final avatar = avatars[index];
                  final isSelected = selectedAvatar == avatar;
                  return GestureDetector(
                    onTap: () => setState(() => selectedAvatar = avatar),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryEmerald
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: const Color(0xFF1E293B),
                        child: Text(
                          avatar,
                          style: const TextStyle(fontSize: 35),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'DISPLAY NAME',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: nameController,
                style: GoogleFonts.sora(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  icon: Icon(Icons.badge, color: AppColors.primaryEmerald),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'DAILY STEP GOAL',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: goalController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.sora(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g. 10000',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  icon: Icon(Icons.directions_walk, color: AppColors.primaryEmerald),
                ),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryEmerald,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : saveProfile,
                child: _isSaving 
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.backgroundDark,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'SAVE CHANGES',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.backgroundDark,
                        letterSpacing: 1.2,
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
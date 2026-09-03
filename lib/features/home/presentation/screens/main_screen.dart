import 'dart:io';
import 'package:build_up/features/insight/presentation/insights_screen.dart';
import 'package:build_up/features/step_tracking/presentation/screens/gps_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../settings/presentation/screens/setting_screen.dart';
import '../../../shop/presentation/screens/store_screen.dart';
import '../../../social/presentation/screens/social_screen.dart';
import '../../../step_tracking/presentation/providers/step_provider.dart';
import '../../../step_tracking/presentation/screens/dashboard_screen.dart';


class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardView(),
    InsightsScreen (),
     ChallengeScreen(),
    GpsTrackingScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndroidVersionAndPrompt();
    });
  }

  Future<void> _checkAndroidVersionAndPrompt() async {
    if (!Platform.isAndroid) return;

    final storage = ref.read(storageProvider);
    if (storage.getBatteryPromptShown()) return;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt <= 33) {
      if (mounted) {
        _showBatteryDialog(storage);
      }
    }
  }

  void _showBatteryDialog(LocalStorageService storage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Enable Background Tracking',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'You must disable battery optimization for Build Up to count your steps accurately in the background.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              storage.saveBatteryPromptShown(true);
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(permissionServiceProvider).requestBatteryExemption();
              storage.saveBatteryPromptShown(true);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryEmerald,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Enable', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      extendBody: false,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141618),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_filled),
              _buildNavItem(1, Icons.auto_graph_rounded),
              _buildNavItem(2, Icons.groups_rounded),
              _buildNavItem(3, Icons.location_on),
              _buildNavItem(4, Icons.settings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryEmerald : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : AppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }
}

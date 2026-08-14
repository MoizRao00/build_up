import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../gamification/presentation/screens/store_screen.dart';
import '../../../settings/presentation/screens/setting_screen.dart';
import '../../../social/presentation/screens/social_screen.dart';
import '../../../step_tracking/presentation/screens/dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardView(),
    const StoreScreen(),
    const SocialScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.glassCardBorder, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.backgroundDark,
          selectedItemColor: AppColors.primaryEmerald,
          unselectedItemColor: AppColors.textSecondary,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_walk),
              label: 'Tracker',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: 'Social',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
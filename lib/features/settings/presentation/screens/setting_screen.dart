import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../step_tracking/presentation/widgets/glass_step_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SETTINGS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.notifications, color: AppColors.primaryEmerald),
                    title: const Text('Stand Alerts', style: TextStyle(color: AppColors.textPrimary)),
                    trailing: Switch(
                      value: true,
                      onChanged: (bool value) {},
                      activeColor: AppColors.primaryEmerald,
                    ),
                  ),
                  const Divider(color: AppColors.glassCardBorder),
                  ListTile(
                    leading: const Icon(Icons.download, color: AppColors.primaryEmerald),
                    title: const Text('Export Data (PDF/CSV)', style: TextStyle(color: AppColors.textPrimary)),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'DANGER ZONE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                title: const Text('Wipe All Data', style: TextStyle(color: Colors.redAccent)),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
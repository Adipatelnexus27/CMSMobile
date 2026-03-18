import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/index.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Profile', style: AppTypography.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // User Info
            Text('John Doe', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.sm),
            Text('Claims Investigator', style: AppTypography.small),
            const SizedBox(height: AppSpacing.lg),

            // User Details Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileInfoRow('Email', 'john.doe@company.com'),
                  const SizedBox(height: AppSpacing.md),
                  _ProfileInfoRow('Phone', '+1 (555) 123-4567'),
                  const SizedBox(height: AppSpacing.md),
                  _ProfileInfoRow('Employee ID', 'EMP-2025-001'),
                  const SizedBox(height: AppSpacing.md),
                  _ProfileInfoRow('Department', 'Claims Department'),
                  const SizedBox(height: AppSpacing.md),
                  _ProfileInfoRow('Region', 'North Region'),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Settings Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Settings', style: AppTypography.h3),
            ),
            const SizedBox(height: AppSpacing.md),

            _SettingsTile(
              icon: Icons.notifications,
              label: 'Notifications',
              onTap: () {
                // Open notifications settings
              },
            ),
            _SettingsTile(
              icon: Icons.security,
              label: 'Security & Privacy',
              onTap: () {
                // Open security settings
              },
            ),
            _SettingsTile(
              icon: Icons.language,
              label: 'Language',
              onTap: () {
                // Open language settings
              },
            ),
            _SettingsTile(
              icon: Icons.dark_mode,
              label: 'Theme',
              onTap: () {
                // Open theme settings
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // App Info
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileInfoRow('App Version', '1.0.0'),
                  const SizedBox(height: AppSpacing.md),
                  _ProfileInfoRow('Last Sync', 'Today at 2:30 PM'),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Storage Used', style: AppTypography.body),
                      Text('245 MB', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Logout Button
            DangerButton(
              label: 'Logout',
              onPressed: () {
                _showLogoutConfirmation();
              },
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.body),
        Text(value, style: AppTypography.small),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: AppSpacing.iconMedium),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: AppTypography.body),
            const Spacer(),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

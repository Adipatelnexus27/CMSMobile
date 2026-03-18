import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/index.dart';

class SyncPage extends StatefulWidget {
  const SyncPage({Key? key}) : super(key: key);

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  bool _isSyncing = false;
  String _lastSyncTime = 'Today at 2:30 PM';
  final List<Map<String, String>> _pendingItems = [
    {'type': 'Note', 'description': 'Investigation update', 'date': '2026-03-18 10:30'},
    {'type': 'Photo', 'description': 'damage_photo_1.jpg', 'date': '2026-03-18 10:15'},
    {'type': 'Document', 'description': 'inspection_report.pdf', 'date': '2026-03-18 09:45'},
  ];

  void _handleSync() {
    setState(() => _isSyncing = true);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _lastSyncTime = 'Just now';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sync completed successfully')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Sync Data', style: AppTypography.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Sync Information
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                border: Border.all(color: AppColors.success),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: AppSpacing.iconMedium,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text('Last Sync', style: AppTypography.label),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _lastSyncTime,
                    style: AppTypography.h3.copyWith(color: AppColors.success),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Sync Button
            AppButton(
              label: _isSyncing ? 'Syncing...' : 'Sync Now',
              isLoading: _isSyncing,
              onPressed: _isSyncing ? () {} : _handleSync,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Pending Items
            Text('Pending Uploads (${_pendingItems.length})', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),

            if (_pendingItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_done,
                      color: AppColors.primary,
                      size: AppSpacing.iconLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'All data synced!',
                      style: AppTypography.body.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              )
            else
              ..._pendingItems.asMap().entries.map((entry) {
                final item = entry.value;
                return _PendingItem(
                  type: item['type']!,
                  description: item['description']!,
                  date: item['date']!,
                );
              }).toList(),

            const SizedBox(height: AppSpacing.lg),

            // Connection Status
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wifi,
                    color: AppColors.info,
                    size: AppSpacing.iconMedium,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Connection Status', style: AppTypography.label),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Online - Connected to network',
                          style: AppTypography.small.copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingItem extends StatelessWidget {
  final String type;
  final String description;
  final String date;

  const _PendingItem({
    required this.type,
    required this.description,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForType(type),
            color: AppColors.warning,
            size: AppSpacing.iconMedium,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: AppTypography.label),
                const SizedBox(height: AppSpacing.xxs),
                Text(description, style: AppTypography.small),
                const SizedBox(height: AppSpacing.xxs),
                Text(date, style: AppTypography.caption),
              ],
            ),
          ),
          Icon(
            Icons.cloud_upload,
            color: AppColors.warning,
            size: AppSpacing.iconMedium,
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'photo':
        return Icons.image;
      case 'document':
        return Icons.description;
      case 'note':
        return Icons.note;
      default:
        return Icons.file_present;
    }
  }
}

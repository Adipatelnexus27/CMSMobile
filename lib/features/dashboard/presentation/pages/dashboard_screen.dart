import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/index.dart';

/// Main dashboard screen showing claims summary and statistics.
/// 
/// Displays:
/// - User greeting with daily summary
/// - Statistics cards (assigned claims, pending tasks, etc.)
/// - Recent claims list with quick actions
/// - Notifications badge
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String _userName = 'John Doe';
  final int _notificationCount = 3;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // TODO: Fetch actual user data from AuthBloc
    // final authState = context.read<AuthBloc>().state;
    // _userName = authState.session?.userName ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $_userName',
              style: AppTypography.h2,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Here\'s your daily summary',
              style: AppTypography.small,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/notifications');
                  },
                ),
                if (_notificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _notificationCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          bottom: AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  StatisticCard(
                    title: 'Assigned Claims',
                    value: '12',
                    icon: Icons.assignment,
                    iconColor: AppColors.primary,
                    onTap: () => Navigator.of(context).pushNamed('/claims'),
                  ),
                  StatisticCard(
                    title: 'Pending Tasks',
                    value: '5',
                    icon: Icons.checklist,
                    iconColor: AppColors.warning,
                    onTap: () => Navigator.of(context).pushNamed('/tasks'),
                  ),
                  StatisticCard(
                    title: 'Investigations',
                    value: '3',
                    icon: Icons.search,
                    iconColor: AppColors.secondary,
                    onTap: () {
                      // Navigate to investigations
                    },
                  ),
                  StatisticCard(
                    title: 'Urgent Alerts',
                    value: '2',
                    icon: Icons.warning,
                    iconColor: AppColors.error,
                    onTap: () {
                      // Navigate to alerts
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _QuickActionTile(
                        icon: Icons.edit,
                        label: 'New\nInvestigation',
                        onTap: () {
                          Navigator.of(context).pushNamed('/investigation/new');
                        },
                      ),
                      _QuickActionTile(
                        icon: Icons.camera_alt,
                        label: 'Capture\nPhoto',
                        onTap: () {
                          Navigator.of(context).pushNamed('/camera');
                        },
                      ),
                      _QuickActionTile(
                        icon: Icons.note_add,
                        label: 'Add\nNote',
                        onTap: () {
                          Navigator.of(context).pushNamed('/note/add');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Recent Claims Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Claims',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _RecentClaimTile(
                    claimId: 'CLM-2026-001',
                    name: 'Alice Johnson',
                    status: 'In Progress',
                    priority: 'High',
                    onTap: () {
                      Navigator.of(context).pushNamed('/claim-detail/CLM-2026-001');
                    },
                  ),
                  _RecentClaimTile(
                    claimId: 'CLM-2026-002',
                    name: 'Bob Smith',
                    status: 'Pending Investigation',
                    priority: 'Medium',
                    onTap: () {
                      Navigator.of(context).pushNamed('/claim-detail/CLM-2026-002');
                    },
                  ),
                  _RecentClaimTile(
                    claimId: 'CLM-2026-003',
                    name: 'Charlie Brown',
                    status: 'Completed',
                    priority: 'Low',
                    onTap: () {
                      Navigator.of(context).pushNamed('/claim-detail/CLM-2026-003');
                    },
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

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSpacing.iconLarge,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentClaimTile extends StatelessWidget {
  final String claimId;
  final String name;
  final String status;
  final String priority;
  final VoidCallback onTap;

  const _RecentClaimTile({
    required this.claimId,
    required this.name,
    required this.status,
    required this.priority,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(claimId, style: AppTypography.h3),
                PriorityBadge(priority: priority),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(name, style: AppTypography.small),
            const SizedBox(height: AppSpacing.sm),
            StatusBadge(status: status),
          ],
        ),
      ),
    );
  }
}

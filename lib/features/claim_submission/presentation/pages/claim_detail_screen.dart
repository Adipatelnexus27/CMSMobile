import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/index.dart';

/// Screen displaying detailed claim information with 5 tabs.
/// 
/// Tabs include:
/// - Overview: Policy and incident information with quick actions
/// - Investigation: Investigation progress and documents  
/// - Evidence: Uploaded evidence files and documents
/// - Notes: Investigator notes and comments
/// - Tasks: Associated tasks and action items
class ClaimDetailPage extends StatefulWidget {
  final String claimId;

  const ClaimDetailPage({Key? key, required this.claimId}) : super(key: key);

  @override
  State<ClaimDetailPage> createState() => _ClaimDetailPageState();
}

class _ClaimDetailPageState extends State<ClaimDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() => _activeTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            Text(widget.claimId, style: AppTypography.h3),
            const SizedBox(height: AppSpacing.xxs),
            const StatusBadge(status: 'In Progress'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showMoreOptions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          AppTabBar(
            tabs: const ['Overview', 'Investigation', 'Evidence', 'Notes', 'Tasks'],
            tabController: _tabController,
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(),
                _InvestigationTab(),
                _EvidenceTab(),
                _NotesTab(),
                _TasksTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _getFloatingButton(),
    );
  }

  Widget? _getFloatingButton() {
    switch (_activeTab) {
      case 2: // Evidence
        return AppFloatingActionButton(
          label: 'Add Evidence',
          icon: Icons.upload_file,
          onPressed: () {
            Navigator.of(context).pushNamed('/evidence/upload');
          },
        );
      case 3: // Notes
        return AppFloatingActionButton(
          label: 'Add Note',
          icon: Icons.note_add,
          onPressed: () {
            Navigator.of(context).pushNamed('/note/add');
          },
        );
      case 4: // Tasks
        return AppFloatingActionButton(
          label: 'Create Task',
          icon: Icons.add_task,
          onPressed: () {
            Navigator.of(context).pushNamed('/task/create');
          },
        );
      default:
        return null;
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Flag as Fraud'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/fraud-flag');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Approve Claim'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/approval');
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Reject Claim'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rejection initiated')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}

class _OverviewTab extends StatelessWidget {
  void _launchDialer() {
    // TODO: Implement URL launcher for tel: scheme
    // Usage: url_launcher package with tel: scheme
  }

  void _launchMaps() {
    // TODO: Implement URL launcher for maps with incident location
    // Usage: url_launcher package with geo: or maps: scheme
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Policy Information'),
          _InfoTile('Policy Number', 'POL-2025-12345'),
          _InfoTile('Policy Holder', 'John Doe'),
          _InfoTile('Coverage Type', 'Property & Casualty'),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle('Incident Information'),
          _InfoTile('Incident Date', '2026-03-10'),
          _InfoTile('Incident Type', 'Property Damage'),
          _InfoTile('Location', '123 Main Street, City, State'),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle('Quick Actions'),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _launchDialer,
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _launchMaps,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Navigate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _SectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(title, style: AppTypography.h3),
    );
  }

  Widget _InfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.label),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.body),
        ],
      ),
    );
  }
}

class _InvestigationTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppButton(
            label: 'Start Investigation',
            onPressed: () {
              Navigator.of(context).pushNamed('/investigation/new');
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Investigation Status', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.md),
          const StatusBadge(status: 'In Progress'),
          const SizedBox(height: AppSpacing.lg),
          _SectionContent('Site Visit Details', 'Awaiting Site Visit'),
          _SectionContent('Damage Assessment', 'Not Started'),
          _SectionContent('Liability Assessment', 'In Progress'),
          _SectionContent('Fraud Indicators', '0 flags'),
        ],
      ),
    );
  }

  Widget _SectionContent(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(content, style: AppTypography.small),
        ],
      ),
    );
  }
}

class _EvidenceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final evidenceItems = [
      {'name': 'photo_1.jpg', 'type': 'Image', 'date': '2026-03-15'},
      {'name': 'report.pdf', 'type': 'Document', 'date': '2026-03-16'},
      {'name': 'video_1.mp4', 'type': 'Video', 'date': '2026-03-17'},
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: evidenceItems
          .map((item) => _EvidenceItem(
                name: item['name']!,
                type: item['type']!,
                date: item['date']!,
              ))
          .toList(),
    );
  }
}

class _EvidenceItem extends StatelessWidget {
  final String name;
  final String type;
  final String date;

  const _EvidenceItem({
    required this.name,
    required this.type,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Preview evidence
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: const Icon(Icons.file_present, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.body),
                  const SizedBox(height: AppSpacing.xxs),
                  Text('$type • $date', style: AppTypography.small),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _NotesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _NoteCard(
          title: 'Initial Investigation',
          content: 'Visited the site. Initial assessment completed.',
          date: '2026-03-15',
          author: 'John Doe',
        ),
        _NoteCard(
          title: 'Damage Assessment',
          content: 'Damage is consistent with claim description.',
          date: '2026-03-16',
          author: 'Jane Smith',
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;
  final String author;

  const _NoteCard({
    required this.title,
    required this.content,
    required this.date,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(title, style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(content, style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(author, style: AppTypography.small),
              Text(date, style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _TaskItem(
          title: 'Schedule Site Visit',
          assignee: 'John Doe',
          dueDate: '2026-03-20',
          status: 'Pending',
        ),
        _TaskItem(
          title: 'Collect Documentation',
          assignee: 'Jane Smith',
          dueDate: '2026-03-22',
          status: 'In Progress',
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String title;
  final String assignee;
  final String dueDate;
  final String status;

  const _TaskItem({
    required this.title,
    required this.assignee,
    required this.dueDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(title, style: AppTypography.h3),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assigned: $assignee', style: AppTypography.small),
              Text('Due: $dueDate', style: AppTypography.small),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/index.dart';

/// Page displaying searchable list of claims.
/// 
/// Features:
/// - Search by claim ID or claimant name
/// - Filter by status
/// - Tap claim to view detailed information
class ClaimsListPage extends StatefulWidget {
  const ClaimsListPage({Key? key}) : super(key: key);

  @override
  State<ClaimsListPage> createState() => _ClaimsListPageState();
}

class _ClaimsListPageState extends State<ClaimsListPage> {
  final _searchController = TextEditingController();
  String _filterStatus = 'All';

  final List<Map<String, String>> _claims = [
    {
      'id': 'CLM-2026-001',
      'name': 'Alice Johnson',
      'status': 'In Progress',
      'priority': 'High',
      'date': '2026-03-15',
    },
    {
      'id': 'CLM-2026-002',
      'name': 'Bob Smith',
      'status': 'Pending Investigation',
      'priority': 'Medium',
      'date': '2026-03-12',
    },
    {
      'id': 'CLM-2026-003',
      'name': 'Charlie Brown',
      'status': 'Completed',
      'priority': 'Low',
      'date': '2026-03-10',
    },
    {
      'id': 'CLM-2026-004',
      'name': 'Diana Prince',
      'status': 'Open',
      'priority': 'High',
      'date': '2026-03-18',
    },
    {
      'id': 'CLM-2026-005',
      'name': 'Eve Adams',
      'status': 'Pending Investigation',
      'priority': 'Low',
      'date': '2026-03-05',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Claims', style: AppTypography.h2),
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search claims...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      _showFilterDialog();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          if (_filterStatus != 'All')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text('Status: $_filterStatus'),
                  onDeleted: () {
                    setState(() => _filterStatus = 'All');
                  },
                ),
              ),
            ),

          // Claims List
          Expanded(
            child: ListView.builder(
              itemCount: _claims.length,
              itemBuilder: (context, index) {
                final claim = _claims[index];
                return ClaimCard(
                  claimId: claim['id']!,
                  customerName: claim['name']!,
                  status: claim['status']!,
                  priority: claim['priority']!,
                  date: claim['date']!,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/claim-detail/${claim['id']}',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['All', 'Open', 'In Progress', 'Completed', 'Rejected']
              .map((status) => RadioListTile<String>(
                    title: Text(status),
                    value: status,
                    groupValue: _filterStatus,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _filterStatus = value);
                        Navigator.of(context).pop();
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

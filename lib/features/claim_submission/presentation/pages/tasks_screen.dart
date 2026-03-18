import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/index.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final List<Map<String, String>> _tasks = [
    {
      'id': '1',
      'title': 'Schedule Site Visit',
      'assignee': 'John Doe',
      'dueDate': '2026-03-20',
      'status': 'Pending',
    },
    {
      'id': '2',
      'title': 'Collect Documentation',
      'assignee': 'Jane Smith',
      'dueDate': '2026-03-22',
      'status': 'In Progress',
    },
    {
      'id': '3',
      'title': 'Medical Examination',
      'assignee': 'Bob Johnson',
      'dueDate': '2026-03-25',
      'status': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Tasks', style: AppTypography.h2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: _tasks
            .map((task) => _TaskCard(
                  title: task['title']!,
                  assignee: task['assignee']!,
                  dueDate: task['dueDate']!,
                  status: task['status']!,
                  onTap: () {
                    // Open task details
                  },
                ))
            .toList(),
      ),
      floatingActionButton: AppFloatingActionButton(
        label: 'Add Task',
        icon: Icons.add_task,
        onPressed: () {
          Navigator.of(context).pushNamed('/task/create').then((result) {
            if (result == true) {
              setState(() {
                // Refresh tasks list
              });
            }
          });
        },
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String assignee;
  final String dueDate;
  final String status;
  final VoidCallback onTap;

  const _TaskCard({
    required this.title,
    required this.assignee,
    required this.dueDate,
    required this.status,
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
                Expanded(
                  child: Text(title, style: AppTypography.h3),
                ),
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
      ),
    );
  }
}

class CreateTaskPage extends StatefulWidget {
  final String? claimId;

  const CreateTaskPage({Key? key, this.claimId}) : super(key: key);

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assigneeController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _priorityController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assigneeController.dispose();
    _dueDateController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter task title')),
      );
      return;
    }

    setState(() => _isSaving = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully')),
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
        title: Text('Create Task', style: AppTypography.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppInputField(
              label: 'Task Title',
              hint: 'Enter task title',
              controller: _titleController,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppInputField(
              label: 'Description',
              hint: 'Enter task description',
              controller: _descriptionController,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDropdownField<String>(
              label: 'Assign To',
              items: [
                'John Doe',
                'Jane Smith',
                'Bob Johnson',
                'Alice Williams',
              ]
                  .map((person) => DropdownMenuItem(value: person, child: Text(person)))
                  .toList(),
              onChanged: (value) {
                _assigneeController.text = value ?? '';
              },
              hint: 'Select assignee',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppInputField(
              label: 'Due Date',
              hint: 'Select due date',
              controller: _dueDateController,
              onChanged: (value) {
                // Show date picker
              },
              prefixIcon: const Icon(Icons.calendar_today),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppDropdownField<String>(
              label: 'Priority',
              items: ['High', 'Medium', 'Low']
                  .map((priority) => DropdownMenuItem(value: priority, child: Text(priority)))
                  .toList(),
              onChanged: (value) {
                _priorityController.text = value ?? '';
              },
              hint: 'Select priority',
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Create Task',
                    isLoading: _isSaving,
                    onPressed: _handleSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

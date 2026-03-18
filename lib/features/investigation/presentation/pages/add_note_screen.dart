import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/index.dart';

class AddNotePage extends StatefulWidget {
  final String? claimId;

  const AddNotePage({Key? key, this.claimId}) : super(key: key);

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _noteController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _useVoiceInput = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _noteController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a note')),
      );
      return;
    }

    setState(() => _isSaving = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved successfully')),
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
        title: Text('Add Note', style: AppTypography.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.claimId != null) ...[
              Text('Claim ID', style: AppTypography.label),
              const SizedBox(height: AppSpacing.xs),
              Text(widget.claimId!, style: AppTypography.body),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Category Dropdown
            AppDropdownField<String>(
              label: 'Note Category',
              items: [
                'Investigation',
                'Damage Assessment',
                'Fraud Indicator',
                'General',
              ]
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                _categoryController.text = value ?? '';
              },
              hint: 'Select category',
            ),
            const SizedBox(height: AppSpacing.lg),

            // Text Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Note Content', style: AppTypography.label),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _noteController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    hintText: 'Type your note here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Voice Input Option
            Row(
              children: [
                Checkbox(
                  value: _useVoiceInput,
                  onChanged: (value) {
                    setState(() => _useVoiceInput = value ?? false);
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Add voice note',
                  style: AppTypography.body,
                ),
              ],
            ),

            if (_useVoiceInput) ...[
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mic,
                        size: AppSpacing.iconLarge,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Recording...',
                        style: AppTypography.body.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Buttons
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
                    label: 'Save Note',
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

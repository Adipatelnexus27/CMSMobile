import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/index.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({Key? key}) : super(key: key);

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  final _complaintTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _complaintTypeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File selected: complaint_doc.pdf')),
    );
    setState(() => _selectedFile = 'complaint_doc.pdf');
  }

  void _handleSubmit() {
    if (_complaintTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select complaint type')),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your complaint')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully')),
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
        title: Text('File Complaint', style: AppTypography.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Complaint Type
            AppDropdownField<String>(
              label: 'Complaint Type',
              items: [
                'Claim Decision',
                'Service Quality',
                'Documentation',
                'Processing Delay',
                'Other',
              ]
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                _complaintTypeController.text = value ?? '';
              },
              hint: 'Select complaint type',
            ),
            const SizedBox(height: AppSpacing.lg),

            // Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description', style: AppTypography.label),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _descriptionController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Describe your complaint in detail...',
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

            // File Attachment
            Text('Attach Evidence (Optional)', style: AppTypography.label),
            const SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: _selectFile,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedFile != null ? AppColors.success : AppColors.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  color: _selectedFile != null
                      ? AppColors.success.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null ? Icons.check_circle : Icons.attach_file,
                      color: _selectedFile != null ? AppColors.success : AppColors.textSecondary,
                      size: AppSpacing.iconLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _selectedFile ?? 'Tap to attach file',
                      style: AppTypography.body.copyWith(
                        color: _selectedFile != null
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

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
                    label: 'Submit',
                    isLoading: _isSubmitting,
                    onPressed: _handleSubmit,
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

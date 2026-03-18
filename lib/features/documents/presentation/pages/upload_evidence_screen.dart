import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/index.dart';

class UploadEvidencePage extends StatefulWidget {
  final String? claimId;

  const UploadEvidencePage({Key? key, this.claimId}) : super(key: key);

  @override
  State<UploadEvidencePage> createState() => _UploadEvidencePageState();
}

class _UploadEvidencePageState extends State<UploadEvidencePage> {
  final _documentTypeController = TextEditingController();
  String? _selectedFile;
  bool _isUploading = false;

  @override
  void dispose() {
    _documentTypeController.dispose();
    super.dispose();
  }

  void _selectFile() {
    // File picker logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File selected: claim_photo.jpg')),
    );
    setState(() => _selectedFile = 'claim_photo.jpg');
  }

  void _handleUpload() {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }

    if (_documentTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select document type')),
      );
      return;
    }

    setState(() => _isUploading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isUploading = false);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evidence uploaded successfully')),
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
        title: Text('Upload Evidence', style: AppTypography.h2),
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

            // Document Type Dropdown
            AppDropdownField<String>(
              label: 'Document Type',
              items: [
                'Photo',
                'Video',
                'Receipt',
                'Police Report',
                'Medical Report',
                'Other',
              ]
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                _documentTypeController.text = value ?? '';
              },
              hint: 'Select document type',
            ),
            const SizedBox(height: AppSpacing.lg),

            // File Selection
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                color: AppColors.primaryLight,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: AppSpacing.iconLarge,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Select File',
                    style: AppTypography.h3.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tap to browse and select file',
                    style: AppTypography.small.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _selectFile,
                    child: const Text('Browse Files'),
                  ),
                ],
              ),
            ),

            if (_selectedFile != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.success),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: AppSpacing.iconLarge,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('File Selected', style: AppTypography.label),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(_selectedFile!, style: AppTypography.small),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Info Box
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
                    Icons.info,
                    color: AppColors.info,
                    size: AppSpacing.iconMedium,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Supported formats: JPG, PNG, PDF, MP4',
                      style: AppTypography.small.copyWith(color: AppColors.info),
                    ),
                  ),
                ],
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
                    label: 'Upload',
                    isLoading: _isUploading,
                    onPressed: _handleUpload,
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

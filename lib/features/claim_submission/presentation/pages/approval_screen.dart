import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/index.dart';

class ApprovalPage extends StatefulWidget {
  final String? claimId;

  const ApprovalPage({Key? key, this.claimId}) : super(key: key);

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  final _commentsController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _handleApprove() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim approved successfully')),
        );
      }
    });
  }

  void _handleReject() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim rejected')),
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
        title: Text('Approve Claim', style: AppTypography.h2),
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

            // Claim Summary
            Text('Claim Summary', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            _SummaryItem('Policy Holder', 'John Doe'),
            _SummaryItem('Claim Amount', '\$5,000.00'),
            _SummaryItem('Policy Number', 'POL-2025-12345'),
            _SummaryItem('Incident Date', '2026-03-10'),
            _SummaryItem('Investigation Status', 'Completed'),
            _SummaryItem('Fraud Check', 'No flags'),

            const SizedBox(height: AppSpacing.lg),

            // Comments
            Text('Review Comments', style: AppTypography.label),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _commentsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add any comments for your decision...',
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

            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            AppButton(
              label: 'Approve Claim',
              isLoading: _isProcessing,
              onPressed: _handleApprove,
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Reject Claim',
              onPressed: _handleReject,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: Center(child: Text('Return for Review')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _SummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(value, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

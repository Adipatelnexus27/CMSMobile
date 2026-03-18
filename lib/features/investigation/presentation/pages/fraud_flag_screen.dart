import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/index.dart';

class FraudFlagPage extends StatefulWidget {
  final String? claimId;

  const FraudFlagPage({Key? key, this.claimId}) : super(key: key);

  @override
  State<FraudFlagPage> createState() => _FraudFlagPageState();
}

class _FraudFlagPageState extends State<FraudFlagPage> {
  final List<String> _fraudIndicators = [
    'Inconsistent statements',
    'Multiple claims in short period',
    'Staged accident indicators',
    'Excess claim amount',
    'Delayed claim submission',
  ];

  final List<bool> _selectedIndicators = [false, false, false, false, false];
  final _commentsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _handleFlagClaim() {
    final anySelected = _selectedIndicators.any((element) => element);
    if (!anySelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one fraud indicator')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim flagged for fraud review')),
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
        title: Text('Flag as Fraud', style: AppTypography.h2),
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

            // Warning Box
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.fraudFlag.withOpacity(0.1),
                border: Border.all(color: AppColors.fraudFlag),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_rounded,
                    color: AppColors.fraudFlag,
                    size: AppSpacing.iconLarge,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'This claim will be flagged for fraud review. Ensure all evidence is documented.',
                      style: AppTypography.small.copyWith(color: AppColors.fraudFlag),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Fraud Indicators Checklist
            Text('Fraud Indicators', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            ..._buildFraudChecklist(),

            const SizedBox(height: AppSpacing.lg),

            // Comments
            Text('Additional Comments', style: AppTypography.label),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _commentsController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Provide details about your suspicion...',
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
                  child: DangerButton(
                    label: 'Flag Claim',
                    isLoading: _isSubmitting,
                    onPressed: _handleFlagClaim,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFraudChecklist() {
    return List.generate(_fraudIndicators.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: CheckboxListTile(
          value: _selectedIndicators[index],
          onChanged: (value) {
            setState(() {
              _selectedIndicators[index] = value ?? false;
            });
          },
          title: Text(_fraudIndicators[index], style: AppTypography.body),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      );
    });
  }
}

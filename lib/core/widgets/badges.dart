import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;

  const StatusBadge({
    Key? key,
    required this.status,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? _getStatusColor();
    final txtColor = textColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
      child: Text(
        status,
        style: AppTypography.caption.copyWith(color: txtColor),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'open':
        return AppColors.warning;
      case 'approved':
      case 'completed':
      case 'closed':
        return AppColors.success;
      case 'rejected':
      case 'denied':
        return AppColors.error;
      case 'in progress':
      case 'investigating':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({
    Key? key,
    required this.priority,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor();
    final label = priority.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(color: color),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.highPriority;
      case 'medium':
        return AppColors.mediumPriority;
      case 'low':
        return AppColors.lowPriority;
      default:
        return AppColors.textSecondary;
    }
  }
}

class FraudBadge extends StatelessWidget {
  final String label;
  final bool isFraud;

  const FraudBadge({
    Key? key,
    this.label = 'FRAUD FLAG',
    this.isFraud = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isFraud ? AppColors.fraudFlag.withOpacity(0.15) : AppColors.suspicious.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(
          color: isFraud ? AppColors.fraudFlag : AppColors.suspicious,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_rounded,
            size: AppSpacing.iconSmall,
            color: isFraud ? AppColors.fraudFlag : AppColors.suspicious,
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isFraud ? AppColors.fraudFlag : AppColors.suspicious,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

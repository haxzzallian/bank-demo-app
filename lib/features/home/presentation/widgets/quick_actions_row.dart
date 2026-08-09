import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    this.onDeposit,
    this.onWithdraw,
    this.onTransfer,
  });

  final VoidCallback? onDeposit;
  final VoidCallback? onWithdraw;
  final VoidCallback? onTransfer;

  static const _actions = [
    _QuickAction(
      label: 'Deposit',
      icon: Icons.south_west_rounded,
      color: AppColors.success,
    ),
    _QuickAction(
      label: 'Withdraw',
      icon: Icons.north_east_rounded,
      color: AppColors.error,
    ),
    _QuickAction(
      label: 'Transfer',
      icon: Icons.sync_alt_rounded,
      color: AppColors.secondary,
    ),
    _QuickAction(
      label: 'History',
      icon: Icons.receipt_long_rounded,
      color: AppColors.primary,
    ),
  ];

  void _onTap(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label is coming soon')));
  }

  VoidCallback? _overrideFor(String label) {
    switch (label) {
      case 'Deposit':
        return onDeposit;
      case 'Withdraw':
        return onWithdraw;
      case 'Transfer':
        return onTransfer;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final action in _actions)
            _ActionButton(
              action: action,
              onTap:
                  _overrideFor(action.label) ??
                  () => _onTap(context, action.label),
            ),
        ],
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action, required this.onTap});

  final _QuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(action.icon, color: action.color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.phoneNumber,
    required this.isRefreshing,
    required this.onRefresh,
  });

  final double? balance;
  final String? phoneNumber;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _hidden = false;

  void _copyAccountNumber() {
    final phoneNumber = widget.phoneNumber;
    if (phoneNumber == null) return;
    Clipboard.setData(ClipboardData(text: phoneNumber));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Account number copied')));
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.balance;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.32),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -30, top: -40, child: _decorativeRing(140)),
          Positioned(left: -20, bottom: -50, child: _decorativeRing(120)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Balance',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Row(
                    children: [
                      _iconButton(
                        icon: _hidden
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        onTap: () => setState(() => _hidden = !_hidden),
                        semanticLabel: _hidden
                            ? 'Show balance'
                            : 'Hide balance',
                      ),
                      const SizedBox(width: 8),
                      _iconButton(
                        icon: Icons.refresh_rounded,
                        onTap: widget.onRefresh,
                        spinning: widget.isRefreshing,
                        semanticLabel: 'Refresh balance',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (balance == null)
                Text(
                  '₦ — — — —',
                  style: AppTextStyles.brand.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                  ),
                )
              else if (_hidden)
                Text(
                  '₦ • • • • • •',
                  style: AppTextStyles.brand.copyWith(
                    color: Colors.white,
                    fontSize: 36,
                    letterSpacing: 2,
                  ),
                )
              else
                TweenAnimationBuilder<double>(
                  key: ValueKey(balance),
                  tween: Tween(begin: 0, end: balance),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Text(
                    CurrencyFormatter.formatWhole(value),
                    style: AppTextStyles.brand.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Tooltip(
                message: 'Copy account number',
                child: GestureDetector(
                  onTap: _copyAccountNumber,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.account_balance_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.phoneNumber ?? '—',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.copy_rounded,
                          color: Colors.white70,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _decorativeRing(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 18,
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String semanticLabel,
    bool spinning = false,
  }) {
    // 44x44 minimum tap target per UI_GUIDELINES's "large tap targets" —
    // the icon itself stays visually compact inside it.
    return Tooltip(
      message: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: spinning
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

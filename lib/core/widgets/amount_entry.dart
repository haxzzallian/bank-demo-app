import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency_formatter.dart';

const List<double> kDefaultAmountPresets = [1000, 5000, 10000, 50000];

class AmountEntry extends StatelessWidget {
  const AmountEntry({
    super.key,
    required this.controller,
    required this.onPresetSelected,
    this.presets = kDefaultAmountPresets,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final ValueChanged<double> onPresetSelected;
  final List<double> presets;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: IntrinsicWidth(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.brand.copyWith(fontSize: 44),
              decoration: InputDecoration(
                prefixText: '₦ ',
                prefixStyle: AppTextStyles.brand.copyWith(
                  fontSize: 44,
                  color: AppColors.textSecondary,
                ),
                hintText: '0',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final preset in presets)
              _PresetChip(
                amount: preset,
                onTap: () => onPresetSelected(preset),
              ),
          ],
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.amount, required this.onTap});

  final double amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          CurrencyFormatter.formatWhole(amount),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

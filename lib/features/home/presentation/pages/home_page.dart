import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: AppColors.cta.withAlpha(30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.menu, color: AppColors.cta),
                  ),
                  Text(
                    'BankDump',
                    style: AppTextStyles.brand.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textSecondary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          hintStyle: AppTextStyles.subtitle.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.cta,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cta.withAlpha(64),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Browse Foods',
                    style: AppTextStyles.title.copyWith(
                      color: Colors.black,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _CategoryCard(label: 'Logistics')),
                  const SizedBox(width: 14),
                  Expanded(child: _CategoryCard(label: 'Mall Errands')),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Explore Restaurants',
                style: AppTextStyles.title.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Column(
                children: const [
                  _RestaurantTile(
                    name: 'Dara’s Kitchen',
                    rating: 4.5,
                    eta: '10–15min',
                  ),
                  SizedBox(height: 14),
                  _RestaurantTile(
                    name: 'Dara’s Kitchen',
                    rating: 4.5,
                    eta: '10–15min',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _RestaurantTile extends StatelessWidget {
  const _RestaurantTile({
    required this.name,
    required this.rating,
    required this.eta,
  });

  final String name;
  final double rating;
  final String eta;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.title.copyWith(fontSize: 18)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.cta, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        eta,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:due_guard/core/constants/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onAddPressed;
  final String selectedCategory;

  const EmptyStateWidget({
    super.key,
    required this.onAddPressed,
    this.selectedCategory = 'All',
  });

  @override
  Widget build(BuildContext context) {
    final cfg = _configFor(selectedCategory);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cfg.iconBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(cfg.icon, color: cfg.iconColor, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              cfg.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cfg.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onAddPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: cfg.iconColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  cfg.buttonLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static _Cfg _configFor(String category) {
    switch (category) {
      case 'Medicine':
        return _Cfg(
          icon: Icons.medication_outlined,
          iconColor: AppColors.medicineColor,
          iconBg: AppColors.medicineBg,
          title: 'No medicine items yet',
          subtitle:
              'Add your medicines, vitamins,\nor supplements via the + button.',
          buttonLabel: 'Add Medicine',
        );
      case 'Subscriptions':
        return _Cfg(
          icon: Icons.credit_card_outlined,
          iconColor: AppColors.subscriptionsColor,
          iconBg: AppColors.subscriptionsBg,
          title: 'No subscriptions yet',
          subtitle: 'Track subscriptions and\nrenewals via the + button.',
          buttonLabel: 'Add Subscription',
        );
      case 'Documents':
        return _Cfg(
          icon: Icons.description_outlined,
          iconColor: AppColors.documentsColor,
          iconBg: AppColors.documentsBg,
          title: 'No documents yet',
          subtitle:
              'Track passports, licences,\nand certificates via the + button.',
          buttonLabel: 'Add Document',
        );
      default:
        return _Cfg(
          icon: Icons.inventory_2_outlined,
          iconColor: AppColors.primary,
          iconBg: AppColors.primaryLight,
          title: 'Nothing tracked yet',
          subtitle: 'Tap the + button to start\ntracking your items.',
          buttonLabel: 'Add First Item',
        );
    }
  }
}

class _Cfg {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String buttonLabel;
  const _Cfg({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });
}

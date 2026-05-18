import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:due_guard/core/constants/app_colors.dart';
import 'package:due_guard/core/utils/date_helper.dart';
import 'package:due_guard/features/dueguard/data/models/item_model.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  String get _expiryLabel {
    final date = DateHelper.format(item.expiryDate);
    switch (item.category) {
      case ItemCategory.electronics:
        return 'Warranty expires $date';
      case ItemCategory.medicine:
        return 'Use by $date';
      case ItemCategory.cosmetics:
        return 'Best before $date';
      case ItemCategory.subscriptions:
        return 'Renews $date';
      case ItemCategory.documents:
        return 'Valid until $date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = item.status;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _buildLeadingImage(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _expiryLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _StatusBadge(status: status),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingImage() {
    if (item.imageUrl.isEmpty) return _categoryIconBox();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 52,
        height: 52,
        child: Image.network(
          item.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _categoryIconBox(),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _categoryIconBox();
          },
        ),
      ),
    );
  }

  Widget _categoryIconBox() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: item.category.bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(item.category.icon, color: item.category.color, size: 24),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ItemStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: status.bgColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

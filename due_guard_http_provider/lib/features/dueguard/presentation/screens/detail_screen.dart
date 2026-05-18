import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_helper.dart';
import '../../data/models/item_model.dart';
import '../provider/item_provider.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatelessWidget {
  final ItemModel item;
  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final days = item.daysRemaining;
    final status = item.status;
    int step = days < 0 ? 3 : (days <= 30 ? 2 : 1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroHeader(),
                    const SizedBox(height: 32),
                    _buildExpiryOverview(days, status),
                    const SizedBox(height: 32),
                    _buildSectionTitle(AppStrings.itemInformation),
                    const SizedBox(height: 14),
                    _buildInfoGrid(),
                    const SizedBox(height: 32),
                    _buildSectionTitle(AppStrings.lifecycle),
                    const SizedBox(height: 20),
                    _buildLifecycleTrack(step),
                    const SizedBox(height: 48),
                    _buildDeleteButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navBtn(Icons.chevron_left_rounded, () => Navigator.pop(context)),
          // Fixed: use push instead of pushReplacement so Back from
          // AddEditScreen returns here, not to Home.
          _navBtn(Icons.edit_rounded, () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEditScreen(item: item)),
            );
            if (context.mounted) Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: item.category.bgColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              image: item.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: item.imageUrl.isEmpty
                ? Icon(item.category.icon, color: item.category.color, size: 36)
                : null,
          ),
          const SizedBox(height: 20),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: item.status.bgColor.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              item.status.label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: item.status.color,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryOverview(int days, ItemStatus status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days < 0 ? 'STATUS' : _expiryTermFor(item.category),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: days < 0 ? '${days.abs()}' : '$days',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: status.color,
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: days < 0 ? ' days ago' : ' days',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.category == ItemCategory.electronics
                    ? 'WARRANTY EXPIRY'
                    : item.category == ItemCategory.subscriptions
                    ? 'RENEWAL DATE'
                    : 'DUE DATE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateHelper.format(item.expiryDate),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _weekdayName(item.expiryDate.weekday),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary.withValues(alpha: 0.6),
        letterSpacing: 1.5,
      ),
    );
  }

  // Fixed: removed unused `days` and `status` params
  Widget _buildInfoGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _infoRow('Category', item.category.label),
          _divider(),
          _infoRow('Purchase Date', DateHelper.format(item.purchaseDate)),
          _divider(),
          _infoRow(
            'Item ID',
            '#${item.id.length > 4 ? item.id.substring(item.id.length - 4) : item.id.padLeft(4, '0')}',
          ),
          if (item.notes.isNotEmpty) ...[
            _divider(),
            _infoRow('Notes', item.notes),
          ],
        ],
      ),
    );
  }

  Widget _buildLifecycleTrack(int current) {
    final stages = ['Purchased', 'Active', 'Expiring', 'Expired'];
    final colors = [
      AppColors.primary,
      AppColors.primary,
      AppColors.soon,
      AppColors.urgent,
    ];
    return Row(
      children: List.generate(stages.length, (i) {
        final isCompleted = i <= current;
        final isCurrent = i == current;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i > 0 && isCompleted
                          ? colors[i]
                          : AppColors.border,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted ? colors[i] : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? colors[i] : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: i < stages.length - 1 && i < current
                          ? colors[i + 1]
                          : AppColors.border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                stages[i],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isCompleted ? colors[i] : AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: () => _showDeleteConfirm(context),
          icon: const Icon(
            Icons.delete_outline_rounded,
            size: 20,
            color: AppColors.urgentText,
          ),
          label: Text(
            'Delete Item',
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.urgentText,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.urgentText, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 24, color: AppColors.textPrimary),
    ),
  );

  // Fixed: removed unused isFirst and isLast params
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
    height: 1,
    color: AppColors.border.withValues(alpha: 0.5),
    margin: const EdgeInsets.symmetric(horizontal: 20),
  );

  String _expiryTermFor(ItemCategory category) {
    switch (category) {
      case ItemCategory.electronics:
        return 'WARRANTY REMAINING';
      case ItemCategory.medicine:
        return 'USE BY';
      case ItemCategory.cosmetics:
        return 'BEST BEFORE';
      case ItemCategory.subscriptions:
        return 'RENEWS IN';
      case ItemCategory.documents:
        return 'VALID FOR';
    }
  }

  String _weekdayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[(weekday - 1).clamp(0, 6)];
  }

  void _showDeleteConfirm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _DeleteSheet(itemId: item.id),
    );
  }
}

class _DeleteSheet extends StatefulWidget {
  final String itemId;
  const _DeleteSheet({required this.itemId});

  @override
  State<_DeleteSheet> createState() => _DeleteSheetState();
}

class _DeleteSheetState extends State<_DeleteSheet> {
  bool _isDeleting = false;

  Future<void> _doDelete() async {
    setState(() => _isDeleting = true);
    final provider = context.read<ItemProvider>();
    final success = await provider.deleteItem(widget.itemId);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context); // close sheet
      Navigator.pop(context); // close detail screen
    } else {
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage.isNotEmpty
                ? provider.errorMessage
                : 'Failed to delete. Please try again.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.urgentText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Delete Permanently?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This action cannot be undone. Are you sure?',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _isDeleting ? null : _doDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.urgent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.urgent.withValues(
                  alpha: 0.6,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isDeleting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Delete Now',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: TextButton(
              onPressed: _isDeleting ? null : () => Navigator.pop(context),
              child: Text(
                'Keep Item',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

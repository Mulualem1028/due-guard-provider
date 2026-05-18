import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/item_model.dart';
import '../provider/item_provider.dart';
import '../widgets/donut_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ItemProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              sliver: SliverToBoxAdapter(child: _buildGrid(p)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              sliver: SliverToBoxAdapter(child: _buildExpiryCard(p)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: SliverToBoxAdapter(child: _buildCategoryCard(p)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('OVERVIEW',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: AppColors.primary, letterSpacing: 2.0)),
            const SizedBox(height: 4),
            Text('Insights',
              style: GoogleFonts.playfairDisplay(
                fontSize: 36, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary, height: 1.0)),
          ]),
        ],
      ),
    );
  }

  // 2×2 grid matching image exactly
  Widget _buildGrid(ItemProvider p) {
    return Column(children: [
      Row(children: [
        _statCard('TOTAL ITEMS', '${p.totalCount}', AppColors.textPrimary,
            Colors.white, border: true),
        const SizedBox(width: 12),
        _statCard('EXPIRING SOON', '${p.expiringSoonCount}',
            AppColors.soonText, AppColors.statSoonBg),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        _statCard('EXPIRED', '${p.expiredCount}',
            AppColors.urgentText, AppColors.statExpiredBg),
        const SizedBox(width: 12),
        _statCard('SAFE ITEMS', '${p.safeCount}',
            AppColors.safeText, AppColors.statSafeBg),
      ]),
    ]);
  }

  Widget _statCard(String label, String value, Color valueColor, Color bg,
      {bool border = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: border ? Border.all(color: AppColors.border) : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10, fontWeight: FontWeight.w700,
              color: AppColors.textSecondary, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Text(value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32, fontWeight: FontWeight.w800,
              color: valueColor, height: 1)),
        ]),
      ),
    );
  }

  Widget _buildExpiryCard(ItemProvider p) {
    final total = p.totalCount;
    double pct(int v) => total > 0 ? v / total * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Expiry Status',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 20),
        Row(children: [
          DonutChart(
            size: 120,
            values: [
              p.safeCount.toDouble(),
              p.expiringSoonCount.toDouble(),
              p.expiredCount.toDouble(),
            ],
            colors: [AppColors.primary, AppColors.soon, AppColors.urgent],
            centerChild: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${p.totalCount}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary, height: 1)),
              Text('TOTAL',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9, fontWeight: FontWeight.w700,
                  color: AppColors.textMuted, letterSpacing: 1)),
            ]),
          ),
          const SizedBox(width: 28),
          Expanded(child: Column(children: [
            _legendRow(AppColors.primary, 'Safe',
                '${p.safeCount} (${pct(p.safeCount).toStringAsFixed(0)}%)'),
            const SizedBox(height: 14),
            _legendRow(AppColors.soon, 'Expiring Soon',
                '${p.expiringSoonCount} (${pct(p.expiringSoonCount).toStringAsFixed(0)}%)'),
            const SizedBox(height: 14),
            _legendRow(AppColors.urgent, 'Expired',
                '${p.expiredCount} (${pct(p.expiredCount).toStringAsFixed(0)}%)'),
          ])),
        ]),
      ]),
    );
  }

  Widget _legendRow(Color color, String label, String value) {
    return Row(children: [
      Container(width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Text(label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
      Text(value,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ]);
  }

  Widget _buildCategoryCard(ItemProvider p) {
    final cats = ItemCategory.values.toList()
      ..sort((a, b) => p.countByCategory(b).compareTo(p.countByCategory(a)));
    // clamp to 1.0 so we never divide by zero even if every category is empty
    final maxCount = cats.isNotEmpty
        ? p.countByCategory(cats.first).toDouble().clamp(1.0, double.infinity)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Top Categories',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        ...cats.map((cat) {
          final count = p.countByCategory(cat);
          final fraction = maxCount > 0 ? count / maxCount : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: cat.bgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(cat.icon, color: cat.color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(cat.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w700, color: cat.color)),
                  Text('$count Items',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 6),
                Stack(children: [
                  Container(height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                  FractionallySizedBox(widthFactor: fraction,
                    child: Container(height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary, borderRadius: BorderRadius.circular(2)))),
                ]),
              ])),
            ]),
          );
        }),
      ]),
    );
  }
}

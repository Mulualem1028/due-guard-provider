import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:due_guard/core/constants/app_colors.dart';
import 'package:due_guard/core/constants/app_strings.dart';
import 'package:due_guard/core/utils/date_helper.dart';
import 'package:due_guard/features/dueguard/data/mock/mock_profile.dart';
import 'package:due_guard/features/dueguard/presentation/provider/item_provider.dart';
import 'package:due_guard/features/dueguard/data/models/item_model.dart';
import 'package:due_guard/features/dueguard/presentation/widgets/category_chip_widget.dart';
import 'package:due_guard/features/dueguard/presentation/widgets/item_card.dart';
import 'package:due_guard/features/dueguard/presentation/widgets/empty_state_widget.dart';
import 'package:due_guard/features/dueguard/presentation/widgets/shimmer_widget.dart';
import 'package:due_guard/features/dueguard/presentation/widgets/offline_banner.dart';
import 'detail_screen.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  static const _cats = [
    'All',
    'Medicine',
    'Cosmetics',
    'Electronics',
    'Subscriptions',
    'Documents',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ItemProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: _buildBody(p)),
    );
  }

  Widget _buildBody(ItemProvider p) {
    if (p.loadState == LoadState.loading) return _buildSkeleton();
    if (p.loadState == LoadState.error) return _buildError(p);

    final items = p.filteredItems;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(p)),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(child: _buildSearchBar(p)),
        ),

        SliverToBoxAdapter(child: _buildChips(p)),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          sliver: SliverToBoxAdapter(child: _buildSectionRow(items.length)),
        ),

        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              selectedCategory: p.selectedCategory,
              onAddPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditScreen(
                    preselectedCategory: p.selectedCategory != 'All'
                        ? _categoryFromLabel(p.selectedCategory)
                        : null,
                  ),
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => ItemCard(
                  item: items[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(item: items[i]),
                    ),
                  ),
                ),
                childCount: items.length,
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  ItemCategory? _categoryFromLabel(String label) {
    for (final cat in ItemCategory.values) {
      if (cat.label == label) return cat;
    }
    return null;
  }

  Widget _buildHeader(ItemProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + greeting row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateHelper.getGreeting(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    MockProfile.userName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Hero title
          Text(
            "What's expiring?",
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
          // Offline banner (non-blocking)
          if (p.errorMessage.isNotEmpty) ...[
            const SizedBox(height: 10),
            OfflineBanner(message: p.errorMessage),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(ItemProvider p) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: p.setSearchQuery,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildChips(ItemProvider p) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        itemCount: _cats.length,
        itemBuilder: (_, i) {
          final sel = p.selectedCategory == _cats[i];
          return CategoryChipWidget(
            label: _cats[i],
            isSelected: sel,
            onTap: () => p.setCategory(_cats[i]),
          );
        },
      ),
    );
  }

  Widget _buildSectionRow(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your items',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '$count tracked',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildError(ItemProvider p) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.somethingWentWrong,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: p.retry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                AppStrings.retry,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          ShimmerWidget(width: 160, height: 16),
          const SizedBox(height: 12),
          ShimmerWidget(width: 220, height: 36),
          const SizedBox(height: 24),
          ShimmerWidget(height: 48),
          const SizedBox(height: 16),
          for (int i = 0; i < 5; i++) ...[
            _skeletonCard(),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _skeletonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ShimmerWidget(width: 52, height: 52, radius: 14),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerWidget(height: 14),
                const SizedBox(height: 6),
                ShimmerWidget(width: 120, height: 11),
                const SizedBox(height: 4),
                ShimmerWidget(width: 100, height: 11),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ShimmerWidget(width: 56, height: 28, radius: 50),
        ],
      ),
    );
  }
}

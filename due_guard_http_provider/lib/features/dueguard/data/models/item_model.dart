import 'dart:math';
import 'package:flutter/material.dart';
import 'package:due_guard/core/constants/app_colors.dart';
import 'package:due_guard/core/utils/date_helper.dart';

enum ItemCategory { medicine, cosmetics, electronics, subscriptions, documents }

enum ItemStatus { safe, soon, urgent, expired }

extension ItemCategoryExt on ItemCategory {
  String get label {
    switch (this) {
      case ItemCategory.medicine:
        return 'Medicine';
      case ItemCategory.cosmetics:
        return 'Cosmetics';
      case ItemCategory.electronics:
        return 'Electronics';
      case ItemCategory.subscriptions:
        return 'Subscriptions';
      case ItemCategory.documents:
        return 'Documents';
    }
  }

  IconData get icon {
    switch (this) {
      case ItemCategory.medicine:
        return Icons.medication_rounded;
      case ItemCategory.cosmetics:
        return Icons.auto_awesome_rounded;
      case ItemCategory.electronics:
        return Icons.laptop_rounded;
      case ItemCategory.subscriptions:
        return Icons.credit_card_rounded;
      case ItemCategory.documents:
        return Icons.description_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ItemCategory.medicine:
        return AppColors.medicineColor;
      case ItemCategory.cosmetics:
        return AppColors.cosmeticsColor;
      case ItemCategory.electronics:
        return AppColors.electronicsColor;
      case ItemCategory.subscriptions:
        return AppColors.subscriptionsColor;
      case ItemCategory.documents:
        return AppColors.documentsColor;
    }
  }

  Color get bgColor {
    switch (this) {
      case ItemCategory.medicine:
        return AppColors.medicineBg;
      case ItemCategory.cosmetics:
        return AppColors.cosmeticsBg;
      case ItemCategory.electronics:
        return AppColors.electronicsBg;
      case ItemCategory.subscriptions:
        return AppColors.subscriptionsBg;
      case ItemCategory.documents:
        return AppColors.documentsBg;
    }
  }

  int get _expiryWindowDays {
    switch (this) {
      case ItemCategory.electronics:
        return 730;
      case ItemCategory.medicine:
        return 365;
      case ItemCategory.cosmetics:
        return 400;
      case ItemCategory.subscriptions:
        return 365;
      case ItemCategory.documents:
        return 1825;
    }
  }
}

extension ItemStatusExt on ItemStatus {
  String get label {
    switch (this) {
      case ItemStatus.safe:
        return 'Safe';
      case ItemStatus.soon:
        return 'Soon';
      case ItemStatus.urgent:
        return 'Urgent';
      case ItemStatus.expired:
        return 'Expired';
    }
  }

  Color get color {
    switch (this) {
      case ItemStatus.safe:
        return AppColors.safeText;
      case ItemStatus.soon:
        return AppColors.soonText;
      case ItemStatus.urgent:
        return AppColors.urgentText;
      case ItemStatus.expired:
        return AppColors.expiredText;
    }
  }

  Color get bgColor {
    switch (this) {
      case ItemStatus.safe:
        return AppColors.safeBg;
      case ItemStatus.soon:
        return AppColors.soonBg;
      case ItemStatus.urgent:
        return AppColors.urgentBg;
      case ItemStatus.expired:
        return AppColors.expiredBg;
    }
  }
}

class ItemModel {
  final String id;
  final String name;
  final ItemCategory category;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final String imageUrl;
  final String notes;

  const ItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.purchaseDate,
    required this.expiryDate,
    required this.imageUrl,
    this.notes = '',
  });

  int get daysRemaining => DateHelper.daysRemaining(expiryDate);

  ItemStatus get status {
    final days = daysRemaining;
    if (days < 0) return ItemStatus.expired;
    if (days <= 7) return ItemStatus.urgent;
    if (days <= 30) return ItemStatus.soon;
    return ItemStatus.safe;
  }

  factory ItemModel.fromJson(
    Map<String, dynamic> json, {
    required ItemCategory forcedCategory,
  }) {
    final random = Random();
    final now = DateTime.now();

    final purchaseDate = now.subtract(Duration(days: 30 + random.nextInt(700)));

    final window = forcedCategory._expiryWindowDays;
    final expiryOffset = -90 + random.nextInt(window + 90);
    final expiryDate = now.add(Duration(days: expiryOffset));

    return ItemModel(
      id: json['id']?.toString() ?? '0',
      name: json['title'] as String? ?? 'Unknown Item',
      category: forcedCategory,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      imageUrl: json['thumbnail'] as String? ?? '',
      notes: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'title': name,
    'category': category.label.toLowerCase(),
    'description': notes,
    'thumbnail': imageUrl,
  };

  ItemModel copyWith({
    String? id,
    String? name,
    ItemCategory? category,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? imageUrl,
    String? notes,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
    );
  }
}

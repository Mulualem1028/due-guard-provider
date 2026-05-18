import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_helper.dart';
import '../../data/models/item_model.dart';
import '../provider/item_provider.dart';

class AddEditScreen extends StatefulWidget {
  final ItemModel? item;
  final ItemCategory? preselectedCategory;
  const AddEditScreen({super.key, this.item, this.preselectedCategory});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController(); // ← NEW

  ItemCategory _category = ItemCategory.medicine;
  DateTime? _purchaseDate;
  DateTime? _expiryDate;
  bool _isSaving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final i = widget.item!;
      _nameCtrl.text = i.name;
      _notesCtrl.text = i.notes;
      _imageUrlCtrl.text = i.imageUrl; // ← NEW
      _category = i.category;
      _purchaseDate = i.purchaseDate;
      _expiryDate = i.expiryDate;
    } else if (widget.preselectedCategory != null) {
      _category = widget.preselectedCategory!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _imageUrlCtrl.dispose(); // ← NEW
    super.dispose();
  }

  Future<void> _pickDate(bool isPurchase) async {
    final initial = isPurchase
        ? (_purchaseDate ?? DateTime.now())
        : (_expiryDate ?? DateTime.now().add(const Duration(days: 365)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isPurchase) {
          _purchaseDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_purchaseDate == null || _expiryDate == null) {
      _showError('Please select both purchase and expiry dates.');
      return;
    }
    if (_expiryDate!.isBefore(_purchaseDate!)) {
      _showError('Expiry date cannot be before purchase date.');
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<ItemProvider>();

    try {
      final bool success;
      if (_isEdit) {
        success = await provider.updateItem(
          widget.item!.copyWith(
            name: _nameCtrl.text.trim(),
            category: _category,
            purchaseDate: _purchaseDate,
            expiryDate: _expiryDate,
            imageUrl: _imageUrlCtrl.text.trim(),
            notes: _notesCtrl.text.trim(),
          ),
        );
      } else {
        success = await provider.addItem(
          ItemModel(
            id: provider.generateId(),
            name: _nameCtrl.text.trim(),
            category: _category,
            purchaseDate: _purchaseDate!,
            expiryDate: _expiryDate!,
            imageUrl: _imageUrlCtrl.text.trim(),
            notes: _notesCtrl.text.trim(),
          ),
        );
      }

      if (mounted) {
        if (!success) {
          _showError(
            provider.errorMessage.isNotEmpty
                ? provider.errorMessage
                : AppStrings.somethingWentWrong,
          );
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) _showError('An unexpected error occurred.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.urgentText,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  children: [
                    _label('Item Name'),
                    const SizedBox(height: 8),
                    _nameField(),
                    const SizedBox(height: 24),
                    _label('Category'),
                    const SizedBox(height: 12),
                    _categoryGrid(),
                    const SizedBox(height: 24),
                    _buildDateRow(),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        _label('Image URL'),
                        const SizedBox(width: 6),
                        Text(
                          '(Optional)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _imageUrlField(),
                    const SizedBox(height: 12),
                    _imagePreview(),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _label('Notes'),
                        const SizedBox(width: 6),
                        Text(
                          '(Optional)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _notesField(),
                    const SizedBox(height: 32),
                    _saveButton(),
                    const SizedBox(height: 12),
                    _cancelButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  size: 26,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Text(
            _isEdit ? 'Edit Item' : 'Add New Item',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );

  Widget _nameField() => TextFormField(
    controller: _nameCtrl,
    validator: (v) =>
        (v == null || v.trim().isEmpty) ? 'Name is required' : null,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      color: AppColors.textPrimary,
    ),
    decoration: _inputDecor('e.g. Vitamin C Serum'),
  );

  Widget _imageUrlField() => TextFormField(
    controller: _imageUrlCtrl,
    onChanged: (_) => setState(() {}),
    keyboardType: TextInputType.url,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      color: AppColors.textPrimary,
    ),
    decoration: _inputDecor('https://example.com/image.jpg'),
  );

  Widget _imagePreview() {
    final url = _imageUrlCtrl.text.trim();
    final hasUrl = url.isNotEmpty;

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: hasUrl
            ? Colors.transparent
            : _category.bgColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: hasUrl
          ? ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,

                errorBuilder: (_, _, _) => _iconFallback(),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  );
                },
              ),
            )
          : _iconFallback(),
    );
  }

  Widget _iconFallback() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_category.icon, color: _category.color, size: 32),
        const SizedBox(height: 6),
        Text(
          _imageUrlCtrl.text.trim().isEmpty
              ? 'Category icon will be shown'
              : 'Could not load image — icon will be used',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _categoryGrid() {
    final cats = ItemCategory.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: cats.length,
      itemBuilder: (_, i) {
        final cat = cats[i];
        final sel = _category == cat;
        return GestureDetector(
          onTap: () => setState(() => _category = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: sel ? cat.bgColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sel ? cat.color : AppColors.border,
                width: sel ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat.icon,
                  color: sel ? cat.color : AppColors.textSecondary,
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  cat.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel ? cat.color : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Purchase Date'),
              const SizedBox(height: 8),
              _dateBox(_purchaseDate, () => _pickDate(true)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Expiry Date'),
              const SizedBox(height: 8),
              _dateBox(_expiryDate, () => _pickDate(false)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateBox(DateTime? date, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              date != null ? DateHelper.format(date) : 'Select date',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: date != null
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _notesField() => TextFormField(
    controller: _notesCtrl,
    maxLines: 4,
    maxLength: 120,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      color: AppColors.textPrimary,
    ),
    decoration: _inputDecor('Add any notes...').copyWith(
      contentPadding: const EdgeInsets.all(16),
      counterStyle: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        color: AppColors.textMuted,
      ),
    ),
  );

  Widget _saveButton() => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: _isSaving ? null : _save,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: _isSaving
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              'Save Item',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
    ),
  );

  Widget _cancelButton() => SizedBox(
    width: double.infinity,
    height: 52,
    child: OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Text(
        'Cancel',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    ),
  );

  InputDecoration _inputDecor(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      color: AppColors.textMuted,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.urgentText),
    ),
  );
}

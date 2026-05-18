import 'package:flutter/material.dart';
import 'package:due_guard/features/dueguard/data/models/item_model.dart';
import 'package:due_guard/features/dueguard/data/services/api_service.dart';

enum LoadState { idle, loading, loaded, error }

class ItemProvider extends ChangeNotifier {
  final _api = ApiService();

  List<ItemModel> _items = [];
  LoadState _loadState = LoadState.idle;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Getters

  List<ItemModel> get items => _items;
  LoadState get loadState => _loadState;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;

  List<ItemModel> get filteredItems {
    return _items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCat =
          _selectedCategory == 'All' ||
          item.category.label.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCat;
    }).toList();
  }

  // Analytics
  int get totalCount => _items.length;
  int get safeCount => _items.where((i) => i.status == ItemStatus.safe).length;
  int get soonCount => _items.where((i) => i.status == ItemStatus.soon).length;
  int get urgentCount =>
      _items.where((i) => i.status == ItemStatus.urgent).length;
  int get expiredCount =>
      _items.where((i) => i.status == ItemStatus.expired).length;
  int get expiringSoonCount => soonCount + urgentCount;

  int countByCategory(ItemCategory cat) =>
      _items.where((i) => i.category == cat).length;

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  /// READ
  Future<void> loadItems() async {
    _loadState = LoadState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _items = await _api.fetchItems();
      _loadState = LoadState.loaded;
    } catch (e) {
      _loadState = LoadState.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> retry() => loadItems();

  /// CREATE
  Future<bool> addItem(ItemModel item) async {
    _errorMessage = '';
    try {
      final saved = await _api.addItem(item);
      _items.insert(0, saved);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// UPDATE
  Future<bool> updateItem(ItemModel item) async {
    _errorMessage = '';
    try {
      final updated = await _api.updateItem(item);
      final idx = _items.indexWhere((i) => i.id == item.id);
      if (idx != -1) {
        _items[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// DELETE
  Future<bool> deleteItem(String id) async {
    _errorMessage = '';
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return false;

    final removed = _items[idx];
    _items.removeAt(idx);
    notifyListeners();

    try {
      await _api.deleteItem(id);
      return true;
    } catch (e) {
      _items.insert(idx, removed);
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  String generateId() => 'local_${DateTime.now().millisecondsSinceEpoch}';
}

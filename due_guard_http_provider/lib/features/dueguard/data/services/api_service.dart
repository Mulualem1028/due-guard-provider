import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:due_guard/core/constants/api_constants.dart';
import '../models/item_model.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  // READ
  Future<List<ItemModel>> fetchItems() async {
    try {
      final results = await Future.wait([
        // Cosmetics
        _fetchCategory('beauty',             ItemCategory.cosmetics),
        _fetchCategory('fragrances',         ItemCategory.cosmetics),
        _fetchCategory('skin-care',          ItemCategory.cosmetics),

        // Electronics
        _fetchCategory('smartphones',        ItemCategory.electronics),
        _fetchCategory('laptops',            ItemCategory.electronics),
        _fetchCategory('tablets',            ItemCategory.electronics),
        _fetchCategory('mobile-accessories', ItemCategory.electronics),

        // Medicine, Subscriptions, Documents — empty on load.
        // DummyJSON has no matching products for these categories.
        // Users add their own items via the + button (POST /products/add).
      ]);

      final seen  = <String>{};
      final items = <ItemModel>[];
      for (final list in results) {
        for (final item in list) {
          if (seen.add(item.id)) items.add(item);
        }
      }

      items.shuffle(Random());
      return items;
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('The request timed out. Please try again.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<ItemModel>> _fetchCategory(
      String slug, ItemCategory category) async {
    try {
      final uri = Uri.parse(
          '${ApiConstants.baseUrl}/products/category/$slug?limit=6');
      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data     = jsonDecode(response.body) as Map<String, dynamic>;
        final products = data['products'] as List<dynamic>? ?? [];
        return products
            .map((p) => ItemModel.fromJson(
                  p as Map<String, dynamic>,
                  forcedCategory: category,
                ))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // CREATE

  Future<ItemModel> addItem(ItemModel item) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/products/add');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(item.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data     = jsonDecode(response.body) as Map<String, dynamic>;
        final serverId = data['id']?.toString() ?? item.id;
        return item.copyWith(id: serverId);
      }
      throw Exception('Failed to add item (${response.statusCode}).');
    } on SocketException {
      throw Exception('No internet connection. Cannot add item.');
    } on TimeoutException {
      throw Exception('Request timed out. Cannot add item.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // UPDATE

  Future<ItemModel> updateItem(ItemModel item) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/products/${item.id}');
      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(item.toJson()),
          )
          .timeout(_timeout);

      
      if (response.statusCode == 200 ||
          (response.statusCode == 404 && _isUserCreated(item.id))) {
        return item;
      }
      throw Exception('Failed to update item (${response.statusCode}).');
    } on SocketException {
      throw Exception('No internet connection. Cannot update item.');
    } on TimeoutException {
      throw Exception('Request timed out. Cannot update item.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // DELETE
  Future<bool> deleteItem(String id) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/products/$id');
      final response = await http.delete(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['isDeleted'] == true;
      }
     
      if (response.statusCode == 404 && _isUserCreated(id)) {
        return true;
      }
      throw Exception('Failed to delete item (${response.statusCode}).');
    } on SocketException {
      throw Exception('No internet connection. Cannot delete item.');
    } on TimeoutException {
      throw Exception('Request timed out. Cannot delete item.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Helpers 
  bool _isUserCreated(String id) {
    if (id.startsWith('local_')) return true;
    final n = int.tryParse(id);
    return n != null && n > 194;
  }
}
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final _service = ProductService();
  List<Product> _products = [];
  bool _loading = false;
  String? _error;
  String _keyword = '';
  int? _categoryId;
  int? _userId;

  List<Product> get products => _products;
  bool get loading => _loading;
  String? get error => _error;
  int? get selectedCategoryId => _categoryId;

  Future<void> loadAll() async {
    _loading = true; _error = null; _categoryId = null; _keyword = ''; notifyListeners();
    try { _products = await _service.getAll(); } catch (e) { _error = e.toString(); }
    _loading = false; notifyListeners();
  }
  Future<void> loadByCategory(int id) async {
    _loading = true; _error = null; _categoryId = id; notifyListeners();
    try { _products = await _service.getByCategory(id); } catch (e) { _error = e.toString(); }
    _loading = false; notifyListeners();
  }
  Future<void> loadByUser(int id) async {
    _loading = true; _error = null; _userId = id; notifyListeners();
    try { _products = await _service.getByUser(id); } catch (e) { _error = e.toString(); }
    _loading = false; notifyListeners();
  }
  Future<void> search(String kw) async {
    _keyword = kw.trim();
    if (_keyword.isEmpty) return loadAll();
    _loading = true; _error = null; notifyListeners();
    try { _products = await _service.search(_keyword); } catch (e) { _error = e.toString(); }
    _loading = false; notifyListeners();
  }
  Future<void> deleteProduct(int id) async {
    await _service.delete(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
  Future<void> refresh() async {
    if (_userId != null) return loadByUser(_userId!);
    if (_categoryId != null) return loadByCategory(_categoryId!);
    if (_keyword.isNotEmpty) return search(_keyword);
    return loadAll();
  }
  void reset() { _categoryId = null; _userId = null; _keyword = ''; notifyListeners(); }
}
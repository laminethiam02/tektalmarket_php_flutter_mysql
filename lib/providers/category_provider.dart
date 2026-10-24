import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final _service = CategoryService();
  List<Category> _categories = [];
  bool _loading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadAll() async {
    _loading = true; _error = null; notifyListeners();
    try { _categories = await _service.getAll(); }
    catch (e) { _error = e.toString(); }
    _loading = false; notifyListeners();
  }
}
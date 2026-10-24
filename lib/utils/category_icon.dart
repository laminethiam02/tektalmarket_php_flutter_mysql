import 'package:flutter/material.dart';

IconData categoryIcon(String? icon) {
  const map = {
    'directions_car': Icons.directions_car,
    'smartphone': Icons.smartphone,
    'checkroom': Icons.checkroom,
    'home_work': Icons.home_work,
    'kitchen': Icons.kitchen,
    'restaurant': Icons.restaurant,
    'category': Icons.category,
  };
  return map[icon ?? 'category'] ?? Icons.category;
}
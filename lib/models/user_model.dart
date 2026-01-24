import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  int? id;
  String? email;
  String? role;
  String? token;

  void login(Map<String, dynamic> data) {
    id = data['id'];
    email = data['email'];
    role = data['role'];
    token = data['token'];
    notifyListeners();
  }

  void logout() {
    id = null;
    email = null;
    role = null;
    token = null;
    notifyListeners();
  }

  bool get isLoggedIn => token != null;
  bool get isAdmin => role == 'admin';
}
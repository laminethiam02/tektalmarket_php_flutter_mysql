import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // ← AJOUTER pour XFile
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  User? _user;
  bool _loading = true;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isVendeur => _user?.isVendeur ?? false;

  Future<void> bootstrap() async {
    final token = await ApiService.getToken();
    if (token == null) {
      _loading = false;
      notifyListeners();
      return;
    }
    try {
      _user = await _service.me();
    } catch (_) {
      await ApiService.clearToken();
      _user = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final r = await _service.login(email, password);
      await ApiService.saveToken(r.token);
      _user = r.user;
      _loading = false; notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString(); _loading = false; notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String nom, required String email, required String password,
    required String telephone, required String ville, required String role,
    String? bio, String? nomMagasin, String? adresseEntreprise,
    String? categorieEntreprise, String? descriptionEntreprise,
  }) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final r = await _service.register(
        nom: nom, email: email, password: password,
        telephone: telephone, ville: ville, role: role,
        bio: bio, nomMagasin: nomMagasin,
        adresseEntreprise: adresseEntreprise,
        categorieEntreprise: categorieEntreprise,
        descriptionEntreprise: descriptionEntreprise,
      );
      await ApiService.saveToken(r.token);
      _user = r.user;
      _loading = false; notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString(); _loading = false; notifyListeners();
      return false;
    }
  }

  Future<void> updateProfile({
    String? nom, String? telephone, String? ville, String? bio,
    String? nomMagasin, String? adresseEntreprise,
    String? categorieEntreprise, String? descriptionEntreprise,
    XFile? userImage, // ← Modifié : XFile au lieu de String
  }) async {
    _user = await _service.updateProfile(
      nom: nom, telephone: telephone, ville: ville, bio: bio,
      nomMagasin: nomMagasin, adresseEntreprise: adresseEntreprise,
      categorieEntreprise: categorieEntreprise,
      descriptionEntreprise: descriptionEntreprise,
      userImage: userImage, // ← Modifié : userImage
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    _user = null;
    notifyListeners();
  }
}
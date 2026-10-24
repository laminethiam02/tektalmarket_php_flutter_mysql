import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthResult {
  final String token;
  final User user;
  AuthResult(this.token, this.user);
}

class AuthService {
  /// 1. Inscription
  Future<AuthResult> register({
    required String nom,
    required String email,
    required String password,
    required String telephone,
    required String ville,
    required String role,
    String? bio,
    String? nomMagasin,
    String? adresseEntreprise,
    String? categorieEntreprise,
    String? descriptionEntreprise,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.authEndpoint}/register'),
      headers: ApiService.jsonHeaders,
      body: jsonEncode({
        'nom': nom,
        'email': email,
        'password': password,
        'telephone': telephone,
        'ville': ville,
        'role': role,
        'bio': bio,
        'nomMagasin': nomMagasin,
        'adresseEntreprise': adresseEntreprise,
        'categorieEntreprise': categorieEntreprise,
        'descriptionEntreprise': descriptionEntreprise,
      }),
    );
    final d = await ApiService.handleResponse(res);
    return AuthResult(d['token'], User.fromJson(d['user']));
  }

  /// 2. Connexion
  Future<AuthResult> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.authEndpoint}/login'),
      headers: ApiService.jsonHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final d = await ApiService.handleResponse(res);
    return AuthResult(d['token'], User.fromJson(d['user']));
  }

  /// 3. Récupérer l'utilisateur connecté (Me)
  Future<User> me() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.authEndpoint}/me'),
      headers: await ApiService.authHeaders(),
    );
    final d = await ApiService.handleResponse(res);
    return User.fromJson(d);
  }

  /// 4. Mettre à jour le profil (Web & Mobile compatible)
  Future<User> updateProfile({
    String? nom,
    String? telephone,
    String? ville,
    String? bio,
    String? nomMagasin,
    String? adresseEntreprise,
    String? categorieEntreprise,
    String? descriptionEntreprise,
    XFile? userImage,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.usersEndpoint}/profile'),
    );

    // Ajout du token d'authentification
    req.headers.addAll(await ApiService.authMultipartHeaders());

    // Méthode override pour simuler un PUT
    req.fields['_method'] = 'PUT';

    if (nom != null) req.fields['nom'] = nom;
    if (telephone != null) req.fields['telephone'] = telephone;
    if (ville != null) req.fields['ville'] = ville;
    if (bio != null) req.fields['bio'] = bio;
    if (nomMagasin != null) req.fields['nomMagasin'] = nomMagasin;
    if (adresseEntreprise != null) req.fields['adresseEntreprise'] = adresseEntreprise;
    if (categorieEntreprise != null) req.fields['categorieEntreprise'] = categorieEntreprise;
    if (descriptionEntreprise != null) req.fields['descriptionEntreprise'] = descriptionEntreprise;

    // Gestion de l'image compatible Web & Mobile
    if (userImage != null) {
      final bytes = await userImage.readAsBytes();
      req.files.add(http.MultipartFile.fromBytes(
        'userImage',
        bytes,
        filename: userImage.name,
      ));
    }

    final s = await req.send();
    final res = await http.Response.fromStream(s);
    final d = await ApiService.handleResponse(res);

    return User.fromJson(d);
  }

  /// 5. Récupérer un profil public (vendeur)
  Future<User> getPublicProfile(int id) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.usersEndpoint}/$id'),
      headers: ApiService.jsonHeaders,
    );
    final d = await ApiService.handleResponse(res);
    return User.fromJson(d);
  }
}
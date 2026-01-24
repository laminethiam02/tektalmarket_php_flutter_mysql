class Constants {
  // API Endpoints
  static const String apiBaseUrl = 'http://localhost/gestion_vente';

  // Shared Preferences Keys
  static const String tokenKey = 'token';
  static const String userEmailKey = 'user_email';
  static const String userRoleKey = 'user_role';

  // App Constants
  static const String appName = 'Gestion de Vente';
  static const String version = '1.0.0';

  // Default Values
  static const int defaultPageSize = 20;
  static const int defaultTimeout = 30000;

  // Status Codes
  static const int success = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;

  // Validation Messages
  static const String requiredField = 'Ce champ est requis';
  static const String invalidEmail = 'Email invalide';
  static const String invalidPhone = 'Numéro de téléphone invalide';
  static const String passwordTooShort = 'Le mot de passe doit contenir au moins 6 caractères';
  static const String passwordsDontMatch = 'Les mots de passe ne correspondent pas';
}
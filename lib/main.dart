import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- 1. AJOUTER CET IMPORT

import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/product_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

// <-- 2. RENDRE LA FONCTION ASYNCHRONE
void main() async {
  // <-- 3. INITIALISER LES SERVICES FLUTTER (Obligatoire sur le Web avant l'await)
  WidgetsFlutterBinding.ensureInitialized();

  // <-- 4. INITIALISER LA LANGUE FRANÇAISE POUR INTL
  await initializeDateFormatting('fr_FR', null);

  runApp(const ApiMarcheApp());
}

class ApiMarcheApp extends StatelessWidget {
  const ApiMarcheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..bootstrap()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        title: 'Api Marché',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import 'products_screen.dart';
import 'profile_screen.dart';
import 'product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAll();
      context.read<CategoryProvider>().loadAll();
    });
  }

  // Fonction pour ouvrir le formulaire d'ajout
  Future<void> _addAnnonce(BuildContext context) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );
    if (created == true && context.mounted) {
      context.read<ProductProvider>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAuthenticated) return const SizedBox();

    // Pages affichées dans l'application
    const pages = <Widget>[
      ProductsScreen(),
      ProfileScreen(),
    ];

    // Vérification de la largeur de l'écran pour le responsive Web
    final bool isDesktop = MediaQuery.of(context).size.width >= 800;

    // On affiche le bouton uniquement si l'utilisateur est un vendeur ET qu'il est sur l'onglet Annonces
    final bool showAddButton = auth.isVendeur && _index == 0;

    // ==========================================
    // 1. VERSION WEB / DESKTOP (Menu latéral)
    // ==========================================
    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Menu de navigation vertical
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              selectedIconTheme: const IconThemeData(color: Colors.deepPurple),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
              // Bouton Ajouter placé juste sous les icônes de navigation
              trailing: showAddButton
                  ? Padding(
                padding: const EdgeInsets.only(top: 32),
                child: FloatingActionButton(
                  onPressed: () => _addAnnonce(context),
                  tooltip: 'Ajouter une annonce',
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.add),
                ),
              )
                  : null,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront),
                  label: Text('Annonces'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Profil'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            // Contenu principal
            Expanded(
              child: IndexedStack(index: _index, children: pages),
            ),
          ],
        ),
      );
    }

    // ==========================================
    // 2. VERSION MOBILE / TABLETTE (Barre en bas)
    // ==========================================
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      // Bouton flottant en bas à droite pour le mobile
      floatingActionButton: showAddButton
          ? FloatingActionButton.extended(
        onPressed: () => _addAnnonce(context),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Annonce'),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Annonces',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
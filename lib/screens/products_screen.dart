import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_widget.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final categories = context.watch<CategoryProvider>().categories;

    // Responsive Web
    final double width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width >= 600 && width < 900) crossAxisCount = 3;
    if (width >= 900 && width < 1200) crossAxisCount = 4;
    if (width >= 1200) crossAxisCount = 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Annonces'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: () => provider.refresh(),
          ),
        ],
      ),
      // 🚨 LE BOUTON FLOTTANT A ÉTÉ SUPPRIMÉ ICI
      // Il est maintenant géré par le HomeScreen
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              // ---- BARRE DE RECHERCHE ----
              Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() {}),
                  onSubmitted: (v) => provider.search(v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher (titre, ville)...',
                    prefixIcon: const Icon(Icons.search),
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() {});
                        provider.search('');
                      },
                    )
                        : null,
                  ),
                ),
              ),

              // ---- FILTRES CATÉGORIES ----
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Toutes'),
                      selected: provider.selectedCategoryId == null,
                      onSelected: (_) {
                        provider.reset();
                        provider.loadAll();
                      },
                    ),
                    const SizedBox(width: 8),
                    for (final c in categories) ...[
                      ChoiceChip(
                        label: Text(c.categoryName ?? ''),
                        selected: provider.selectedCategoryId == c.id,
                        onSelected: (sel) {
                          if (sel && c.id != null) {
                            provider.loadByCategory(c.id!);
                          } else {
                            provider.reset();
                            provider.loadAll();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),

              // ---- GRILLE DES ANNONCES ----
              Expanded(
                child: provider.loading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null
                    ? EmptyWidget(
                  icon: Icons.error_outline,
                  message: provider.error!,
                  onAction: () => provider.refresh(),
                  actionLabel: 'Réessayer',
                )
                    : provider.products.isEmpty
                    ? const EmptyWidget(
                  icon: Icons.inventory_2_outlined,
                  message: 'Aucune annonce trouvée',
                )
                    : RefreshIndicator(
                  onRefresh: provider.refresh,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: provider.products.length,
                    itemBuilder: (_, i) {
                      final p = provider.products[i];
                      return ProductCard(
                        product: p,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(productId: p.id!),
                          ),
                        ).then((_) => provider.refresh()),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../models/produit_model.dart';
import '../../services/produit_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_dialog.dart';
import 'add_produit_screen.dart';
import 'edit_produit_screen.dart';

class ProduitsScreen extends StatefulWidget {
  const ProduitsScreen({Key? key}) : super(key: key);

  @override
  _ProduitsScreenState createState() => _ProduitsScreenState();
}

class _ProduitsScreenState extends State<ProduitsScreen> {
  final ProduitService _produitService = ProduitService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Produit> _produits = [];
  List<Produit> _filteredProduits = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _loadProduits();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoadingMore) {
        _loadMoreProduits();
      }
    }
  }

  Future<void> _loadProduits({bool reset = false}) async {
    if (reset) {
      setState(() {
        _page = 1;
        _produits.clear();
        _filteredProduits.clear();
        _hasMore = true;
      });
    }

    try {
      final produits = await _produitService.getProduits(
        page: _page,
        limit: _limit,
        search: _searchController.text.isEmpty ? null : _searchController.text.trim(),
        lowStock: _showLowStockOnly,
      );

      setState(() {
        if (reset) {
          _produits = produits;
        } else {
          _produits.addAll(produits);
        }
        _filteredProduits = _produits;
        _hasMore = produits.length == _limit;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(context, 'Erreur lors du chargement: $e');
      }
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreProduits() async {
    if (!_hasMore || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _page++;
    });

    await _loadProduits();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredProduits = _produits;
      } else {
        _filteredProduits = _produits.where((produit) {
          return produit.nom.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _deleteProduit(int id, BuildContext context) async {
    final confirmed = await CustomDialog.showConfirm(
      context,
      'Supprimer ce produit?',
      'Cette action est irréversible.',
    );

    if (confirmed) {
      try {
        await _produitService.deleteProduit(id);
        setState(() {
          _produits.removeWhere((produit) => produit.id == id);
          _filteredProduits.removeWhere((produit) => produit.id == id);
        });
        if (mounted) {
          CustomDialog.showSuccess(context, 'Produit supprimé avec succès');
        }
      } catch (e) {
        if (mounted) {
          CustomDialog.showError(context, 'Erreur: $e');
        }
      }
    }
  }

  Future<void> _refresh() async {
    await _loadProduits(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Produits',
        actions: [
          IconButton(
            icon: Icon(
              _showLowStockOnly ? Icons.inventory : Icons.inventory_2,
              color: _showLowStockOnly ? Colors.red : null,
            ),
            onPressed: () {
              setState(() => _showLowStockOnly = !_showLowStockOnly);
              _loadProduits(reset: true);
            },
            tooltip: _showLowStockOnly ? 'Tous les stocks' : 'Stocks bas uniquement',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddProduitScreen()),
              );
              if (result == true) {
                await _loadProduits(reset: true);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _isLoading && _produits.isEmpty
                  ? const LoadingWidget()
                  : _filteredProduits.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty
                          ? 'Aucun produit trouvé'
                          : 'Aucun résultat pour "${_searchController.text}"',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_searchController.text.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged();
                        },
                        child: const Text('Effacer la recherche'),
                      ),
                  ],
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                itemCount: _filteredProduits.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _filteredProduits.length) {
                    return _buildLoadMoreIndicator();
                  }

                  final produit = _filteredProduits[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStockColor(produit.stock),
                        child: Text(
                          produit.stock.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        produit.nom,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prix: ${produit.prix.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          if (produit.createdAt != null)
                            Text(
                              'Créé le ${_formatDate(produit.createdAt)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Modifier'),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'edit') {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProduitScreen(produit: produit),
                              ),
                            );
                            if (result == true) {
                              await _loadProduits(reset: true);
                            }
                          } else if (value == 'delete') {
                            await _deleteProduit(produit.id, context);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return _isLoadingMore
        ? const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    )
        : _hasMore
        ? Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _loadMoreProduits,
        child: const Text('Charger plus'),
      ),
    )
        : const SizedBox();
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock < 10) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
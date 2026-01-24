import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/client_model.dart';
import '../../models/produit_model.dart';
import '../../models/commande_item_model.dart';
import '../../services/client_service.dart';
import '../../services/produit_service.dart';
import '../../services/commande_service.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/loading_widget.dart';

class CreateCommandeScreen extends StatefulWidget {
  const CreateCommandeScreen({Key? key}) : super(key: key);

  @override
  _CreateCommandeScreenState createState() => _CreateCommandeScreenState();
}

class _CreateCommandeScreenState extends State<CreateCommandeScreen> {
  final ClientService _clientService = ClientService();
  final ProduitService _produitService = ProduitService();
  final CommandeService _commandeService = CommandeService();

  List<Client> _clients = [];
  List<Produit> _produits = [];
  List<CommandeItem> _items = [];

  Client? _selectedClient;
  Produit? _selectedProduit;
  String _quantity = '1';

  bool _isLoading = true;
  bool _isCreating = false;
  final TextEditingController _searchClientController = TextEditingController();
  final TextEditingController _searchProduitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchClientController.dispose();
    _searchProduitController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final clients = await _clientService.getClients(limit: 100);
      final produits = await _produitService.getProduits(limit: 100);

      setState(() {
        _clients = clients;
        _produits = produits;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(context, 'Erreur: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  void _addItem() {
    if (_selectedProduit == null) {
      CustomDialog.showError(context, 'Veuillez sélectionner un produit');
      return;
    }

    final quantity = int.tryParse(_quantity);
    if (quantity == null || quantity <= 0) {
      CustomDialog.showError(context, 'Quantité invalide');
      return;
    }

    if (quantity > _selectedProduit!.stock) {
      CustomDialog.showError(context, 'Stock insuffisant');
      return;
    }

    setState(() {
      _items.add(CommandeItem(
        id: 0,
        commandeId: 0,
        produitId: _selectedProduit!.id,
        quantite: quantity,
        prixUnitaire: _selectedProduit!.prix,
        produitNom: _selectedProduit!.nom,
      ));

      _selectedProduit = null;
      _quantity = '1';
      _searchProduitController.clear();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _createCommande() async {
    if (_selectedClient == null) {
      CustomDialog.showError(context, 'Veuillez sélectionner un client');
      return;
    }

    if (_items.isEmpty) {
      CustomDialog.showError(context, 'La commande doit contenir au moins un produit');
      return;
    }

    setState(() => _isCreating = true);

    try {
      await _commandeService.createCommande(_selectedClient!.id, _items);

      if (mounted) {
        CustomDialog.showSuccess(
          context,
          'Commande créée avec succès',
          onConfirm: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(context, 'Erreur: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  double get _total {
    return _items.fold(0, (sum, item) => sum + item.sousTotal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle commande'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isCreating || _items.isEmpty ? null : _createCommande,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélection du client
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Client',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Client>(
                      value: _selectedClient,
                      decoration: const InputDecoration(
                        labelText: 'Sélectionner un client',
                        border: OutlineInputBorder(),
                      ),
                      items: _clients.map((client) {
                        return DropdownMenuItem(
                          value: client,
                          child: Text(client.nom),
                        );
                      }).toList(),
                      onChanged: (client) {
                        setState(() => _selectedClient = client);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Ajout de produits
            Card(
              margin: const EdgeInsets.only(top: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ajouter des produits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Produit>(
                      value: _selectedProduit,
                      decoration: const InputDecoration(
                        labelText: 'Sélectionner un produit',
                        border: OutlineInputBorder(),
                      ),
                      items: _produits.map((produit) {
                        return DropdownMenuItem(
                          value: produit,
                          child: Text('${produit.nom} (Stock: ${produit.stock})'),
                        );
                      }).toList(),
                      onChanged: (produit) {
                        setState(() => _selectedProduit = produit);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Quantité',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: _quantity),
                      onChanged: (value) => _quantity = value,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addItem,
                        child: const Text('Ajouter au panier'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Panier
            if (_items.isNotEmpty) ...[
              Card(
                margin: const EdgeInsets.only(top: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Panier',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return ListTile(
                          leading: const Icon(Icons.shopping_cart),
                          title: Text(item.produitNom ?? 'Produit'),
                          subtitle: Text(
                            '${item.quantite} × ${item.prixUnitaire.toStringAsFixed(2)} €',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.sousTotal.toStringAsFixed(2)} €',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(index),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      // Total
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_total.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton de création
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createCommande,
                    child: _isCreating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Créer la commande',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
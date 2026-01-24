import 'package:flutter/material.dart';
import '../../models/produit_model.dart';
import '../../services/produit_service.dart';
import '../../widgets/custom_dialog.dart';

class EditProduitScreen extends StatefulWidget {
  final Produit produit;

  const EditProduitScreen({Key? key, required this.produit}) : super(key: key);

  @override
  _EditProduitScreenState createState() => _EditProduitScreenState();
}

class _EditProduitScreenState extends State<EditProduitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prixController;
  late TextEditingController _stockController;
  final ProduitService _produitService = ProduitService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.produit.nom);
    _prixController = TextEditingController(text: widget.produit.prix.toString());
    _stockController = TextEditingController(text: widget.produit.stock.toString());
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prixController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _updateProduit() async {
    if (!_formKey.currentState!.validate()) return;

    final prix = double.tryParse(_prixController.text);
    final stock = int.tryParse(_stockController.text);

    if (prix == null || prix <= 0) {
      CustomDialog.showError(context, 'Prix invalide');
      return;
    }

    if (stock == null || stock < 0) {
      CustomDialog.showError(context, 'Stock invalide');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _produitService.updateProduit(
        widget.produit.id,
        _nomController.text.trim(),
        prix,
        stock,
      );

      if (mounted) {
        CustomDialog.showSuccess(
          context,
          'Produit mis à jour avec succès',
          onConfirm: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialog.showError(context, 'Erreur: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le produit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateProduit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom du produit *',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _prixController,
                decoration: const InputDecoration(
                  labelText: 'Prix (€) *',
                  prefixIcon: Icon(Icons.euro),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le prix est requis';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Prix invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  prefixIcon: Icon(Icons.warehouse),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final stock = int.tryParse(value);
                    if (stock == null || stock < 0) {
                      return 'Stock invalide';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProduit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Mettre à jour'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
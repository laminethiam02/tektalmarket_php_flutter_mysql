import 'package:flutter/material.dart';
import '../../services/produit_service.dart';
import '../../widgets/custom_dialog.dart';

class AddProduitScreen extends StatefulWidget {
  const AddProduitScreen({Key? key}) : super(key: key);

  @override
  _AddProduitScreenState createState() => _AddProduitScreenState();
}

class _AddProduitScreenState extends State<AddProduitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prixController = TextEditingController();
  final _stockController = TextEditingController();
  final ProduitService _produitService = ProduitService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prixController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _addProduit() async {
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
      await _produitService.addProduit(
        _nomController.text.trim(),
        prix,
        stock,
      );

      if (mounted) {
        CustomDialog.showSuccess(
          context,
          'Produit ajouté avec succès',
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
        title: const Text('Ajouter un produit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _addProduit,
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
                  labelText: 'Stock initial',
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
                  onPressed: _isLoading ? null : _addProduit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Ajouter le produit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
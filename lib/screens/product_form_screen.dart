import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../services/product_service.dart';
import '../utils/image_helper.dart';
import '../config/api_config.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ProductService();

  late TextEditingController _title, _desc, _price, _ville;
  int? _categoryId;
  List<XFile> _images = [];
  bool _saving = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _title = TextEditingController(text: p?.productTitle ?? '');
    _desc = TextEditingController(text: p?.productDescription ?? '');
    _price = TextEditingController(text: p?.productPrice?.toString() ?? '');
    _ville = TextEditingController(text: p?.ville ?? '');
    _categoryId = p?.categoryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadAll();
    });
  }

  Future<void> _pickImages() async {
    final picked = await ImageHelper.pickMultiple(limit: 5 - _images.length);
    if (picked.isNotEmpty && mounted) {
      setState(() => _images.addAll(picked));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sélectionnez une catégorie')));
      return;
    }
    setState(() => _saving = true);
    try {
      if (isEditing) {
        await _service.update(
          id: widget.product!.id!,
          productTitle: _title.text.trim(),
          productDescription: _desc.text.trim(),
          productPrice: double.parse(_price.text),
          ville: _ville.text.trim(),
          categoryId: _categoryId,
          images: _images,
        );
      } else {
        await _service.create(
          productTitle: _title.text.trim(),
          productDescription: _desc.text.trim(),
          productPrice: double.parse(_price.text),
          ville: _ville.text.trim(),
          categoryId: _categoryId!,
          images: _images,
        );
      }
      if (!mounted) return;
      context.read<ProductProvider>().refresh();
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;
    final existing = widget.product?.images.map((i) => i.imagePath ?? '').toList() ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Modifier annonce' : 'Nouvelle annonce')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Limite la largeur sur PC
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Photos (5 max)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Nouvelles images (Web & Mobile)
                      for (final img in _images)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FutureBuilder<Uint8List>(
                                  future: img.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Image.memory(
                                        snapshot.data!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      );
                                    }
                                    return Container(
                                      width: 100, height: 100,
                                      color: Colors.grey.shade200,
                                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 0, right: 0,
                                child: InkWell(
                                  onTap: () => setState(() => _images.remove(img)),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Anciennes images
                      if (existing.isNotEmpty && _images.isEmpty)
                        for (final path in existing)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(ApiConfig.imageUrl(path)!,
                                  width: 100, height: 100, fit: BoxFit.cover),
                            ),
                          ),

                      // Bouton Ajouter
                      if (_images.length < 5 && (existing.isEmpty || _images.isNotEmpty))
                        InkWell(
                          onTap: _pickImages,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                      labelText: 'Titre *', prefixIcon: Icon(Icons.title)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _desc,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      labelText: 'Description', alignLabelWithHint: true),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _categoryId,
                  decoration: const InputDecoration(
                      labelText: 'Catégorie *', prefixIcon: Icon(Icons.category_outlined)),
                  items: categories.where((c) => c.id != null).map((c) =>
                      DropdownMenuItem(value: c.id, child: Text(c.categoryName ?? ''))).toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) => v == null ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Prix (CFA) *', prefixIcon: Icon(Icons.euro)),
                  validator: (v) => (v == null || double.tryParse(v) == null) ? 'Invalide' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ville,
                  decoration: const InputDecoration(
                      labelText: 'Ville *', prefixIcon: Icon(Icons.location_on_outlined)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  label: Text(_saving ? 'Enregistrement...'
                      : (isEditing ? 'Enregistrer' : 'Publier')),
                ),
                const SizedBox(height: 12),
                Text('La durée de l\'annonce (30 jours) est définie automatiquement.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
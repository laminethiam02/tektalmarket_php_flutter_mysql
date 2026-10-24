import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/api_config.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import '../widgets/image_carousel.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _service = ProductService();
  Product? _product;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final prod = await _service.getById(widget.productId);
      if (mounted) {
        setState(() {
          _product = prod;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _product == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(_error ?? 'Produit introuvable')));
    }

    final p = _product!;
    // Le NumberFormat fonctionnera maintenant car 'fr_FR' est initialisé dans main.dart
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: 'CFA', decimalDigits: 0);
    final isOwner = auth.user?.id == p.userId;

    final imagePaths = p.images.map((i) => i.imagePath ?? '').where((s) => s.isNotEmpty).toList();
    if (imagePaths.isEmpty && p.productImage != null) imagePaths.add(p.productImage!);
    final sellerImg = ApiConfig.imageUrl(p.seller?.userImage);

    return Scaffold(
      appBar: AppBar(
        title: Text(p.productTitle ?? 'Détail du produit'),
        actions: [
          if (isOwner) ...[
            IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Modifier',
                onPressed: () async {
                  final ok = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => ProductFormScreen(product: p))
                  );
                  if (ok == true) _load();
                }
            ),
            IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                tooltip: 'Supprimer',
                onPressed: () async {
                  final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Supprimer'),
                        content: Text('Voulez-vous vraiment supprimer "${p.productTitle}" ?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annuler')
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                  );
                  if (ok == true && mounted) {
                    await context.read<ProductProvider>().deleteProduct(p.id!);
                    if (mounted) Navigator.pop(context);
                  }
                }
            ),
          ],
        ],
      ),
      // --- ADAPTATION WEB : Centre et limite la largeur sur PC ---
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ImageCarousel(imagePaths: imagePaths),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          p.productTitle ?? '',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 8),
                      Text(
                          fmt.format(p.productPrice ?? 0),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary)
                      ),
                      const SizedBox(height: 12),
                      if (p.categoryName != null)
                        Chip(
                          label: Text(p.categoryName!),
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          labelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 16),
                      Wrap( // Utilisation de Wrap au lieu de Row pour éviter les débordements (overflow) sur petits écrans
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, size: 18, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(p.ville ?? 'Non spécifié', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule, size: 18, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(p.dureeLabel, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(p.expiresLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 20),

                      if ((p.productDescription ?? '').isNotEmpty) ...[
                        const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(
                            p.productDescription!,
                            style: TextStyle(height: 1.5, color: Colors.grey.shade800, fontSize: 15)
                        ),
                        const SizedBox(height: 20),
                      ],

                      const Divider(),
                      const SizedBox(height: 8),
                      const Text('Vendu par', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),

                      if (p.seller != null)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey.shade200,
                                  backgroundImage: sellerImg != null ? CachedNetworkImageProvider(sellerImg) : null,
                                  child: sellerImg == null ? const Icon(Icons.person, size: 30, color: Colors.grey) : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          p.seller!.nom ?? 'Vendeur',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                      ),
                                      if (p.seller!.nomMagasin != null)
                                        Text(
                                            p.seller!.nomMagasin!,
                                            style: const TextStyle(color: Colors.grey, fontSize: 14)
                                        ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.phone, size: 14, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text(p.seller!.telephone ?? '-', style: const TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          const SizedBox(width: 6),
                                          Text(p.seller!.ville ?? '-', style: const TextStyle(fontSize: 13)),
                                        ],
                                      ),
                                      if (p.seller!.membreDepuis != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                              'Membre depuis ${_formatDate(p.seller!.membreDepuis!)}',
                                              style: const TextStyle(fontSize: 12, color: Colors.grey)
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.tryParse(iso.replaceAll(' ', 'T'));
      if (dt == null) return iso;
      return DateFormat('MMMM yyyy', 'fr_FR').format(dt);
    } catch (e) {
      return iso; // En cas d'erreur, on retourne la date brute
    }
  }
}
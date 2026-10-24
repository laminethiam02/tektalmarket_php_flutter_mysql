import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_FR', symbol: 'CFA', decimalDigits: 0);
    final img = ApiConfig.imageUrl(product.productImage);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: img != null
                  ? CachedNetworkImage(
                imageUrl: img, fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey.shade200),
                errorWidget: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey)),
              )
                  : Container(color: Colors.grey.shade200,
                  child: const Icon(Icons.image, color: Colors.grey)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.productTitle ?? 'Sans titre',
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(fmt.format(product.productPrice ?? 0),
                      style: const TextStyle(fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF), fontSize: 15)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: Colors.grey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(product.ville ?? '',
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                      ),
                      const SizedBox(width: 4),
                      Text(product.dureeLabel,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
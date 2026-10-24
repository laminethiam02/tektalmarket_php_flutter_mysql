import 'product_image.dart';
import 'user.dart';

class Product {
  final int? id;
  final String? productTitle;
  final String? productDescription;
  final double? productPrice;
  final String? ville;
  final String? productImage;
  final int? categoryId;
  final String? categoryName;
  final int? userId;
  final int durationDays;
  final String? expiresAt;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final List<ProductImage> images;
  final SellerInfo? seller;

  Product({
    this.id, this.productTitle, this.productDescription, this.productPrice,
    this.ville, this.productImage, this.categoryId,
    this.categoryName, this.userId, this.durationDays = 30, this.expiresAt,
    this.isActive = true, this.createdAt, this.updatedAt,
    this.images = const [], this.seller,
  });

  /// "il y a Xj" calculé depuis createdAt
  String get dureeLabel {
    if (createdAt == null) return '';
    final dt = DateTime.tryParse(createdAt!.replaceAll(' ', 'T'));
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return 'il y a ${diff.inDays}j';
    if (diff.inHours > 0) return 'il y a ${diff.inHours}h';
    if (diff.inMinutes > 0) return 'il y a ${diff.inMinutes}min';
    return "à l'instant";
  }

  /// "27 jours restants"
  String get expiresLabel {
    if (expiresAt == null) return '';
    final dt = DateTime.tryParse(expiresAt!.replaceAll(' ', 'T'));
    if (dt == null) return '';
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Expirée';
    if (diff.inDays > 0) return '${diff.inDays} j restants';
    return '${diff.inHours} h restants';
  }

  factory Product.fromJson(Map<String, dynamic> j) => Product(
    id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}'),
    productTitle: j['productTitle'],
    productDescription: j['productDescription'],
    productPrice: j['productPrice'] != null ? (j['productPrice'] as num).toDouble() : null,
    ville: j['ville'],
    productImage: j['productImage'],
    categoryId: j['categoryId'] is int ? j['categoryId'] : int.tryParse('${j['categoryId']}'),
    categoryName: j['categoryName'],
    userId: j['userId'] is int ? j['userId'] : int.tryParse('${j['userId']}'),
    durationDays: j['durationDays'] is int ? j['durationDays'] : int.tryParse('${j['durationDays']}') ?? 30,
    expiresAt: j['expiresAt'],
    isActive: j['isActive'] == true || j['isActive'] == 1,
    createdAt: j['createdAt'],
    updatedAt: j['updatedAt'],
    images: (j['images'] as List?)?.map((e) => ProductImage.fromJson(e)).toList() ?? [],
    seller: j['seller'] != null ? SellerInfo.fromJson(j['seller']) : null,
  );
}
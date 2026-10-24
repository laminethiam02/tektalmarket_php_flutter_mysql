class ProductImage {
  final int? id;
  final String? imagePath;
  final int sortOrder;

  ProductImage({this.id, this.imagePath, this.sortOrder = 0});

  factory ProductImage.fromJson(Map<String, dynamic> j) => ProductImage(
    id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}'),
    imagePath: j['imagePath'],
    sortOrder: j['sortOrder'] is int ? j['sortOrder'] : int.tryParse('${j['sortOrder']}') ?? 0,
  );
}
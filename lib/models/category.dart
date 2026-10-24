class Category {
  final int? id;
  final String? categoryName;
  final String? icon;

  Category({this.id, this.categoryName, this.icon});

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}'),
    categoryName: j['categoryName'],
    icon: j['icon'],
  );
}
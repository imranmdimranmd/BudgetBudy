class Subcategory {
  final int? id;
  final int categoryId;
  final String name;

  Subcategory({this.id, required this.categoryId, required this.name});

  Map<String, dynamic> toMap() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
      };

  factory Subcategory.fromMap(Map<String, dynamic> map) => Subcategory(
        id: map['id'] as int?,
        categoryId: map['category_id'] as int,
        name: map['name'] as String,
      );
}

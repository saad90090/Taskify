class Category {
  String id;
  String name;

  Category({required this.id, required this.name});

  factory Category.fromMap(String id, Map<String, dynamic> data) => Category(
        id: id,
        name: data['name'],
      );
}

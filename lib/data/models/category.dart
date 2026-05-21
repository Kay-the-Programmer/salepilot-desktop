class Category {
  Category({required this.id, required this.name, this.parentId});

  final String id;
  final String name;
  final String? parentId;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        parentId: json['parentId']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (parentId != null) 'parentId': parentId,
      };
}

class CategoryEntry {
  final String id;
  final String title;
  final String description;
  final String themeColor;
  final String? iconAsset;
  final int sortOrder;

  const CategoryEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.themeColor,
    this.iconAsset,
    required this.sortOrder,
  });

  CategoryEntry copyWith({
    String? id,
    String? title,
    String? description,
    String? themeColor,
    String? iconAsset,
    int? sortOrder,
  }) {
    return CategoryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      themeColor: themeColor ?? this.themeColor,
      iconAsset: iconAsset ?? this.iconAsset,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'themeColor': themeColor,
      'iconAsset': iconAsset,
      'sortOrder': sortOrder,
    };
  }

  factory CategoryEntry.fromMap(Map<String, dynamic> map) {
    return CategoryEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      themeColor: map['themeColor'] as String,
      iconAsset: map['iconAsset'] as String?,
      sortOrder: map['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory CategoryEntry.fromJson(Map<String, dynamic> json) =>
      CategoryEntry.fromMap(json);
}

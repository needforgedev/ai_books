class SavedItem {
  final int? id;
  final String type;
  final String sourceBookId;
  final String? sourceCheckpointId;
  final String? savedText;
  final DateTime createdAt;

  const SavedItem({
    this.id,
    required this.type,
    required this.sourceBookId,
    this.sourceCheckpointId,
    this.savedText,
    required this.createdAt,
  });

  SavedItem copyWith({
    int? id,
    String? type,
    String? sourceBookId,
    String? sourceCheckpointId,
    String? savedText,
    DateTime? createdAt,
  }) {
    return SavedItem(
      id: id ?? this.id,
      type: type ?? this.type,
      sourceBookId: sourceBookId ?? this.sourceBookId,
      sourceCheckpointId: sourceCheckpointId ?? this.sourceCheckpointId,
      savedText: savedText ?? this.savedText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'sourceBookId': sourceBookId,
      'sourceCheckpointId': sourceCheckpointId,
      'savedText': savedText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavedItem.fromMap(Map<String, dynamic> map) {
    return SavedItem(
      id: map['id'] as int?,
      type: map['type'] as String,
      sourceBookId: map['sourceBookId'] as String,
      sourceCheckpointId: map['sourceCheckpointId'] as String?,
      savedText: map['savedText'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory SavedItem.fromJson(Map<String, dynamic> json) =>
      SavedItem.fromMap(json);
}

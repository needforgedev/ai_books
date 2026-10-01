class NoteLink {
  final int? id;
  final int fromSavedItemId;
  final int toSavedItemId;
  final String? label;
  final DateTime createdAt;

  const NoteLink({
    this.id,
    required this.fromSavedItemId,
    required this.toSavedItemId,
    this.label,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'from_saved_item_id': fromSavedItemId,
        'to_saved_item_id': toSavedItemId,
        'label': label,
        'created_at': createdAt.toIso8601String(),
      };

  factory NoteLink.fromMap(Map<String, dynamic> map) => NoteLink(
        id: map['id'] as int?,
        fromSavedItemId: map['from_saved_item_id'] as int,
        toSavedItemId: map['to_saved_item_id'] as int,
        label: map['label'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

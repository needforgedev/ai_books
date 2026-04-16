class CheckpointEntry {
  final String id;
  final String bookId;
  final int checkpointOrder;
  final String title;
  final String? checkpointType;
  final String? hookText;
  final String? explanationText;
  final String? modernExample;
  final String? reflectionPrompt;
  final String? keyQuote;
  final String? imageAssetOrUrl;
  final String? recapText;
  final int? estimatedMinutes;

  const CheckpointEntry({
    required this.id,
    required this.bookId,
    required this.checkpointOrder,
    required this.title,
    this.checkpointType,
    this.hookText,
    this.explanationText,
    this.modernExample,
    this.reflectionPrompt,
    this.keyQuote,
    this.imageAssetOrUrl,
    this.recapText,
    this.estimatedMinutes,
  });

  CheckpointEntry copyWith({
    String? id,
    String? bookId,
    int? checkpointOrder,
    String? title,
    String? checkpointType,
    String? hookText,
    String? explanationText,
    String? modernExample,
    String? reflectionPrompt,
    String? keyQuote,
    String? imageAssetOrUrl,
    String? recapText,
    int? estimatedMinutes,
  }) {
    return CheckpointEntry(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      checkpointOrder: checkpointOrder ?? this.checkpointOrder,
      title: title ?? this.title,
      checkpointType: checkpointType ?? this.checkpointType,
      hookText: hookText ?? this.hookText,
      explanationText: explanationText ?? this.explanationText,
      modernExample: modernExample ?? this.modernExample,
      reflectionPrompt: reflectionPrompt ?? this.reflectionPrompt,
      keyQuote: keyQuote ?? this.keyQuote,
      imageAssetOrUrl: imageAssetOrUrl ?? this.imageAssetOrUrl,
      recapText: recapText ?? this.recapText,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'checkpointOrder': checkpointOrder,
      'title': title,
      'checkpointType': checkpointType,
      'hookText': hookText,
      'explanationText': explanationText,
      'modernExample': modernExample,
      'reflectionPrompt': reflectionPrompt,
      'keyQuote': keyQuote,
      'imageAssetOrUrl': imageAssetOrUrl,
      'recapText': recapText,
      'estimatedMinutes': estimatedMinutes,
    };
  }

  factory CheckpointEntry.fromMap(Map<String, dynamic> map) {
    return CheckpointEntry(
      id: map['id'] as String,
      bookId: map['bookId'] as String,
      checkpointOrder: map['checkpointOrder'] as int,
      title: map['title'] as String,
      checkpointType: map['checkpointType'] as String?,
      hookText: map['hookText'] as String?,
      explanationText: map['explanationText'] as String?,
      modernExample: map['modernExample'] as String?,
      reflectionPrompt: map['reflectionPrompt'] as String?,
      keyQuote: map['keyQuote'] as String?,
      imageAssetOrUrl: map['imageAssetOrUrl'] as String?,
      recapText: map['recapText'] as String?,
      estimatedMinutes: map['estimatedMinutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory CheckpointEntry.fromJson(Map<String, dynamic> json) =>
      CheckpointEntry.fromMap(json);
}

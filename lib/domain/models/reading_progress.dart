import 'dart:convert';

class ReadingProgress {
  final int? id;
  final String bookId;
  final String? currentCheckpointId;
  final List<String> completedCheckpointIds;
  final double completionPercent;
  final DateTime startedAt;
  final DateTime lastOpenedAt;
  final DateTime? finishedAt;

  const ReadingProgress({
    this.id,
    required this.bookId,
    this.currentCheckpointId,
    required this.completedCheckpointIds,
    required this.completionPercent,
    required this.startedAt,
    required this.lastOpenedAt,
    this.finishedAt,
  });

  ReadingProgress copyWith({
    int? id,
    String? bookId,
    String? currentCheckpointId,
    List<String>? completedCheckpointIds,
    double? completionPercent,
    DateTime? startedAt,
    DateTime? lastOpenedAt,
    DateTime? finishedAt,
  }) {
    return ReadingProgress(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      currentCheckpointId: currentCheckpointId ?? this.currentCheckpointId,
      completedCheckpointIds:
          completedCheckpointIds ?? this.completedCheckpointIds,
      completionPercent: completionPercent ?? this.completionPercent,
      startedAt: startedAt ?? this.startedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'currentCheckpointId': currentCheckpointId,
      'completedCheckpointIds': jsonEncode(completedCheckpointIds),
      'completionPercent': completionPercent,
      'startedAt': startedAt.toIso8601String(),
      'lastOpenedAt': lastOpenedAt.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
    };
  }

  factory ReadingProgress.fromMap(Map<String, dynamic> map) {
    return ReadingProgress(
      id: map['id'] as int?,
      bookId: map['bookId'] as String,
      currentCheckpointId: map['currentCheckpointId'] as String?,
      completedCheckpointIds: List<String>.from(
        jsonDecode(map['completedCheckpointIds'] as String),
      ),
      completionPercent: (map['completionPercent'] as num).toDouble(),
      startedAt: DateTime.parse(map['startedAt'] as String),
      lastOpenedAt: DateTime.parse(map['lastOpenedAt'] as String),
      finishedAt: map['finishedAt'] != null
          ? DateTime.parse(map['finishedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory ReadingProgress.fromJson(Map<String, dynamic> json) =>
      ReadingProgress.fromMap(json);
}

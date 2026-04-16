class StreakRecord {
  final int? id;
  final String date;
  final int readingMinutes;
  final int checkpointsCompleted;
  final DateTime createdAt;

  const StreakRecord({
    this.id,
    required this.date,
    required this.readingMinutes,
    required this.checkpointsCompleted,
    required this.createdAt,
  });

  StreakRecord copyWith({
    int? id,
    String? date,
    int? readingMinutes,
    int? checkpointsCompleted,
    DateTime? createdAt,
  }) {
    return StreakRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      readingMinutes: readingMinutes ?? this.readingMinutes,
      checkpointsCompleted: checkpointsCompleted ?? this.checkpointsCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'readingMinutes': readingMinutes,
      'checkpointsCompleted': checkpointsCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StreakRecord.fromMap(Map<String, dynamic> map) {
    return StreakRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      readingMinutes: map['readingMinutes'] as int,
      checkpointsCompleted: map['checkpointsCompleted'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory StreakRecord.fromJson(Map<String, dynamic> json) =>
      StreakRecord.fromMap(json);
}

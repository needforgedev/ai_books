class QuizCard {
  final int? id;
  final int savedItemId;
  final String fullText;
  final int blankStart;
  final int blankLength;
  final String correctAnswer;
  final int timesShown;
  final int timesCorrect;
  final DateTime? nextReviewAt;
  final int reviewBucket;
  final DateTime createdAt;

  const QuizCard({
    this.id,
    required this.savedItemId,
    required this.fullText,
    required this.blankStart,
    required this.blankLength,
    required this.correctAnswer,
    this.timesShown = 0,
    this.timesCorrect = 0,
    this.nextReviewAt,
    this.reviewBucket = 0,
    required this.createdAt,
  });

  String get beforeBlank => fullText.substring(0, blankStart);
  String get afterBlank => fullText.substring(blankStart + blankLength);
  // Braces needed — identifiers run into underscores without them
  // ignore: unnecessary_brace_in_string_interps
  String get displayWithBlank => '${beforeBlank}______${afterBlank}';

  double get accuracy =>
      timesShown == 0 ? 0 : timesCorrect / timesShown;

  bool get isDue {
    if (nextReviewAt == null) return true;
    return DateTime.now().isAfter(nextReviewAt!);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'saved_item_id': savedItemId,
        'full_text': fullText,
        'blank_start': blankStart,
        'blank_length': blankLength,
        'correct_answer': correctAnswer,
        'times_shown': timesShown,
        'times_correct': timesCorrect,
        'next_review_at': nextReviewAt?.toIso8601String(),
        'review_bucket': reviewBucket,
        'created_at': createdAt.toIso8601String(),
      };

  factory QuizCard.fromMap(Map<String, dynamic> map) => QuizCard(
        id: map['id'] as int?,
        savedItemId: map['saved_item_id'] as int,
        fullText: map['full_text'] as String,
        blankStart: map['blank_start'] as int,
        blankLength: map['blank_length'] as int,
        correctAnswer: map['correct_answer'] as String,
        timesShown: (map['times_shown'] as int?) ?? 0,
        timesCorrect: (map['times_correct'] as int?) ?? 0,
        nextReviewAt: map['next_review_at'] != null
            ? DateTime.parse(map['next_review_at'] as String)
            : null,
        reviewBucket: (map['review_bucket'] as int?) ?? 0,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

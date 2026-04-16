import 'dart:convert';

class BookEntry {
  final String id;
  final String title;
  final String? subtitle;
  final String author;
  final String categoryId;
  final String difficulty;
  final int estimatedMinutes;
  final String? coverImage;
  final String? introHook;
  final String? whyItMatters;
  final String? shortDescription;
  final List<String> interestTags;
  final List<String> goalTags;
  final List<String> improvementTags;
  final bool isFeatured;
  final List<String> nextBookIds;
  final int sortOrder;

  const BookEntry({
    required this.id,
    required this.title,
    this.subtitle,
    required this.author,
    required this.categoryId,
    required this.difficulty,
    required this.estimatedMinutes,
    this.coverImage,
    this.introHook,
    this.whyItMatters,
    this.shortDescription,
    required this.interestTags,
    required this.goalTags,
    required this.improvementTags,
    required this.isFeatured,
    required this.nextBookIds,
    required this.sortOrder,
  });

  BookEntry copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? author,
    String? categoryId,
    String? difficulty,
    int? estimatedMinutes,
    String? coverImage,
    String? introHook,
    String? whyItMatters,
    String? shortDescription,
    List<String>? interestTags,
    List<String>? goalTags,
    List<String>? improvementTags,
    bool? isFeatured,
    List<String>? nextBookIds,
    int? sortOrder,
  }) {
    return BookEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      author: author ?? this.author,
      categoryId: categoryId ?? this.categoryId,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      coverImage: coverImage ?? this.coverImage,
      introHook: introHook ?? this.introHook,
      whyItMatters: whyItMatters ?? this.whyItMatters,
      shortDescription: shortDescription ?? this.shortDescription,
      interestTags: interestTags ?? this.interestTags,
      goalTags: goalTags ?? this.goalTags,
      improvementTags: improvementTags ?? this.improvementTags,
      isFeatured: isFeatured ?? this.isFeatured,
      nextBookIds: nextBookIds ?? this.nextBookIds,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'author': author,
      'categoryId': categoryId,
      'difficulty': difficulty,
      'estimatedMinutes': estimatedMinutes,
      'coverImage': coverImage,
      'introHook': introHook,
      'whyItMatters': whyItMatters,
      'shortDescription': shortDescription,
      'interestTags': jsonEncode(interestTags),
      'goalTags': jsonEncode(goalTags),
      'improvementTags': jsonEncode(improvementTags),
      'isFeatured': isFeatured ? 1 : 0,
      'nextBookIds': jsonEncode(nextBookIds),
      'sortOrder': sortOrder,
    };
  }

  factory BookEntry.fromMap(Map<String, dynamic> map) {
    return BookEntry(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String?,
      author: map['author'] as String,
      categoryId: map['categoryId'] as String,
      difficulty: map['difficulty'] as String,
      estimatedMinutes: map['estimatedMinutes'] as int,
      coverImage: map['coverImage'] as String?,
      introHook: map['introHook'] as String?,
      whyItMatters: map['whyItMatters'] as String?,
      shortDescription: map['shortDescription'] as String?,
      interestTags:
          List<String>.from(jsonDecode(map['interestTags'] as String)),
      goalTags: List<String>.from(jsonDecode(map['goalTags'] as String)),
      improvementTags:
          List<String>.from(jsonDecode(map['improvementTags'] as String)),
      isFeatured: (map['isFeatured'] as int) == 1,
      nextBookIds:
          List<String>.from(jsonDecode(map['nextBookIds'] as String)),
      sortOrder: map['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory BookEntry.fromJson(Map<String, dynamic> json) =>
      BookEntry.fromMap(json);
}

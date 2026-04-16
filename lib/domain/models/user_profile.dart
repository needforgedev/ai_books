import 'dart:convert';

class UserProfile {
  final int id;
  final String? displayName;
  final List<String> selectedInterests;
  final List<String> selectedGoals;
  final List<String> selectedImprovementAreas;
  final String readingComfort;
  final int dailyTimePreference;
  final int streakGoal;
  final bool notificationOptIn;
  final DateTime? onboardingCompletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    this.displayName,
    required this.selectedInterests,
    required this.selectedGoals,
    required this.selectedImprovementAreas,
    required this.readingComfort,
    required this.dailyTimePreference,
    required this.streakGoal,
    required this.notificationOptIn,
    this.onboardingCompletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    int? id,
    String? displayName,
    List<String>? selectedInterests,
    List<String>? selectedGoals,
    List<String>? selectedImprovementAreas,
    String? readingComfort,
    int? dailyTimePreference,
    int? streakGoal,
    bool? notificationOptIn,
    DateTime? onboardingCompletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      selectedGoals: selectedGoals ?? this.selectedGoals,
      selectedImprovementAreas:
          selectedImprovementAreas ?? this.selectedImprovementAreas,
      readingComfort: readingComfort ?? this.readingComfort,
      dailyTimePreference: dailyTimePreference ?? this.dailyTimePreference,
      streakGoal: streakGoal ?? this.streakGoal,
      notificationOptIn: notificationOptIn ?? this.notificationOptIn,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'selectedInterests': jsonEncode(selectedInterests),
      'selectedGoals': jsonEncode(selectedGoals),
      'selectedImprovementAreas': jsonEncode(selectedImprovementAreas),
      'readingComfort': readingComfort,
      'dailyTimePreference': dailyTimePreference,
      'streakGoal': streakGoal,
      'notificationOptIn': notificationOptIn ? 1 : 0,
      'onboardingCompletedAt': onboardingCompletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int,
      displayName: map['displayName'] as String?,
      selectedInterests:
          List<String>.from(jsonDecode(map['selectedInterests'] as String)),
      selectedGoals:
          List<String>.from(jsonDecode(map['selectedGoals'] as String)),
      selectedImprovementAreas: List<String>.from(
        jsonDecode(map['selectedImprovementAreas'] as String),
      ),
      readingComfort: map['readingComfort'] as String,
      dailyTimePreference: map['dailyTimePreference'] as int,
      streakGoal: map['streakGoal'] as int,
      notificationOptIn: (map['notificationOptIn'] as int) == 1,
      onboardingCompletedAt: map['onboardingCompletedAt'] != null
          ? DateTime.parse(map['onboardingCompletedAt'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      UserProfile.fromMap(json);
}

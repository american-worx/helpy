import 'package:hive/hive.dart';

part 'user.g.dart';

/// User entity representing an authenticated user
@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String? profileImageUrl;
  @HiveField(4)
  final UserPreferences preferences;
  @HiveField(5)
  final DateTime createdAt;
  @HiveField(6)
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    required this.preferences,
    required this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'preferences': preferences.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      profileImageUrl: json['profileImageUrl'],
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email)';
  }
}

/// User preferences and settings
@HiveType(typeId: 1)
class UserPreferences {
  @HiveField(0)
  final String locale;
  @HiveField(1)
  final bool isDarkMode;
  @HiveField(2)
  final bool notificationsEnabled;
  @HiveField(3)
  final bool soundEnabled;
  @HiveField(4)
  final bool hapticFeedbackEnabled;
  @HiveField(5)
  final String preferredHelpyPersonality;
  @HiveField(6)
  final List<String> subjects;
  @HiveField(7)
  final String gradeLevel;
  @HiveField(8)
  final String learningStyle;
  @HiveField(9)
  final String curriculum;
  @HiveField(10)
  final bool offlineMode;

  const UserPreferences({
    this.locale = 'en',
    this.isDarkMode = true, // Default to dark mode for tech users
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.preferredHelpyPersonality = 'friendly',
    this.subjects = const [],
    this.gradeLevel = 'grade_9',
    this.learningStyle = 'mixed',
    this.curriculum = 'commonCore',
    this.offlineMode = false,
  });

  UserPreferences copyWith({
    String? locale,
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? hapticFeedbackEnabled,
    String? preferredHelpyPersonality,
    List<String>? subjects,
    String? gradeLevel,
    String? learningStyle,
    String? curriculum,
    bool? offlineMode,
  }) {
    return UserPreferences(
      locale: locale ?? this.locale,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      preferredHelpyPersonality:
          preferredHelpyPersonality ?? this.preferredHelpyPersonality,
      subjects: subjects ?? this.subjects,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      learningStyle: learningStyle ?? this.learningStyle,
      curriculum: curriculum ?? this.curriculum,
      offlineMode: offlineMode ?? this.offlineMode,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'preferredHelpyPersonality': preferredHelpyPersonality,
      'subjects': subjects,
      'gradeLevel': gradeLevel,
      'learningStyle': learningStyle,
      'curriculum': curriculum,
      'offlineMode': offlineMode,
    };
  }

  /// Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      locale: json['locale'] ?? 'en',
      isDarkMode: json['isDarkMode'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] ?? true,
      preferredHelpyPersonality:
          json['preferredHelpyPersonality'] ?? 'friendly',
      subjects: List<String>.from(json['subjects'] ?? []),
      gradeLevel: json['gradeLevel'] ?? 'grade_9',
      learningStyle: json['learningStyle'] ?? 'mixed',
      curriculum: json['curriculum'] ?? 'commonCore',
      offlineMode: json['offlineMode'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
        other.locale == locale &&
        other.isDarkMode == isDarkMode &&
        other.notificationsEnabled == notificationsEnabled &&
        other.soundEnabled == soundEnabled &&
        other.hapticFeedbackEnabled == hapticFeedbackEnabled &&
        other.preferredHelpyPersonality == preferredHelpyPersonality &&
        other.subjects.toString() == subjects.toString() &&
        other.gradeLevel == gradeLevel &&
        other.learningStyle == learningStyle &&
        other.curriculum == curriculum &&
        other.offlineMode == offlineMode;
  }

  @override
  int get hashCode {
    return Object.hash(
      locale,
      isDarkMode,
      notificationsEnabled,
      soundEnabled,
      hapticFeedbackEnabled,
      preferredHelpyPersonality,
      subjects,
      gradeLevel,
      learningStyle,
      curriculum,
      offlineMode,
    );
  }

  @override
  String toString() {
    return 'UserPreferences(locale: $locale, isDarkMode: $isDarkMode, subjects: $subjects)';
  }
}

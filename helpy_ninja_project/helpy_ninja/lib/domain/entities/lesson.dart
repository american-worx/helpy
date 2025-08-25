import 'shared_enums.dart';

/// Lesson entity representing learning content
class Lesson {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String content;
  final LessonType type;
  final DifficultyLevel difficulty;
  final int estimatedDuration; // in minutes
  final List<String> prerequisites;
  final List<String> learningObjectives;
  final List<LessonSection> sections;
  final List<String> tags;
  final Map<String, dynamic>? metadata;
  final LessonStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final String? videoUrl;
  final bool isPublished;
  final int orderIndex;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.subjectId,
    required this.content,
    required this.type,
    this.difficulty = DifficultyLevel.beginner,
    this.estimatedDuration = 15,
    this.prerequisites = const [],
    this.learningObjectives = const [],
    this.sections = const [],
    this.tags = const [],
    this.metadata,
    this.status = LessonStatus.draft,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.videoUrl,
    this.isPublished = false,
    this.orderIndex = 0,
  });

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? subjectId,
    String? content,
    LessonType? type,
    DifficultyLevel? difficulty,
    int? estimatedDuration,
    List<String>? prerequisites,
    List<String>? learningObjectives,
    List<LessonSection>? sections,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    LessonStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    String? videoUrl,
    bool? isPublished,
    int? orderIndex,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      content: content ?? this.content,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      prerequisites: prerequisites ?? this.prerequisites,
      learningObjectives: learningObjectives ?? this.learningObjectives,
      sections: sections ?? this.sections,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isPublished: isPublished ?? this.isPublished,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  /// Get formatted duration string
  String get formattedDuration {
    if (estimatedDuration < 60) {
      return '${estimatedDuration}m';
    } else {
      final hours = estimatedDuration ~/ 60;
      final minutes = estimatedDuration % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  /// Get difficulty color
  String get difficultyColor {
    switch (difficulty) {
      case DifficultyLevel.beginner:
        return '#4CAF50'; // Green
      case DifficultyLevel.intermediate:
        return '#FF9800'; // Orange
      case DifficultyLevel.advanced:
        return '#F44336'; // Red
      case DifficultyLevel.expert:
        return '#9C27B0'; // Purple
    }
  }

  /// Get lesson type icon
  String get typeIcon {
    switch (type) {
      case LessonType.reading:
        return '📖';
      case LessonType.video:
        return '🎥';
      case LessonType.interactive:
        return '🎮';
      case LessonType.quiz:
        return '❓';
      case LessonType.practice:
        return '✏️';
      case LessonType.project:
        return '🚀';
    }
  }

  /// Check if lesson is available (prerequisites met)
  bool isAvailable(List<String> completedLessonIds) {
    if (prerequisites.isEmpty) return true;
    return prerequisites.every((prereq) => completedLessonIds.contains(prereq));
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'content': content,
      'type': type.name,
      'difficulty': difficulty.name,
      'estimatedDuration': estimatedDuration,
      'prerequisites': prerequisites,
      'learningObjectives': learningObjectives,
      'sections': sections.map((section) => section.toJson()).toList(),
      'tags': tags,
      'metadata': metadata,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'isPublished': isPublished,
      'orderIndex': orderIndex,
    };
  }

  /// Create from JSON
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subjectId: json['subjectId'] ?? '',
      content: json['content'] ?? '',
      type: LessonType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => LessonType.reading,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (level) => level.name == json['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      estimatedDuration: json['estimatedDuration'] ?? 15,
      prerequisites: List<String>.from(json['prerequisites'] ?? []),
      learningObjectives: List<String>.from(json['learningObjectives'] ?? []),
      sections:
          (json['sections'] as List?)
              ?.map((section) => LessonSection.fromJson(section))
              .toList() ??
          [],
      tags: List<String>.from(json['tags'] ?? []),
      metadata: json['metadata'],
      status: LessonStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => LessonStatus.draft,
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      isPublished: json['isPublished'] ?? false,
      orderIndex: json['orderIndex'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lesson && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Lesson(id: $id, title: $title, type: $type, difficulty: $difficulty)';
  }
}

/// Types of lessons
enum LessonType {
  reading, // Text-based lessons
  video, // Video content
  interactive, // Interactive exercises
  quiz, // Quiz/assessment
  practice, // Practice problems
  project, // Project-based learning
}

/// Lesson status
enum LessonStatus {
  draft, // Being created
  review, // Under review
  published, // Live and available
  archived, // No longer active
}

/// Lesson section for organizing content
class LessonSection {
  final String id;
  final String title;
  final String content;
  final LessonSectionType type;
  final int orderIndex;
  final Map<String, dynamic>? metadata;

  const LessonSection({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.orderIndex = 0,
    this.metadata,
  });

  LessonSection copyWith({
    String? id,
    String? title,
    String? content,
    LessonSectionType? type,
    int? orderIndex,
    Map<String, dynamic>? metadata,
  }) {
    return LessonSection(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      orderIndex: orderIndex ?? this.orderIndex,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.name,
      'orderIndex': orderIndex,
      'metadata': metadata,
    };
  }

  factory LessonSection.fromJson(Map<String, dynamic> json) {
    return LessonSection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: LessonSectionType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => LessonSectionType.text,
      ),
      orderIndex: json['orderIndex'] ?? 0,
      metadata: json['metadata'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LessonSection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Types of lesson sections
enum LessonSectionType {
  text, // Text content
  image, // Image content
  video, // Video content
  audio, // Audio content
  code, // Code examples
  exercise, // Interactive exercise
  quiz, // Quiz questions
}

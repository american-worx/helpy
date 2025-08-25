import 'shared_enums.dart';

/// Quiz question entity for assessments and practice
class QuizQuestion {
  final String id;
  final String lessonId;
  final String question;
  final QuestionType type;
  final List<QuestionOption> options;
  final List<String> correctAnswers; // IDs of correct options
  final String? explanation;
  final String? hint;
  final DifficultyLevel difficulty;
  final int points;
  final int timeLimit; // in seconds, 0 = no limit
  final Map<String, dynamic>? metadata;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const QuizQuestion({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.type,
    this.options = const [],
    this.correctAnswers = const [],
    this.explanation,
    this.hint,
    this.difficulty = DifficultyLevel.beginner,
    this.points = 1,
    this.timeLimit = 0,
    this.metadata,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  QuizQuestion copyWith({
    String? id,
    String? lessonId,
    String? question,
    QuestionType? type,
    List<QuestionOption>? options,
    List<String>? correctAnswers,
    String? explanation,
    String? hint,
    DifficultyLevel? difficulty,
    int? points,
    int? timeLimit,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      question: question ?? this.question,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      explanation: explanation ?? this.explanation,
      hint: hint ?? this.hint,
      difficulty: difficulty ?? this.difficulty,
      points: points ?? this.points,
      timeLimit: timeLimit ?? this.timeLimit,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Check if answer is correct
  bool isCorrectAnswer(List<String> answerIds) {
    if (correctAnswers.isEmpty) return false;

    // For single choice, check exact match
    if (type == QuestionType.singleChoice) {
      return answerIds.length == 1 &&
          correctAnswers.length == 1 &&
          answerIds.first == correctAnswers.first;
    }

    // For multiple choice, check all correct answers are selected
    if (type == QuestionType.multipleChoice) {
      return answerIds.length == correctAnswers.length &&
          answerIds.every((id) => correctAnswers.contains(id));
    }

    // For text questions, compare normalized strings
    if (type == QuestionType.text || type == QuestionType.shortAnswer) {
      if (answerIds.isEmpty || correctAnswers.isEmpty) return false;
      final userAnswer = answerIds.first.toLowerCase().trim();
      return correctAnswers.any(
        (correct) => correct.toLowerCase().trim() == userAnswer,
      );
    }

    return false;
  }

  /// Get partial credit score (0.0 to 1.0)
  double getPartialScore(List<String> answerIds) {
    if (isCorrectAnswer(answerIds)) return 1.0;

    if (type == QuestionType.multipleChoice && correctAnswers.isNotEmpty) {
      final correctSelected = answerIds
          .where((id) => correctAnswers.contains(id))
          .length;
      final incorrectSelected = answerIds
          .where((id) => !correctAnswers.contains(id))
          .length;

      // Partial credit: correct selections minus incorrect selections
      final score =
          (correctSelected - incorrectSelected) / correctAnswers.length;
      return score.clamp(0.0, 1.0);
    }

    return 0.0;
  }

  /// Get question type icon
  String get typeIcon {
    switch (type) {
      case QuestionType.singleChoice:
        return '⚪';
      case QuestionType.multipleChoice:
        return '☑️';
      case QuestionType.text:
        return '✏️';
      case QuestionType.shortAnswer:
        return '📝';
      case QuestionType.trueFalse:
        return '✅❌';
      case QuestionType.matching:
        return '🔗';
      case QuestionType.ordering:
        return '📋';
      case QuestionType.fillInBlank:
        return '___';
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

  /// Get formatted time limit
  String get formattedTimeLimit {
    if (timeLimit <= 0) return 'No limit';

    final minutes = timeLimit ~/ 60;
    final seconds = timeLimit % 60;

    if (minutes > 0) {
      return seconds > 0 ? '${minutes}m ${seconds}s' : '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'question': question,
      'type': type.name,
      'options': options.map((option) => option.toJson()).toList(),
      'correctAnswers': correctAnswers,
      'explanation': explanation,
      'hint': hint,
      'difficulty': difficulty.name,
      'points': points,
      'timeLimit': timeLimit,
      'metadata': metadata,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? '',
      lessonId: json['lessonId'] ?? '',
      question: json['question'] ?? '',
      type: QuestionType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => QuestionType.singleChoice,
      ),
      options:
          (json['options'] as List?)
              ?.map((option) => QuestionOption.fromJson(option))
              .toList() ??
          [],
      correctAnswers: List<String>.from(json['correctAnswers'] ?? []),
      explanation: json['explanation'],
      hint: json['hint'],
      difficulty: DifficultyLevel.values.firstWhere(
        (level) => level.name == json['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      points: json['points'] ?? 1,
      timeLimit: json['timeLimit'] ?? 0,
      metadata: json['metadata'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizQuestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuizQuestion(id: $id, type: $type, difficulty: $difficulty, points: $points)';
  }
}

/// Question option for multiple choice questions
class QuestionOption {
  final String id;
  final String text;
  final String? imageUrl;
  final bool isCorrect;
  final String? explanation;
  final Map<String, dynamic>? metadata;

  const QuestionOption({
    required this.id,
    required this.text,
    this.imageUrl,
    this.isCorrect = false,
    this.explanation,
    this.metadata,
  });

  QuestionOption copyWith({
    String? id,
    String? text,
    String? imageUrl,
    bool? isCorrect,
    String? explanation,
    Map<String, dynamic>? metadata,
  }) {
    return QuestionOption(
      id: id ?? this.id,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      isCorrect: isCorrect ?? this.isCorrect,
      explanation: explanation ?? this.explanation,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'imageUrl': imageUrl,
      'isCorrect': isCorrect,
      'explanation': explanation,
      'metadata': metadata,
    };
  }

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      imageUrl: json['imageUrl'],
      isCorrect: json['isCorrect'] ?? false,
      explanation: json['explanation'],
      metadata: json['metadata'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionOption && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Types of quiz questions
enum QuestionType {
  singleChoice, // Single correct option
  multipleChoice, // Multiple correct options
  text, // Free text answer
  shortAnswer, // Short text answer
  trueFalse, // True/False question
  matching, // Match items
  ordering, // Put items in order
  fillInBlank, // Fill in the blanks
}

/// Question answer for tracking user responses
class QuestionAnswer {
  final String id;
  final String questionId;
  final String userId;
  final String sessionId;
  final List<String> answerIds; // Selected option IDs or text answers
  final String? textAnswer; // For text-based questions
  final bool isCorrect;
  final double score;
  final Duration timeToAnswer;
  final int hintsUsed;
  final DateTime answeredAt;
  final Map<String, dynamic>? metadata;

  const QuestionAnswer({
    required this.id,
    required this.questionId,
    required this.userId,
    required this.sessionId,
    this.answerIds = const [],
    this.textAnswer,
    this.isCorrect = false,
    this.score = 0.0,
    this.timeToAnswer = Duration.zero,
    this.hintsUsed = 0,
    required this.answeredAt,
    this.metadata,
  });

  QuestionAnswer copyWith({
    String? id,
    String? questionId,
    String? userId,
    String? sessionId,
    List<String>? answerIds,
    String? textAnswer,
    bool? isCorrect,
    double? score,
    Duration? timeToAnswer,
    int? hintsUsed,
    DateTime? answeredAt,
    Map<String, dynamic>? metadata,
  }) {
    return QuestionAnswer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      answerIds: answerIds ?? this.answerIds,
      textAnswer: textAnswer ?? this.textAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      score: score ?? this.score,
      timeToAnswer: timeToAnswer ?? this.timeToAnswer,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      answeredAt: answeredAt ?? this.answeredAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'userId': userId,
      'sessionId': sessionId,
      'answerIds': answerIds,
      'textAnswer': textAnswer,
      'isCorrect': isCorrect,
      'score': score,
      'timeToAnswer': timeToAnswer.inSeconds,
      'hintsUsed': hintsUsed,
      'answeredAt': answeredAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionAnswer(
      id: json['id'] ?? '',
      questionId: json['questionId'] ?? '',
      userId: json['userId'] ?? '',
      sessionId: json['sessionId'] ?? '',
      answerIds: List<String>.from(json['answerIds'] ?? []),
      textAnswer: json['textAnswer'],
      isCorrect: json['isCorrect'] ?? false,
      score: (json['score'] ?? 0.0).toDouble(),
      timeToAnswer: Duration(seconds: json['timeToAnswer'] ?? 0),
      hintsUsed: json['hintsUsed'] ?? 0,
      answeredAt: DateTime.parse(
        json['answeredAt'] ?? DateTime.now().toIso8601String(),
      ),
      metadata: json['metadata'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuestionAnswer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'QuestionAnswer(id: $id, questionId: $questionId, isCorrect: $isCorrect, score: $score)';
  }
}

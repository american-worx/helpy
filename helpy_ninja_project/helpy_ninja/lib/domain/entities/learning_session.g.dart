// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LearningSessionAdapter extends TypeAdapter<LearningSession> {
  @override
  final int typeId = 15;

  @override
  LearningSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LearningSession(
      id: fields[0] as String,
      userId: fields[1] as String,
      lessonId: fields[2] as String,
      type: fields[3] as SessionType,
      status: fields[4] as SessionStatus,
      startedAt: fields[5] as DateTime,
      completedAt: fields[6] as DateTime?,
      pausedAt: fields[7] as DateTime?,
      totalTimeSpent: fields[8] as Duration,
      progressPercentage: fields[9] as double,
      currentSectionIndex: fields[10] as int,
      sessionData: (fields[11] as Map).cast<String, dynamic>(),
      events: (fields[12] as List).cast<SessionEvent>(),
      score: fields[13] as SessionScore?,
      metadata: (fields[14] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, LearningSession obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.lessonId)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.startedAt)
      ..writeByte(6)
      ..write(obj.completedAt)
      ..writeByte(7)
      ..write(obj.pausedAt)
      ..writeByte(8)
      ..write(obj.totalTimeSpent)
      ..writeByte(9)
      ..write(obj.progressPercentage)
      ..writeByte(10)
      ..write(obj.currentSectionIndex)
      ..writeByte(11)
      ..write(obj.sessionData)
      ..writeByte(12)
      ..write(obj.events)
      ..writeByte(13)
      ..write(obj.score)
      ..writeByte(14)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionEventAdapter extends TypeAdapter<SessionEvent> {
  @override
  final int typeId = 18;

  @override
  SessionEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionEvent(
      id: fields[0] as String,
      type: fields[1] as SessionEventType,
      timestamp: fields[2] as DateTime,
      data: (fields[3] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SessionEvent obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionScoreAdapter extends TypeAdapter<SessionScore> {
  @override
  final int typeId = 28;

  @override
  SessionScore read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionScore(
      totalScore: fields[0] as double,
      maxScore: fields[1] as double,
      correctAnswers: fields[2] as int,
      totalAnswers: fields[3] as int,
      hintsUsed: fields[4] as int,
      timeToComplete: fields[5] as Duration,
      sectionScores: (fields[6] as Map).cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, SessionScore obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.totalScore)
      ..writeByte(1)
      ..write(obj.maxScore)
      ..writeByte(2)
      ..write(obj.correctAnswers)
      ..writeByte(3)
      ..write(obj.totalAnswers)
      ..writeByte(4)
      ..write(obj.hintsUsed)
      ..writeByte(5)
      ..write(obj.timeToComplete)
      ..writeByte(6)
      ..write(obj.sectionScores);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionScoreAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionTypeAdapter extends TypeAdapter<SessionType> {
  @override
  final int typeId = 16;

  @override
  SessionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SessionType.lesson;
      case 1:
        return SessionType.practice;
      case 2:
        return SessionType.quiz;
      case 3:
        return SessionType.review;
      case 4:
        return SessionType.project;
      default:
        return SessionType.lesson;
    }
  }

  @override
  void write(BinaryWriter writer, SessionType obj) {
    switch (obj) {
      case SessionType.lesson:
        writer.writeByte(0);
        break;
      case SessionType.practice:
        writer.writeByte(1);
        break;
      case SessionType.quiz:
        writer.writeByte(2);
        break;
      case SessionType.review:
        writer.writeByte(3);
        break;
      case SessionType.project:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionStatusAdapter extends TypeAdapter<SessionStatus> {
  @override
  final int typeId = 17;

  @override
  SessionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SessionStatus.active;
      case 1:
        return SessionStatus.paused;
      case 2:
        return SessionStatus.completed;
      case 3:
        return SessionStatus.abandoned;
      case 4:
        return SessionStatus.expired;
      default:
        return SessionStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, SessionStatus obj) {
    switch (obj) {
      case SessionStatus.active:
        writer.writeByte(0);
        break;
      case SessionStatus.paused:
        writer.writeByte(1);
        break;
      case SessionStatus.completed:
        writer.writeByte(2);
        break;
      case SessionStatus.abandoned:
        writer.writeByte(3);
        break;
      case SessionStatus.expired:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionEventTypeAdapter extends TypeAdapter<SessionEventType> {
  @override
  final int typeId = 19;

  @override
  SessionEventType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SessionEventType.start;
      case 1:
        return SessionEventType.pause;
      case 2:
        return SessionEventType.resume;
      case 3:
        return SessionEventType.complete;
      case 4:
        return SessionEventType.sectionStart;
      case 5:
        return SessionEventType.sectionComplete;
      case 6:
        return SessionEventType.interaction;
      case 7:
        return SessionEventType.answer;
      case 8:
        return SessionEventType.hint;
      case 9:
        return SessionEventType.error;
      default:
        return SessionEventType.start;
    }
  }

  @override
  void write(BinaryWriter writer, SessionEventType obj) {
    switch (obj) {
      case SessionEventType.start:
        writer.writeByte(0);
        break;
      case SessionEventType.pause:
        writer.writeByte(1);
        break;
      case SessionEventType.resume:
        writer.writeByte(2);
        break;
      case SessionEventType.complete:
        writer.writeByte(3);
        break;
      case SessionEventType.sectionStart:
        writer.writeByte(4);
        break;
      case SessionEventType.sectionComplete:
        writer.writeByte(5);
        break;
      case SessionEventType.interaction:
        writer.writeByte(6);
        break;
      case SessionEventType.answer:
        writer.writeByte(7);
        break;
      case SessionEventType.hint:
        writer.writeByte(8);
        break;
      case SessionEventType.error:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionEventTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

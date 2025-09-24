// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LessonAdapter extends TypeAdapter<Lesson> {
  @override
  final int typeId = 10;

  @override
  Lesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lesson(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      subjectId: fields[3] as String,
      content: fields[4] as String,
      type: fields[5] as LessonType,
      difficulty: fields[6] as DifficultyLevel,
      estimatedDuration: fields[7] as int,
      prerequisites: (fields[8] as List).cast<String>(),
      learningObjectives: (fields[9] as List).cast<String>(),
      sections: (fields[10] as List).cast<LessonSection>(),
      tags: (fields[11] as List).cast<String>(),
      metadata: (fields[12] as Map?)?.cast<String, dynamic>(),
      status: fields[13] as LessonStatus,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime?,
      imageUrl: fields[16] as String?,
      videoUrl: fields[17] as String?,
      isPublished: fields[18] as bool,
      orderIndex: fields[19] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Lesson obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.subjectId)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.estimatedDuration)
      ..writeByte(8)
      ..write(obj.prerequisites)
      ..writeByte(9)
      ..write(obj.learningObjectives)
      ..writeByte(10)
      ..write(obj.sections)
      ..writeByte(11)
      ..write(obj.tags)
      ..writeByte(12)
      ..write(obj.metadata)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.imageUrl)
      ..writeByte(17)
      ..write(obj.videoUrl)
      ..writeByte(18)
      ..write(obj.isPublished)
      ..writeByte(19)
      ..write(obj.orderIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonSectionAdapter extends TypeAdapter<LessonSection> {
  @override
  final int typeId = 13;

  @override
  LessonSection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonSection(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      type: fields[3] as LessonSectionType,
      orderIndex: fields[4] as int,
      metadata: (fields[5] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, LessonSection obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.orderIndex)
      ..writeByte(5)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonSectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonTypeAdapter extends TypeAdapter<LessonType> {
  @override
  final int typeId = 11;

  @override
  LessonType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LessonType.reading;
      case 1:
        return LessonType.video;
      case 2:
        return LessonType.interactive;
      case 3:
        return LessonType.quiz;
      case 4:
        return LessonType.practice;
      case 5:
        return LessonType.project;
      default:
        return LessonType.reading;
    }
  }

  @override
  void write(BinaryWriter writer, LessonType obj) {
    switch (obj) {
      case LessonType.reading:
        writer.writeByte(0);
        break;
      case LessonType.video:
        writer.writeByte(1);
        break;
      case LessonType.interactive:
        writer.writeByte(2);
        break;
      case LessonType.quiz:
        writer.writeByte(3);
        break;
      case LessonType.practice:
        writer.writeByte(4);
        break;
      case LessonType.project:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonStatusAdapter extends TypeAdapter<LessonStatus> {
  @override
  final int typeId = 12;

  @override
  LessonStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LessonStatus.draft;
      case 1:
        return LessonStatus.review;
      case 2:
        return LessonStatus.published;
      case 3:
        return LessonStatus.archived;
      default:
        return LessonStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, LessonStatus obj) {
    switch (obj) {
      case LessonStatus.draft:
        writer.writeByte(0);
        break;
      case LessonStatus.review:
        writer.writeByte(1);
        break;
      case LessonStatus.published:
        writer.writeByte(2);
        break;
      case LessonStatus.archived:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonSectionTypeAdapter extends TypeAdapter<LessonSectionType> {
  @override
  final int typeId = 14;

  @override
  LessonSectionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LessonSectionType.text;
      case 1:
        return LessonSectionType.image;
      case 2:
        return LessonSectionType.video;
      case 3:
        return LessonSectionType.audio;
      case 4:
        return LessonSectionType.code;
      case 5:
        return LessonSectionType.exercise;
      case 6:
        return LessonSectionType.quiz;
      default:
        return LessonSectionType.text;
    }
  }

  @override
  void write(BinaryWriter writer, LessonSectionType obj) {
    switch (obj) {
      case LessonSectionType.text:
        writer.writeByte(0);
        break;
      case LessonSectionType.image:
        writer.writeByte(1);
        break;
      case LessonSectionType.video:
        writer.writeByte(2);
        break;
      case LessonSectionType.audio:
        writer.writeByte(3);
        break;
      case LessonSectionType.code:
        writer.writeByte(4);
        break;
      case LessonSectionType.exercise:
        writer.writeByte(5);
        break;
      case LessonSectionType.quiz:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonSectionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

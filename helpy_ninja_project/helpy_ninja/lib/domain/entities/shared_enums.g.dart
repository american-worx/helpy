// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageReactionAdapter extends TypeAdapter<MessageReaction> {
  @override
  final int typeId = 26;

  @override
  MessageReaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageReaction(
      emoji: fields[0] as String,
      userIds: (fields[1] as List).cast<String>(),
      count: fields[2] as int,
      timestamp: fields[3] as DateTime?,
      userName: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MessageReaction obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.emoji)
      ..writeByte(1)
      ..write(obj.userIds)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.userName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageReactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CompressionInfoAdapter extends TypeAdapter<CompressionInfo> {
  @override
  final int typeId = 27;

  @override
  CompressionInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompressionInfo(
      originalSize: fields[0] as int,
      compressedSize: fields[1] as int,
      compressionRatio: fields[2] as double,
      algorithm: fields[3] as String,
      processingTime: fields[4] as Duration,
      metadata: (fields[5] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, CompressionInfo obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.originalSize)
      ..writeByte(1)
      ..write(obj.compressedSize)
      ..writeByte(2)
      ..write(obj.compressionRatio)
      ..writeByte(3)
      ..write(obj.algorithm)
      ..writeByte(4)
      ..write(obj.processingTime)
      ..writeByte(5)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompressionInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyLevelAdapter extends TypeAdapter<DifficultyLevel> {
  @override
  final int typeId = 20;

  @override
  DifficultyLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DifficultyLevel.beginner;
      case 1:
        return DifficultyLevel.intermediate;
      case 2:
        return DifficultyLevel.advanced;
      case 3:
        return DifficultyLevel.expert;
      default:
        return DifficultyLevel.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, DifficultyLevel obj) {
    switch (obj) {
      case DifficultyLevel.beginner:
        writer.writeByte(0);
        break;
      case DifficultyLevel.intermediate:
        writer.writeByte(1);
        break;
      case DifficultyLevel.advanced:
        writer.writeByte(2);
        break;
      case DifficultyLevel.expert:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 21;

  @override
  ThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ThemeMode.light;
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    switch (obj) {
      case ThemeMode.light:
        writer.writeByte(0);
        break;
      case ThemeMode.dark:
        writer.writeByte(1);
        break;
      case ThemeMode.system:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttachmentTypeAdapter extends TypeAdapter<AttachmentType> {
  @override
  final int typeId = 22;

  @override
  AttachmentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AttachmentType.image;
      case 1:
        return AttachmentType.video;
      case 2:
        return AttachmentType.audio;
      case 3:
        return AttachmentType.document;
      case 4:
        return AttachmentType.file;
      default:
        return AttachmentType.image;
    }
  }

  @override
  void write(BinaryWriter writer, AttachmentType obj) {
    switch (obj) {
      case AttachmentType.image:
        writer.writeByte(0);
        break;
      case AttachmentType.video:
        writer.writeByte(1);
        break;
      case AttachmentType.audio:
        writer.writeByte(2);
        break;
      case AttachmentType.document:
        writer.writeByte(3);
        break;
      case AttachmentType.file:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttachmentStatusAdapter extends TypeAdapter<AttachmentStatus> {
  @override
  final int typeId = 23;

  @override
  AttachmentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AttachmentStatus.uploading;
      case 1:
        return AttachmentStatus.uploaded;
      case 2:
        return AttachmentStatus.failed;
      case 3:
        return AttachmentStatus.processing;
      case 4:
        return AttachmentStatus.compressed;
      case 5:
        return AttachmentStatus.encrypted;
      default:
        return AttachmentStatus.uploading;
    }
  }

  @override
  void write(BinaryWriter writer, AttachmentStatus obj) {
    switch (obj) {
      case AttachmentStatus.uploading:
        writer.writeByte(0);
        break;
      case AttachmentStatus.uploaded:
        writer.writeByte(1);
        break;
      case AttachmentStatus.failed:
        writer.writeByte(2);
        break;
      case AttachmentStatus.processing:
        writer.writeByte(3);
        break;
      case AttachmentStatus.compressed:
        writer.writeByte(4);
        break;
      case AttachmentStatus.encrypted:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttachmentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessagePriorityAdapter extends TypeAdapter<MessagePriority> {
  @override
  final int typeId = 24;

  @override
  MessagePriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessagePriority.low;
      case 1:
        return MessagePriority.normal;
      case 2:
        return MessagePriority.high;
      case 3:
        return MessagePriority.urgent;
      default:
        return MessagePriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, MessagePriority obj) {
    switch (obj) {
      case MessagePriority.low:
        writer.writeByte(0);
        break;
      case MessagePriority.normal:
        writer.writeByte(1);
        break;
      case MessagePriority.high:
        writer.writeByte(2);
        break;
      case MessagePriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagePriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageDeliveryStatusAdapter extends TypeAdapter<MessageDeliveryStatus> {
  @override
  final int typeId = 25;

  @override
  MessageDeliveryStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageDeliveryStatus.sending;
      case 1:
        return MessageDeliveryStatus.sent;
      case 2:
        return MessageDeliveryStatus.delivered;
      case 3:
        return MessageDeliveryStatus.read;
      case 4:
        return MessageDeliveryStatus.failed;
      case 5:
        return MessageDeliveryStatus.acknowledged;
      default:
        return MessageDeliveryStatus.sending;
    }
  }

  @override
  void write(BinaryWriter writer, MessageDeliveryStatus obj) {
    switch (obj) {
      case MessageDeliveryStatus.sending:
        writer.writeByte(0);
        break;
      case MessageDeliveryStatus.sent:
        writer.writeByte(1);
        break;
      case MessageDeliveryStatus.delivered:
        writer.writeByte(2);
        break;
      case MessageDeliveryStatus.read:
        writer.writeByte(3);
        break;
      case MessageDeliveryStatus.failed:
        writer.writeByte(4);
        break;
      case MessageDeliveryStatus.acknowledged:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageDeliveryStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

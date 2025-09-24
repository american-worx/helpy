// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConversationAdapter extends TypeAdapter<Conversation> {
  @override
  final int typeId = 6;

  @override
  Conversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Conversation(
      id: fields[0] as String,
      title: fields[1] as String,
      userId: fields[2] as String,
      helpyPersonalityId: fields[3] as String,
      type: fields[4] as ConversationType,
      status: fields[5] as ConversationStatus,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      lastMessageId: fields[8] as String?,
      lastMessagePreview: fields[9] as String?,
      lastMessageTime: fields[10] as DateTime?,
      unreadCount: fields[11] as int,
      participants: (fields[12] as List).cast<String>(),
      metadata: (fields[13] as Map?)?.cast<String, dynamic>(),
      settings: fields[14] as ConversationSettings,
    );
  }

  @override
  void write(BinaryWriter writer, Conversation obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.helpyPersonalityId)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.lastMessageId)
      ..writeByte(9)
      ..write(obj.lastMessagePreview)
      ..writeByte(10)
      ..write(obj.lastMessageTime)
      ..writeByte(11)
      ..write(obj.unreadCount)
      ..writeByte(12)
      ..write(obj.participants)
      ..writeByte(13)
      ..write(obj.metadata)
      ..writeByte(14)
      ..write(obj.settings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversationSettingsAdapter extends TypeAdapter<ConversationSettings> {
  @override
  final int typeId = 9;

  @override
  ConversationSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationSettings(
      notificationsEnabled: fields[0] as bool,
      soundEnabled: fields[1] as bool,
      autoSaveEnabled: fields[2] as bool,
      maxMessages: fields[3] as int,
      typingTimeout: fields[4] as Duration,
      customSettings: (fields[5] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ConversationSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.notificationsEnabled)
      ..writeByte(1)
      ..write(obj.soundEnabled)
      ..writeByte(2)
      ..write(obj.autoSaveEnabled)
      ..writeByte(3)
      ..write(obj.maxMessages)
      ..writeByte(4)
      ..write(obj.typingTimeout)
      ..writeByte(5)
      ..write(obj.customSettings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversationTypeAdapter extends TypeAdapter<ConversationType> {
  @override
  final int typeId = 7;

  @override
  ConversationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConversationType.general;
      case 1:
        return ConversationType.subjectHelp;
      case 2:
        return ConversationType.homework;
      case 3:
        return ConversationType.quiz;
      case 4:
        return ConversationType.lesson;
      case 5:
        return ConversationType.group;
      default:
        return ConversationType.general;
    }
  }

  @override
  void write(BinaryWriter writer, ConversationType obj) {
    switch (obj) {
      case ConversationType.general:
        writer.writeByte(0);
        break;
      case ConversationType.subjectHelp:
        writer.writeByte(1);
        break;
      case ConversationType.homework:
        writer.writeByte(2);
        break;
      case ConversationType.quiz:
        writer.writeByte(3);
        break;
      case ConversationType.lesson:
        writer.writeByte(4);
        break;
      case ConversationType.group:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversationStatusAdapter extends TypeAdapter<ConversationStatus> {
  @override
  final int typeId = 8;

  @override
  ConversationStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConversationStatus.active;
      case 1:
        return ConversationStatus.paused;
      case 2:
        return ConversationStatus.ended;
      case 3:
        return ConversationStatus.archived;
      default:
        return ConversationStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, ConversationStatus obj) {
    switch (obj) {
      case ConversationStatus.active:
        writer.writeByte(0);
        break;
      case ConversationStatus.paused:
        writer.writeByte(1);
        break;
      case ConversationStatus.ended:
        writer.writeByte(2);
        break;
      case ConversationStatus.archived:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 2;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      id: fields[0] as String,
      conversationId: fields[1] as String,
      senderId: fields[2] as String,
      senderName: fields[3] as String,
      content: fields[4] as String,
      type: fields[5] as MessageType,
      status: fields[6] as MessageStatus,
      timestamp: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime?,
      metadata: (fields[9] as Map?)?.cast<String, dynamic>(),
      replyToMessageId: fields[10] as String?,
      attachments: (fields[11] as List?)?.cast<MessageAttachment>(),
      reactions: (fields[12] as List?)?.cast<MessageReaction>(),
      isEdited: fields[13] as bool,
      editedAt: fields[14] as DateTime?,
      priority: fields[15] as MessagePriority,
      aiSettings: (fields[16] as Map?)?.cast<String, dynamic>(),
      sequenceNumber: fields[17] as int,
      isConflict: fields[18] as bool,
      conflictingMessageIds: (fields[19] as List).cast<String>(),
      messageId: fields[20] as String,
      sentAt: fields[21] as DateTime?,
      deliveredAt: fields[22] as DateTime?,
      readAt: fields[23] as DateTime?,
      deliveryStatus: fields[24] as MessageDeliveryStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(25)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.senderName)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.timestamp)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.metadata)
      ..writeByte(10)
      ..write(obj.replyToMessageId)
      ..writeByte(11)
      ..write(obj.attachments)
      ..writeByte(12)
      ..write(obj.reactions)
      ..writeByte(13)
      ..write(obj.isEdited)
      ..writeByte(14)
      ..write(obj.editedAt)
      ..writeByte(15)
      ..write(obj.priority)
      ..writeByte(16)
      ..write(obj.aiSettings)
      ..writeByte(17)
      ..write(obj.sequenceNumber)
      ..writeByte(18)
      ..write(obj.isConflict)
      ..writeByte(19)
      ..write(obj.conflictingMessageIds)
      ..writeByte(20)
      ..write(obj.messageId)
      ..writeByte(21)
      ..write(obj.sentAt)
      ..writeByte(22)
      ..write(obj.deliveredAt)
      ..writeByte(23)
      ..write(obj.readAt)
      ..writeByte(24)
      ..write(obj.deliveryStatus);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageAttachmentAdapter extends TypeAdapter<MessageAttachment> {
  @override
  final int typeId = 5;

  @override
  MessageAttachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageAttachment(
      id: fields[0] as String,
      fileName: fields[1] as String,
      originalFileName: fields[2] as String?,
      fileType: fields[3] as String,
      fileSize: fields[4] as int,
      originalFileSize: fields[5] as int?,
      url: fields[6] as String,
      localPath: fields[7] as String?,
      thumbnail: fields[8] as String?,
      type: fields[9] as AttachmentType,
      status: fields[10] as AttachmentStatus,
      compressionInfo: fields[11] as CompressionInfo?,
      metadata: (fields[12] as Map?)?.cast<String, dynamic>(),
      uploadedAt: fields[13] as DateTime?,
      uploadedBy: fields[14] as String?,
      isEncrypted: fields[15] as bool,
      encryptionKey: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MessageAttachment obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.originalFileName)
      ..writeByte(3)
      ..write(obj.fileType)
      ..writeByte(4)
      ..write(obj.fileSize)
      ..writeByte(5)
      ..write(obj.originalFileSize)
      ..writeByte(6)
      ..write(obj.url)
      ..writeByte(7)
      ..write(obj.localPath)
      ..writeByte(8)
      ..write(obj.thumbnail)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.compressionInfo)
      ..writeByte(12)
      ..write(obj.metadata)
      ..writeByte(13)
      ..write(obj.uploadedAt)
      ..writeByte(14)
      ..write(obj.uploadedBy)
      ..writeByte(15)
      ..write(obj.isEncrypted)
      ..writeByte(16)
      ..write(obj.encryptionKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 3;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.image;
      case 2:
        return MessageType.file;
      case 3:
        return MessageType.audio;
      case 4:
        return MessageType.video;
      case 5:
        return MessageType.document;
      case 6:
        return MessageType.system;
      case 7:
        return MessageType.typing;
      case 8:
        return MessageType.quiz;
      case 9:
        return MessageType.lesson;
      case 10:
        return MessageType.achievement;
      case 11:
        return MessageType.suggestion;
      case 12:
        return MessageType.emoji;
      case 13:
        return MessageType.sticker;
      case 14:
        return MessageType.location;
      case 15:
        return MessageType.contact;
      default:
        return MessageType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.text:
        writer.writeByte(0);
        break;
      case MessageType.image:
        writer.writeByte(1);
        break;
      case MessageType.file:
        writer.writeByte(2);
        break;
      case MessageType.audio:
        writer.writeByte(3);
        break;
      case MessageType.video:
        writer.writeByte(4);
        break;
      case MessageType.document:
        writer.writeByte(5);
        break;
      case MessageType.system:
        writer.writeByte(6);
        break;
      case MessageType.typing:
        writer.writeByte(7);
        break;
      case MessageType.quiz:
        writer.writeByte(8);
        break;
      case MessageType.lesson:
        writer.writeByte(9);
        break;
      case MessageType.achievement:
        writer.writeByte(10);
        break;
      case MessageType.suggestion:
        writer.writeByte(11);
        break;
      case MessageType.emoji:
        writer.writeByte(12);
        break;
      case MessageType.sticker:
        writer.writeByte(13);
        break;
      case MessageType.location:
        writer.writeByte(14);
        break;
      case MessageType.contact:
        writer.writeByte(15);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageStatusAdapter extends TypeAdapter<MessageStatus> {
  @override
  final int typeId = 4;

  @override
  MessageStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageStatus.sending;
      case 1:
        return MessageStatus.sent;
      case 2:
        return MessageStatus.delivered;
      case 3:
        return MessageStatus.read;
      case 4:
        return MessageStatus.failed;
      case 5:
        return MessageStatus.encrypted;
      case 6:
        return MessageStatus.deleted;
      default:
        return MessageStatus.sending;
    }
  }

  @override
  void write(BinaryWriter writer, MessageStatus obj) {
    switch (obj) {
      case MessageStatus.sending:
        writer.writeByte(0);
        break;
      case MessageStatus.sent:
        writer.writeByte(1);
        break;
      case MessageStatus.delivered:
        writer.writeByte(2);
        break;
      case MessageStatus.read:
        writer.writeByte(3);
        break;
      case MessageStatus.failed:
        writer.writeByte(4);
        break;
      case MessageStatus.encrypted:
        writer.writeByte(5);
        break;
      case MessageStatus.deleted:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

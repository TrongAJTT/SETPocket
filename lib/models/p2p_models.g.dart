// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class P2PUserAdapter extends TypeAdapter<P2PUser> {
  @override
  final int typeId = 47;

  @override
  P2PUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return P2PUser(
      id: fields[0] as String?,
      displayName: fields[1] as String,
      deviceId: fields[2] as String,
      ipAddress: fields[3] as String,
      port: fields[4] as int,
      lastSeen: fields[5] as DateTime?,
      isOnline: fields[6] as bool,
      isPaired: fields[7] as bool,
      isTrusted: fields[8] as bool,
      autoConnect: fields[9] as bool,
      pairedAt: fields[10] as DateTime?,
      isStored: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, P2PUser obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.deviceId)
      ..writeByte(3)
      ..write(obj.ipAddress)
      ..writeByte(4)
      ..write(obj.port)
      ..writeByte(5)
      ..write(obj.lastSeen)
      ..writeByte(6)
      ..write(obj.isOnline)
      ..writeByte(7)
      ..write(obj.isPaired)
      ..writeByte(8)
      ..write(obj.isTrusted)
      ..writeByte(9)
      ..write(obj.autoConnect)
      ..writeByte(10)
      ..write(obj.pairedAt)
      ..writeByte(11)
      ..write(obj.isStored);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is P2PUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PairingRequestAdapter extends TypeAdapter<PairingRequest> {
  @override
  final int typeId = 48;

  @override
  PairingRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PairingRequest(
      id: fields[0] as String?,
      fromUserId: fields[1] as String,
      fromUserName: fields[2] as String,
      fromDeviceId: fields[3] as String,
      fromIpAddress: fields[4] as String,
      fromPort: fields[5] as int,
      requestTime: fields[6] as DateTime?,
      wantsSaveConnection: fields[7] as bool,
      isProcessed: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PairingRequest obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fromUserId)
      ..writeByte(2)
      ..write(obj.fromUserName)
      ..writeByte(3)
      ..write(obj.fromDeviceId)
      ..writeByte(4)
      ..write(obj.fromIpAddress)
      ..writeByte(5)
      ..write(obj.fromPort)
      ..writeByte(6)
      ..write(obj.requestTime)
      ..writeByte(7)
      ..write(obj.wantsSaveConnection)
      ..writeByte(8)
      ..write(obj.isProcessed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PairingRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataTransferTaskAdapter extends TypeAdapter<DataTransferTask> {
  @override
  final int typeId = 49;

  @override
  DataTransferTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataTransferTask(
      id: fields[0] as String?,
      fileName: fields[1] as String,
      filePath: fields[2] as String,
      fileSize: fields[3] as int,
      targetUserId: fields[4] as String,
      targetUserName: fields[5] as String,
      status: fields[6] as DataTransferStatus,
      transferredBytes: fields[7] as int,
      createdAt: fields[8] as DateTime?,
      startedAt: fields[9] as DateTime?,
      completedAt: fields[10] as DateTime?,
      errorMessage: fields[11] as String?,
      isOutgoing: fields[12] as bool,
      savePath: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DataTransferTask obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.fileSize)
      ..writeByte(4)
      ..write(obj.targetUserId)
      ..writeByte(5)
      ..write(obj.targetUserName)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.transferredBytes)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.startedAt)
      ..writeByte(10)
      ..write(obj.completedAt)
      ..writeByte(11)
      ..write(obj.errorMessage)
      ..writeByte(12)
      ..write(obj.isOutgoing)
      ..writeByte(13)
      ..write(obj.savePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataTransferTaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class P2PFileStorageSettingsAdapter
    extends TypeAdapter<P2PFileStorageSettings> {
  @override
  final int typeId = 52;

  @override
  P2PFileStorageSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return P2PFileStorageSettings(
      downloadPath: fields[0] as String,
      askBeforeDownload: fields[1] as bool,
      createDateFolders: fields[2] as bool,
      maxFileSize: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, P2PFileStorageSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.downloadPath)
      ..writeByte(1)
      ..write(obj.askBeforeDownload)
      ..writeByte(2)
      ..write(obj.createDateFolders)
      ..writeByte(3)
      ..write(obj.maxFileSize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is P2PFileStorageSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume_state_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VolumeCardStateAdapter extends TypeAdapter<VolumeCardState> {
  @override
  final int typeId = 26;

  @override
  VolumeCardState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VolumeCardState(
      unitCode: fields[0] as String,
      amount: fields[1] as double,
      name: fields[2] as String?,
      visibleUnits: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, VolumeCardState obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.unitCode)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.visibleUnits);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VolumeCardStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VolumeStateModelAdapter extends TypeAdapter<VolumeStateModel> {
  @override
  final int typeId = 27;

  @override
  VolumeStateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VolumeStateModel(
      cards: (fields[0] as List).cast<VolumeCardState>(),
      visibleUnits: (fields[1] as List).cast<String>(),
      lastUpdated: fields[2] as DateTime,
      isFocusMode: fields[3] as bool,
      viewMode: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VolumeStateModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cards)
      ..writeByte(1)
      ..write(obj.visibleUnits)
      ..writeByte(2)
      ..write(obj.lastUpdated)
      ..writeByte(3)
      ..write(obj.isFocusMode)
      ..writeByte(4)
      ..write(obj.viewMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VolumeStateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

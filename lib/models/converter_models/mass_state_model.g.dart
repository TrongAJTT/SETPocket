// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mass_state_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MassCardStateAdapter extends TypeAdapter<MassCardState> {
  @override
  final int typeId = 8;

  @override
  MassCardState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MassCardState(
      unitCode: fields[0] as String,
      amount: fields[1] as double,
      name: fields[2] as String?,
      visibleUnits: (fields[3] as List?)?.cast<String>(),
      createdAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MassCardState obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.unitCode)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.visibleUnits)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MassCardStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MassStateModelAdapter extends TypeAdapter<MassStateModel> {
  @override
  final int typeId = 9;

  @override
  MassStateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MassStateModel(
      cards: (fields[0] as List).cast<MassCardState>(),
      visibleUnits: (fields[1] as List).cast<String>(),
      lastUpdated: fields[2] as DateTime,
      isFocusMode: fields[3] as bool,
      viewMode: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MassStateModel obj) {
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
      other is MassStateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

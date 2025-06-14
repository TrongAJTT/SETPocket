// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_state_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeCardStateAdapter extends TypeAdapter<TimeCardState> {
  @override
  final int typeId = 24;

  @override
  TimeCardState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeCardState(
      unitCode: fields[0] as String,
      amount: fields[1] as double,
      name: fields[2] as String?,
      visibleUnits: (fields[3] as List?)?.cast<String>(),
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TimeCardState obj) {
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
      other is TimeCardStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimeStateModelAdapter extends TypeAdapter<TimeStateModel> {
  @override
  final int typeId = 25;

  @override
  TimeStateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeStateModel(
      cards: (fields[0] as List).cast<TimeCardState>(),
      visibleUnits: (fields[1] as List).cast<String>(),
      lastUpdated: fields[2] as DateTime,
      isFocusMode: fields[3] as bool,
      viewMode: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TimeStateModel obj) {
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
      other is TimeStateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

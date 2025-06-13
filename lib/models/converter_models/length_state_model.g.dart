// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'length_state_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LengthCardStateAdapter extends TypeAdapter<LengthCardState> {
  @override
  final int typeId = 17;

  @override
  LengthCardState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LengthCardState(
      unitCode: fields[0] as String,
      amount: fields[1] as double,
      name: fields[2] as String?,
      visibleUnits: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, LengthCardState obj) {
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
      other is LengthCardStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LengthStateModelAdapter extends TypeAdapter<LengthStateModel> {
  @override
  final int typeId = 18;

  @override
  LengthStateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LengthStateModel(
      cards: (fields[0] as List).cast<LengthCardState>(),
      visibleUnits: (fields[1] as List).cast<String>(),
      lastUpdated: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LengthStateModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.cards)
      ..writeByte(1)
      ..write(obj.visibleUnits)
      ..writeByte(2)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LengthStateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

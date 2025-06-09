// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_state_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeightCardStateAdapter extends TypeAdapter<WeightCardState> {
  @override
  final int typeId = 8;

  @override
  WeightCardState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightCardState(
      unitCode: fields[0] as String,
      amount: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WeightCardState obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.unitCode)
      ..writeByte(1)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightCardStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeightStateModelAdapter extends TypeAdapter<WeightStateModel> {
  @override
  final int typeId = 9;

  @override
  WeightStateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightStateModel(
      cards: (fields[0] as List).cast<WeightCardState>(),
      visibleUnits: (fields[1] as List).cast<String>(),
      lastUpdated: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeightStateModel obj) {
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
      other is WeightStateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

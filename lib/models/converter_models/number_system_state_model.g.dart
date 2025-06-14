// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'number_system_state_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NumberSystemCardStateAdapter extends TypeAdapter<NumberSystemCardState> {
  @override
  final int typeId = 28;

  @override
  NumberSystemCardState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NumberSystemCardState(
      unitCode: fields[0] as String,
      amount: fields[1] as double,
      name: fields[2] as String?,
      visibleUnits: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, NumberSystemCardState obj) {
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
      other is NumberSystemCardStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NumberSystemStateModelAdapter
    extends TypeAdapter<NumberSystemStateModel> {
  @override
  final int typeId = 29;

  @override
  NumberSystemStateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NumberSystemStateModel(
      cards: (fields[0] as List).cast<NumberSystemCardState>(),
      globalVisibleUnits: (fields[1] as List).cast<String>(),
      isFocusMode: fields[2] as bool,
      viewMode: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, NumberSystemStateModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.cards)
      ..writeByte(1)
      ..write(obj.globalVisibleUnits)
      ..writeByte(2)
      ..write(obj.isFocusMode)
      ..writeByte(3)
      ..write(obj.viewMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberSystemStateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

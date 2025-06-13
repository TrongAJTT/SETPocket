// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'length_preset_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LengthPresetModelAdapter extends TypeAdapter<LengthPresetModel> {
  @override
  final int typeId = 4;

  @override
  LengthPresetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LengthPresetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      units: (fields[2] as List).cast<String>(),
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LengthPresetModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.units)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LengthPresetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generic_preset_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GenericPresetModelAdapter extends TypeAdapter<GenericPresetModel> {
  @override
  final int typeId = 19;

  @override
  GenericPresetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GenericPresetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      units: (fields[2] as List).cast<String>(),
      createdAt: fields[3] as DateTime,
      presetType: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GenericPresetModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.units)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.presetType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenericPresetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

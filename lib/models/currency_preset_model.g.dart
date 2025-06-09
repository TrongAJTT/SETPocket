// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_preset_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyPresetModelAdapter extends TypeAdapter<CurrencyPresetModel> {
  @override
  final int typeId = 3;

  @override
  CurrencyPresetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyPresetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      currencies: (fields[2] as List).cast<String>(),
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyPresetModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.currencies)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyPresetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

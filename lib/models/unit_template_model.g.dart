// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_template_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitTemplateModelAdapter extends TypeAdapter<UnitTemplateModel> {
  @override
  final int typeId = 15;

  @override
  UnitTemplateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitTemplateModel(
      id: fields[0] as String,
      name: fields[1] as String,
      templateType: fields[2] as String,
      units: (fields[3] as List).cast<String>(),
      createdAt: fields[4] as DateTime,
      metadata: (fields[5] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UnitTemplateModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.templateType)
      ..writeByte(3)
      ..write(obj.units)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitTemplateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TemplateSortOrderAdapter extends TypeAdapter<TemplateSortOrder> {
  @override
  final int typeId = 16;

  @override
  TemplateSortOrder read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TemplateSortOrder.date;
      case 1:
        return TemplateSortOrder.name;
      case 2:
        return TemplateSortOrder.type;
      default:
        return TemplateSortOrder.date;
    }
  }

  @override
  void write(BinaryWriter writer, TemplateSortOrder obj) {
    switch (obj) {
      case TemplateSortOrder.date:
        writer.writeByte(0);
        break;
      case TemplateSortOrder.name:
        writer.writeByte(1);
        break;
      case TemplateSortOrder.type:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplateSortOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

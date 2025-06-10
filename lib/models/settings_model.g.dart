// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 12;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      currencyFetchMode: fields[0] as CurrencyFetchMode,
      fetchTimeoutSeconds: fields[1] as int,
      featureStateSavingEnabled: fields[2] as bool,
      logRetentionDays: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.currencyFetchMode)
      ..writeByte(1)
      ..write(obj.fetchTimeoutSeconds)
      ..writeByte(2)
      ..write(obj.featureStateSavingEnabled)
      ..writeByte(3)
      ..write(obj.logRetentionDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

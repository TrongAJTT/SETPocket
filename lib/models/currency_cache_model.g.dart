// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_cache_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyCacheModelAdapter extends TypeAdapter<CurrencyCacheModel> {
  @override
  final int typeId = 10;

  @override
  CurrencyCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyCacheModel(
      rates: (fields[0] as Map).cast<String, double>(),
      lastUpdated: fields[1] as DateTime,
      isValid: fields[2] as bool,
      currencyStatuses: (fields[3] as Map?)?.cast<String, int>(),
      currencyFetchTimes: (fields[4] as Map?)?.cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyCacheModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.rates)
      ..writeByte(1)
      ..write(obj.lastUpdated)
      ..writeByte(2)
      ..write(obj.isValid)
      ..writeByte(3)
      ..write(obj.currencyStatuses)
      ..writeByte(4)
      ..write(obj.currencyFetchTimes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CurrencyFetchModeAdapter extends TypeAdapter<CurrencyFetchMode> {
  @override
  final int typeId = 11;

  @override
  CurrencyFetchMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return CurrencyFetchMode.manual;
      case 1:
        return CurrencyFetchMode.onceADay;
      case 2:
        return CurrencyFetchMode.manual; // Handle old everytime values
      default:
        return CurrencyFetchMode.manual;
    }
  }

  @override
  void write(BinaryWriter writer, CurrencyFetchMode obj) {
    switch (obj) {
      case CurrencyFetchMode.manual:
        writer.writeByte(0);
        break;
      case CurrencyFetchMode.onceADay:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyFetchModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

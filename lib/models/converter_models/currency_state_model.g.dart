// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_state_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyStateModelAdapter extends TypeAdapter<CurrencyStateModel> {
  @override
  final int typeId = 5;

  @override
  CurrencyStateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyStateModel(
      cards: (fields[0] as List).cast<CurrencyCardState>(),
      visibleCurrencies: (fields[1] as List).cast<String>(),
      lastUpdated: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyStateModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.cards)
      ..writeByte(1)
      ..write(obj.visibleCurrencies)
      ..writeByte(2)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyStateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CurrencyCardStateAdapter extends TypeAdapter<CurrencyCardState> {
  @override
  final int typeId = 6;

  @override
  CurrencyCardState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyCardState(
      currencyCode: fields[0] as String,
      amount: fields[1] as double,
      name: fields[2] as String?,
      currencies: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyCardState obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.currencyCode)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.currencies);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyCardStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

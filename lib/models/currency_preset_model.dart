import 'package:hive/hive.dart';

part 'currency_preset_model.g.dart';

@HiveType(typeId: 3)
class CurrencyPresetModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> currencies;

  @HiveField(3)
  final DateTime createdAt;

  CurrencyPresetModel({
    required this.id,
    required this.name,
    required this.currencies,
    required this.createdAt,
  });

  // Factory constructor to create preset with current timestamp
  factory CurrencyPresetModel.create({
    required String name,
    required List<String> currencies,
  }) {
    final now = DateTime.now();
    return CurrencyPresetModel(
      id: now.millisecondsSinceEpoch.toString(),
      name: name,
      currencies: List.from(currencies),
      createdAt: now,
    );
  }

  // Copy with method for updates
  CurrencyPresetModel copyWith({
    String? id,
    String? name,
    List<String>? currencies,
    DateTime? createdAt,
  }) {
    return CurrencyPresetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      currencies: currencies ?? this.currencies,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CurrencyPresetModel(id: $id, name: $name, currencies: $currencies, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyPresetModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 
import 'package:isar/isar.dart';
import 'package:setpocket/utils/isar_utils.dart';

part 'currency_preset_model.g.dart';

@Collection()
class CurrencyPresetModel {
  Id get isarId => fastHash(id);

  @Index(unique: true, replace: true)
  String id;

  String name;

  List<String> currencies;

  DateTime createdAt;

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

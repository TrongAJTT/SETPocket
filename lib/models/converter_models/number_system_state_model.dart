import 'package:isar/isar.dart';

part 'number_system_state_model.g.dart';

@embedded
class NumberSystemCardState {
  String unitCode;

  double amount;

  String? name;

  List<String>? visibleUnits;

  NumberSystemCardState({
    this.unitCode = 'decimal',
    this.amount = 0.0,
    this.name,
    this.visibleUnits,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'unitCode': unitCode,
      'amount': amount,
      'name': name ?? 'Card 1',
      'visibleUnits':
          visibleUnits ?? ['binary', 'octal', 'decimal', 'hexadecimal'],
    };
  }

  // Create from JSON
  factory NumberSystemCardState.fromJson(Map<String, dynamic> json) {
    return NumberSystemCardState(
      unitCode: json['unitCode'] ?? 'decimal',
      amount: (json['amount'] ?? 0).toDouble(),
      name: json['name'] ?? 'Card 1',
      visibleUnits: (json['visibleUnits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['binary', 'octal', 'decimal', 'hexadecimal'],
    );
  }

  NumberSystemCardState copyWith({
    String? unitCode,
    double? amount,
    String? name,
    List<String>? visibleUnits,
  }) {
    return NumberSystemCardState(
      unitCode: unitCode ?? this.unitCode,
      amount: amount ?? this.amount,
      name: name ?? this.name,
      visibleUnits: visibleUnits ?? this.visibleUnits,
    );
  }
}

@collection
class NumberSystemStateModel {
  Id id = Isar.autoIncrement;

  List<NumberSystemCardState> cards;

  List<String> globalVisibleUnits;

  bool isFocusMode;

  String viewMode; // 'cards' or 'table'

  DateTime lastUpdated;

  NumberSystemStateModel({
    required this.cards,
    required this.globalVisibleUnits,
    required this.isFocusMode,
    required this.viewMode,
    required this.lastUpdated,
  });

  // Create default state
  static NumberSystemStateModel createDefault() {
    return NumberSystemStateModel(
      cards: [
        NumberSystemCardState(
          unitCode: 'decimal',
          amount: 255,
          name: 'Card 1',
          visibleUnits: ['binary', 'octal', 'decimal', 'hexadecimal'],
        ),
      ],
      globalVisibleUnits: [
        'binary',
        'octal',
        'decimal',
        'hexadecimal',
      ],
      isFocusMode: false,
      viewMode: 'cards',
      lastUpdated: DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((card) => card.toJson()).toList(),
      'globalVisibleUnits': globalVisibleUnits,
      'isFocusMode': isFocusMode,
      'viewMode': viewMode,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Create from JSON
  factory NumberSystemStateModel.fromJson(Map<String, dynamic> json) {
    return NumberSystemStateModel(
      cards: (json['cards'] as List<dynamic>?)
              ?.map((cardJson) => NumberSystemCardState.fromJson(
                  cardJson as Map<String, dynamic>))
              .toList() ??
          [
            NumberSystemCardState(
              unitCode: 'decimal',
              amount: 255,
              name: 'Card 1',
              visibleUnits: ['binary', 'octal', 'decimal', 'hexadecimal'],
            ),
          ],
      globalVisibleUnits: (json['globalVisibleUnits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [
            'binary',
            'octal',
            'decimal',
            'hexadecimal',
          ],
      isFocusMode: json['isFocusMode'] ?? false,
      viewMode: json['viewMode'] ?? 'cards',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  NumberSystemStateModel copyWith({
    List<NumberSystemCardState>? cards,
    List<String>? globalVisibleUnits,
    bool? isFocusMode,
    String? viewMode,
    DateTime? lastUpdated,
  }) {
    return NumberSystemStateModel(
      cards: cards ?? this.cards,
      globalVisibleUnits: globalVisibleUnits ?? this.globalVisibleUnits,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      viewMode: viewMode ?? this.viewMode,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Fast hash function to generate Isar Id from String
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}

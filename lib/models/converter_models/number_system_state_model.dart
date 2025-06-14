import 'package:hive/hive.dart';

part 'number_system_state_model.g.dart';

@HiveType(typeId: 28)
class NumberSystemCardState extends HiveObject {
  @HiveField(0)
  String unitCode;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String? name;

  @HiveField(3)
  List<String>? visibleUnits;

  NumberSystemCardState({
    required this.unitCode,
    required this.amount,
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

@HiveType(typeId: 29)
class NumberSystemStateModel extends HiveObject {
  @HiveField(0)
  List<NumberSystemCardState> cards;

  @HiveField(1)
  List<String> globalVisibleUnits;

  @HiveField(2)
  bool isFocusMode;

  @HiveField(3)
  String viewMode; // 'cards' or 'table'

  NumberSystemStateModel({
    required this.cards,
    required this.globalVisibleUnits,
    required this.isFocusMode,
    required this.viewMode,
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
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cards': cards.map((card) => card.toJson()).toList(),
      'globalVisibleUnits': globalVisibleUnits,
      'isFocusMode': isFocusMode,
      'viewMode': viewMode,
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
    );
  }

  NumberSystemStateModel copyWith({
    List<NumberSystemCardState>? cards,
    List<String>? globalVisibleUnits,
    bool? isFocusMode,
    String? viewMode,
  }) {
    return NumberSystemStateModel(
      cards: cards ?? this.cards,
      globalVisibleUnits: globalVisibleUnits ?? this.globalVisibleUnits,
      isFocusMode: isFocusMode ?? this.isFocusMode,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

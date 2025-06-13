/// Abstract base class for any converter unit
abstract class ConverterUnit {
  String get id;
  String get name;
  String get symbol;

  /// Convert raw value to display string
  String formatValue(double value);

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConverterUnit &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Status for each unit conversion
enum ConversionStatus { success, failed, timeout, loading, notAvailable }

/// A single card/row state in converter
class ConverterCardState {
  final String name;
  final String baseUnitId;
  final double baseValue;
  final List<String> visibleUnits;
  final Map<String, double> values;
  final Map<String, ConversionStatus> statuses;

  const ConverterCardState({
    required this.name,
    required this.baseUnitId,
    required this.baseValue,
    required this.visibleUnits,
    required this.values,
    this.statuses = const {},
  });

  ConverterCardState copyWith({
    String? name,
    String? baseUnitId,
    double? baseValue,
    List<String>? visibleUnits,
    Map<String, double>? values,
    Map<String, ConversionStatus>? statuses,
  }) {
    return ConverterCardState(
      name: name ?? this.name,
      baseUnitId: baseUnitId ?? this.baseUnitId,
      baseValue: baseValue ?? this.baseValue,
      visibleUnits: visibleUnits != null
          ? visibleUnits.toSet().toList() // Remove duplicates
          : this.visibleUnits,
      values: values ?? this.values,
      statuses: statuses ?? this.statuses,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'baseUnitId': baseUnitId,
        'baseValue': baseValue,
        'visibleUnits': visibleUnits,
        'values': values,
      };

  factory ConverterCardState.fromJson(Map<String, dynamic> json) {
    final rawVisibleUnits = List<String>.from(json['visibleUnits'] ?? []);
    return ConverterCardState(
      name: json['name'] ?? '',
      baseUnitId: json['baseUnitId'] ?? '',
      baseValue: (json['baseValue'] ?? 0.0).toDouble(),
      visibleUnits: rawVisibleUnits.toSet().toList(), // Remove duplicates
      values: Map<String, double>.from(json['values'] ?? {}),
    );
  }
}

/// Overall state for converter
class ConverterState {
  final List<ConverterCardState> cards;
  final Set<String> globalVisibleUnits;
  final DateTime? lastUpdated;
  final bool isLoading;

  const ConverterState({
    required this.cards,
    required this.globalVisibleUnits,
    this.lastUpdated,
    this.isLoading = false,
  });

  ConverterState copyWith({
    List<ConverterCardState>? cards,
    Set<String>? globalVisibleUnits,
    DateTime? lastUpdated,
    bool? isLoading,
  }) {
    return ConverterState(
      cards: cards ?? this.cards,
      globalVisibleUnits: globalVisibleUnits ?? this.globalVisibleUnits,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  Map<String, dynamic> toJson() => {
        'cards': cards.map((c) => c.toJson()).toList(),
        'globalVisibleUnits': globalVisibleUnits.toList(),
        'lastUpdated': lastUpdated?.toIso8601String(),
      };

  factory ConverterState.fromJson(Map<String, dynamic> json) {
    return ConverterState(
      cards: (json['cards'] as List<dynamic>?)
              ?.map((c) => ConverterCardState.fromJson(c))
              .toList() ??
          [],
      globalVisibleUnits: Set<String>.from(json['globalVisibleUnits'] ?? []),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }
}

/// Configuration for unit item in customization dialog
class UnitItem {
  final String id;
  final String name;
  final String symbol;
  final String? description;

  const UnitItem({
    required this.id,
    required this.name,
    required this.symbol,
    this.description,
  });
}

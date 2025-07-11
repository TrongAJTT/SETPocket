import 'package:isar/isar.dart';
import 'dart:convert';

part 'calculator_tools_data.g.dart';

/// Unified data model for all calculator tools state and cache
/// Uses toolCode to distinguish between different calculator types
@Collection()
class CalculatorToolsData {
  Id id = Isar.autoIncrement;

  /// Tool identifier (e.g., 'financial', 'graphing', 'scientific', 'bmi', etc.)
  @Index(composite: [CompositeIndex('dataType')], unique: true)
  late String toolCode;

  /// JSON data for tool-specific state/cache
  late String jsonData;

  /// Data type to distinguish between different data types
  /// e.g., 'state', 'cache', 'presets'
  late String dataType;

  /// Last updated timestamp
  DateTime lastUpdated = DateTime.now();

  /// Optional metadata as JSON string
  String? metadata;

  CalculatorToolsData();

  /// Create a new instance
  CalculatorToolsData.create({
    required this.toolCode,
    required this.dataType,
    required Map<String, dynamic> data,
    Map<String, dynamic>? meta,
  }) {
    jsonData = jsonEncode(data);
    if (meta != null) {
      metadata = jsonEncode(meta);
    }
    lastUpdated = DateTime.now();
  }

  /// Get the parsed JSON data
  Map<String, dynamic> getParsedData() {
    try {
      return jsonDecode(jsonData) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Get the parsed metadata
  Map<String, dynamic>? getParsedMetadata() {
    if (metadata == null) return null;
    try {
      return jsonDecode(metadata!) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Update the data
  void updateData(Map<String, dynamic> data) {
    jsonData = jsonEncode(data);
    lastUpdated = DateTime.now();
  }

  /// Update the metadata
  void updateMetadata(Map<String, dynamic>? meta) {
    metadata = meta != null ? jsonEncode(meta) : null;
    lastUpdated = DateTime.now();
  }

  /// Get unique key for this entry
  String get uniqueKey => '${toolCode}_$dataType';

  @override
  String toString() {
    return 'CalculatorToolsData(toolCode: $toolCode, dataType: $dataType, lastUpdated: $lastUpdated)';
  }
}

/// Constants for calculator tool codes
class CalculatorToolCodes {
  static const String financial = 'financial';
  static const String graphing = 'graphing';
  static const String scientific = 'scientific';
  static const String bmi = 'bmi';
  static const String dateCalculator = 'date_calculator';
  static const String discountCalculator = 'discount_calculator';
}

/// Constants for data types
class CalculatorDataTypes {
  static const String state = 'state';
  static const String cache = 'cache';
  static const String presets = 'presets';
  static const String history = 'history';
}

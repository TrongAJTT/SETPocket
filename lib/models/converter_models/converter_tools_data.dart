import 'package:isar/isar.dart';
import 'dart:convert';

part 'converter_tools_data.g.dart';

/// Unified data model for all converter tools state and cache
/// Uses toolCode to distinguish between different converter types
@Collection()
class ConverterToolsData {
  Id id = Isar.autoIncrement;

  /// Tool identifier (e.g., 'area', 'currency', 'length', 'weight', etc.)
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

  ConverterToolsData();

  /// Create a new instance
  ConverterToolsData.create({
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
    return 'ConverterToolsData(toolCode: $toolCode, dataType: $dataType, lastUpdated: $lastUpdated)';
  }
}

/// Constants for tool codes
class ConverterToolCodes {
  static const String area = 'area';
  static const String currency = 'currency';
  static const String length = 'length';
  static const String weight = 'weight';
  static const String volume = 'volume';
  static const String temperature = 'temperature';
  static const String mass = 'mass';
  static const String numberSystem = 'number_system';
  static const String time = 'time';
  static const String data = 'data';
  static const String speed = 'speed';
}

/// Constants for data types
class ConverterDataTypes {
  static const String state = 'state';
  static const String cache = 'cache';
  static const String presets = 'presets';
}

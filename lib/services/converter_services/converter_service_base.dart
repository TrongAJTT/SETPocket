import '../../models/converter_base.dart';

/// Abstract service interface for all converters
abstract class ConverterServiceBase {
  /// Get all available units for this converter
  List<ConverterUnit> get units;

  /// Get converter type (currency, length, weight, etc.)
  String get converterType;

  /// Get display name for this converter
  String get displayName;

  /// Get default visible units
  Set<String> get defaultVisibleUnits;

  /// Convert value from one unit to another
  double convert(double value, String fromUnitId, String toUnitId);

  /// Get unit by ID
  ConverterUnit? getUnit(String unitId);

  /// Get conversion status for a specific unit
  ConversionStatus getUnitStatus(String unitId) => ConversionStatus.success;

  /// Check if this converter needs real-time data updates
  bool get requiresRealTimeData => false;

  /// Refresh real-time data (for currency converter)
  Future<void> refreshData() async {}

  /// Get last update time (for currency converter)
  DateTime? get lastUpdated => null;

  /// Check if using live data
  bool get isUsingLiveData => false;
}

/// Service for managing converter state persistence
abstract class ConverterStateService {
  /// Save converter state
  Future<void> saveState(String converterType, ConverterState state);

  /// Load converter state
  Future<ConverterState> loadState(String converterType);

  /// Clear saved state
  Future<void> clearState(String converterType);
}

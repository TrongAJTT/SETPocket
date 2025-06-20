import 'dart:convert';
import 'package:setpocket/services/hive_service.dart';
import 'package:setpocket/services/calculator_history_service.dart';

class ScientificCalculatorState {
  final String display;
  final String expression;
  final String realTimeResult;
  final bool isRadians;
  final bool showSecondaryFunctions;
  final List<String> calculationStack;
  final bool justCalculated;

  ScientificCalculatorState({
    required this.display,
    required this.expression,
    required this.realTimeResult,
    required this.isRadians,
    required this.showSecondaryFunctions,
    required this.calculationStack,
    required this.justCalculated,
  });

  Map<String, dynamic> toJson() {
    return {
      'display': display,
      'expression': expression,
      'realTimeResult': realTimeResult,
      'isRadians': isRadians,
      'showSecondaryFunctions': showSecondaryFunctions,
      'calculationStack': calculationStack,
      'justCalculated': justCalculated,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  factory ScientificCalculatorState.fromJson(Map<String, dynamic> json) {
    return ScientificCalculatorState(
      display: json['display'] ?? '0',
      expression: json['expression'] ?? '',
      realTimeResult: json['realTimeResult'] ?? '',
      isRadians: json['isRadians'] ?? true,
      showSecondaryFunctions: json['showSecondaryFunctions'] ?? false,
      calculationStack: List<String>.from(json['calculationStack'] ?? []),
      justCalculated: json['justCalculated'] ?? false,
    );
  }
}

class ScientificCalculatorService {
  static const String _stateBoxName = 'scientific_calculator_state';
  static const String _stateKey = 'current_state';

  // State management
  static Future<ScientificCalculatorState?> getCurrentState() async {
    try {
      final box = await HiveService.getBox(_stateBoxName);
      final data = box.get(_stateKey);
      if (data != null && data is Map) {
        return ScientificCalculatorState.fromJson(
            Map<String, dynamic>.from(data));
      }
    } catch (e) {
      // Return null if error
    }
    return null;
  }

  static Future<void> saveCurrentState(ScientificCalculatorState state) async {
    try {
      final box = await HiveService.getBox(_stateBoxName);
      await box.put(_stateKey, state.toJson());
    } catch (e) {
      // Silently fail
    }
  }

  static Future<void> clearCurrentState() async {
    try {
      final box = await HiveService.getBox(_stateBoxName);
      await box.delete(_stateKey);
    } catch (e) {
      // Silently fail
    }
  }

  // History management (delegates to CalculatorHistoryService)
  static Future<List<CalculatorHistoryItem>> getHistory() async {
    return await CalculatorHistoryService.getHistory('scientific');
  }

  static Future<void> addToHistory(String expression, String result) async {
    await CalculatorHistoryService.addHistoryItem(
      expression,
      result,
      'scientific',
    );
  }

  static Future<void> clearHistory() async {
    await CalculatorHistoryService.clearHistory('scientific');
  }

  // Cache info for settings integration
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final history = await getHistory();
      final currentState = await getCurrentState();

      // Calculate size estimation
      int historySize = 0;
      for (final item in history) {
        historySize += json.encode(item.toJson()).length;
      }

      final stateSize =
          currentState != null ? json.encode(currentState.toJson()).length : 0;

      return {
        'items': history.length + (currentState != null ? 1 : 0),
        'size': historySize + stateSize,
        'history_count': history.length,
        'has_current_state': currentState != null,
      };
    } catch (e) {
      return {
        'items': 0,
        'size': 0,
        'history_count': 0,
        'has_current_state': false,
      };
    }
  }

  static Future<void> clearAllData() async {
    await clearHistory();
    await clearCurrentState();
  }
}

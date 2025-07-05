import 'package:isar/isar.dart';
import 'package:setpocket/models/calculator_history.dart';
import 'package:setpocket/models/scientific_calculator_state.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:setpocket/services/calculator_history_isar_service.dart';

class ScientificCalculatorService {
  // State management
  static Future<ScientificCalculatorState?> getCurrentState() async {
    final isar = IsarService.isar;
    return isar.scientificCalculatorStates.where().findFirst();
  }

  static Future<void> saveCurrentState(ScientificCalculatorState state) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.scientificCalculatorStates.clear();
      await isar.scientificCalculatorStates.put(state);
    });
  }

  static Future<void> clearCurrentState() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() => isar.scientificCalculatorStates.clear());
  }

  // History management delegates to the new Isar service
  static Future<List<CalculatorHistory>> getHistory() async {
    return await CalculatorHistoryIsarService.getHistory('scientific');
  }

  static Future<void> addToHistory(String expression, String result) async {
    await CalculatorHistoryIsarService.addHistoryItem(
      expression,
      result,
      'scientific',
    );
  }

  static Future<void> clearHistory() async {
    await CalculatorHistoryIsarService.clearHistory('scientific');
  }

  // Cache info for settings integration
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final history = await getHistory();
      final currentState = await getCurrentState();
      int historySize = history.fold(
          0,
          (prev, item) =>
              prev + (item.expression.length + item.result.length) * 2);
      int stateSize = (currentState?.expression?.length ?? 0) +
          (currentState?.display?.length ?? 0);

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
        'has_current_state': false
      };
    }
  }

  static Future<void> clearAllData() async {
    await clearHistory();
    await clearCurrentState();
  }
}

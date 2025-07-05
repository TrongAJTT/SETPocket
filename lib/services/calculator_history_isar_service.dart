// This service will be a clean, Isar-only implementation
// of the calculator history logic.
import 'package:isar/isar.dart';
import 'package:setpocket/models/calculator_history.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorHistoryIsarService {
  static const _historyEnabledKey = 'calculator_history_enabled';
  static const int maxHistoryItems = 100;

  static Future<bool> isHistoryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_historyEnabledKey) ?? true;
  }

  static Future<void> setHistoryEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_historyEnabledKey, enabled);
  }

  static Future<void> addHistoryItem(
      String expression, String result, String type) async {
    final enabled = await isHistoryEnabled();
    if (!enabled) return;

    final isar = IsarService.isar;
    final newItem = CalculatorHistory()
      ..expression = expression
      ..result = result
      ..timestamp = DateTime.now()
      ..type = type;

    await isar.writeTxn(() async {
      await isar.calculatorHistorys.put(newItem);
      final count =
          await isar.calculatorHistorys.where().typeEqualTo(type).count();
      if (count > maxHistoryItems) {
        final oldestItem = await isar.calculatorHistorys
            .where()
            .typeEqualTo(type)
            .sortByTimestamp()
            .findFirst();
        if (oldestItem != null) {
          await isar.calculatorHistorys.delete(oldestItem.id);
        }
      }
    });
  }

  static Future<List<CalculatorHistory>> getHistory(String type) async {
    if (!await isHistoryEnabled()) return [];
    final isar = IsarService.isar;
    return isar.calculatorHistorys
        .where()
        .typeEqualTo(type)
        .sortByTimestampDesc()
        .findAll();
  }

  static Future<void> clearHistory(String type) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.calculatorHistorys.where().typeEqualTo(type).deleteAll();
    });
  }

  static Future<void> clearAllHistory() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() => isar.calculatorHistorys.clear());
  }

  static Future<int> getHistoryCount() async {
    if (!await isHistoryEnabled()) return 0;
    final isar = IsarService.isar;
    return await isar.calculatorHistorys.count();
  }

  static Future<int> getHistorySize() async {
    if (!await isHistoryEnabled()) return 0;
    final isar = IsarService.isar;
    final allHistory = await isar.calculatorHistorys.where().findAll();
    int size = 0;
    for (final item in allHistory) {
      size += item.expression.length * 2; // Estimate size in bytes (UTF-16)
      size += item.result.length * 2;
      size += 8; // for timestamp (DateTime)
      size += item.type.length * 2;
    }
    return size;
  }
}

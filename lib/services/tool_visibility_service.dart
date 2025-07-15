import 'package:setpocket/models/tool_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ToolVisibilityService {
  static const String _visibilityKey = 'tool_visibility';
  static const String _orderKey = 'tool_order'; // Default tool configuration
  static const Map<String, ToolConfig> _defaultTools = {
    'p2pDataTransfer': ToolConfig(
      id: 'p2pDataTransfer',
      fixName: 'P2P File Transfer',
      nameKey: 'p2pDataTransfer',
      descKey: 'p2pDataTransferDesc',
      icon: 'share',
      iconColor: 'teal',
      isVisible: true,
      order: 0,
    ),
    'calculatorTools': ToolConfig(
      id: 'calculatorTools',
      fixName: 'Calculator Tools',
      nameKey: 'calculatorTools',
      descKey: 'calculatorToolsDesc',
      icon: 'calculate',
      iconColor: 'orange',
      isVisible: true,
      order: 1,
    ),
    'converterTools': ToolConfig(
      id: 'converterTools',
      fixName: 'Converter Tools',
      nameKey: 'converterTools',
      descKey: 'converterToolsDesc',
      icon: 'swap_horiz',
      iconColor: 'green',
      isVisible: true,
      order: 2,
    ),
    'randomTools': ToolConfig(
      id: 'randomTools',
      fixName: 'Random Tools',
      nameKey: 'random',
      descKey: 'randomDesc',
      icon: 'casino',
      iconColor: 'purple',
      isVisible: true,
      order: 3,
    ),
    'textTemplate': ToolConfig(
      id: 'textTemplate',
      fixName: 'Text Template Generator',
      nameKey: 'textTemplateGen',
      descKey: 'textTemplateGenDesc',
      icon: 'description',
      iconColor: 'blue800',
      isVisible: true,
      order: 4,
    ),
  };

  static Future<Map<String, bool>> getToolVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final visibilityJson = prefs.getString(_visibilityKey);

    if (visibilityJson == null) {
      // Return default visibility
      return Map.fromEntries(_defaultTools.entries.map(
        (e) => MapEntry(e.key, e.value.isVisible),
      ));
    }

    try {
      final decoded = Map<String, dynamic>.from(
        Uri.splitQueryString(visibilityJson),
      );
      return decoded.map((key, value) => MapEntry(key, value == 'true'));
    } catch (e) {
      // Return default on error
      return Map.fromEntries(_defaultTools.entries.map(
        (e) => MapEntry(e.key, e.value.isVisible),
      ));
    }
  }

  static Future<List<String>> getToolOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final orderString = prefs.getString(_orderKey);

    if (orderString == null) {
      // Return default order
      final sortedTools = _defaultTools.entries.toList()
        ..sort((a, b) => a.value.order.compareTo(b.value.order));
      return sortedTools.map((e) => e.key).toList();
    }

    try {
      return orderString.split(',').where((s) => s.isNotEmpty).toList();
    } catch (e) {
      // Return default on error
      final sortedTools = _defaultTools.entries.toList()
        ..sort((a, b) => a.value.order.compareTo(b.value.order));
      return sortedTools.map((e) => e.key).toList();
    }
  }

  static Future<void> saveToolVisibility(Map<String, bool> visibility) async {
    final prefs = await SharedPreferences.getInstance();
    final queryString =
        visibility.entries.map((e) => '${e.key}=${e.value}').join('&');
    await prefs.setString(_visibilityKey, queryString);
  }

  static Future<void> saveToolOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_orderKey, order.join(','));
  }

  static Future<List<ToolConfig>> getVisibleToolsInOrder() async {
    final visibility = await getToolVisibility();
    final order = await getToolOrder();

    return order
        .where((toolId) => visibility[toolId] == true)
        .map((toolId) => _defaultTools[toolId])
        .where((config) => config != null)
        .cast<ToolConfig>()
        .toList();
  }

  static Future<List<ToolConfig>> getAllToolsInOrder() async {
    final order = await getToolOrder();
    final visibility = await getToolVisibility();

    return order
        .map((toolId) => _defaultTools[toolId])
        .where((config) => config != null)
        .cast<ToolConfig>()
        .map((config) =>
            config.copyWith(isVisible: visibility[config.id] ?? true))
        .toList();
  }

  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_visibilityKey);
    await prefs.remove(_orderKey);
  }

  static Map<String, ToolConfig> get defaultTools => _defaultTools;
}

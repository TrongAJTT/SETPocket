import 'package:shared_preferences/shared_preferences.dart';

class ToolVisibilityService {
  static const String _visibilityKey = 'tool_visibility';
  static const String _orderKey = 'tool_order';

  // Default tool configuration
  static const Map<String, ToolConfig> _defaultTools = {
    'textTemplate': ToolConfig(
      id: 'textTemplate',
      nameKey: 'textTemplateGen',
      descKey: 'textTemplateGenDesc',
      icon: 'description',
      iconColor: 'blue800',
      isVisible: true,
      order: 0,
    ),
    'randomTools': ToolConfig(
      id: 'randomTools',
      nameKey: 'random',
      descKey: 'randomDesc',
      icon: 'casino',
      iconColor: 'purple',
      isVisible: true,
      order: 1,
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

class ToolConfig {
  final String id;
  final String nameKey;
  final String descKey;
  final String icon;
  final String iconColor;
  final bool isVisible;
  final int order;

  const ToolConfig({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.icon,
    required this.iconColor,
    required this.isVisible,
    required this.order,
  });

  ToolConfig copyWith({
    String? id,
    String? nameKey,
    String? descKey,
    String? icon,
    String? iconColor,
    bool? isVisible,
    int? order,
  }) {
    return ToolConfig(
      id: id ?? this.id,
      nameKey: nameKey ?? this.nameKey,
      descKey: descKey ?? this.descKey,
      icon: icon ?? this.icon,
      iconColor: iconColor ?? this.iconColor,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
    );
  }
}

// utils/icon_mapper.dart
import 'package:flutter/material.dart';

class IconMapper {
  static const Map<String, IconData> _iconMap = {
    'star_outline': Icons.star_outline,
    'speed': Icons.speed,
    'functions': Icons.functions,
    'rotate_left': Icons.rotate_left,
    'alt_route': Icons.alt_route,
    'history': Icons.history,
    'memory': Icons.memory,
    'help_outline': Icons.help_outline,
    'lightbulb_outline': Icons.lightbulb_outline,
    'category': Icons.category,
    'settings': Icons.settings,
    'build': Icons.build,
    'calculate': Icons.calculate,
    'people': Icons.people,
    'insights': Icons.insights,
    'monitor_weight': Icons.monitor_weight,
    'straighten': Icons.straighten,
    'share': Icons.share,
    'warning_outlined': Icons.warning_outlined,
    'swap_horiz': Icons.swap_horiz,
    'medical_services': Icons.medical_services,
    'casino': Icons.casino,
    'trending_up': Icons.trending_up,
    'description': Icons.description,
    'info_outline': Icons.info_outline,
    'check_circle_outline': Icons.check_circle_outline,
    'error_outline': Icons.error_outline,
    'visibility': Icons.visibility,
    'visibility_off': Icons.visibility_off,
    'favorite_border': Icons.favorite_border,
    'favorite': Icons.favorite,
    'bookmark_border': Icons.bookmark_border,
    'bookmark': Icons.bookmark,
    'search': Icons.search,
    'add_circle_outline': Icons.add_circle_outline,
    'remove_circle_outline': Icons.remove_circle_outline,
    'edit': Icons.edit,
    'home': Icons.home,
    'person': Icons.person,
    'savings': Icons.savings,
    'business_center': Icons.business_center,
    'attach_money': Icons.attach_money,
  };

  static const Map<String, Color> _colorMap = {
    'amber': Colors.amber,
    'orange': Colors.orange,
    'blue': Colors.blue,
    'green': Colors.green,
    'purple': Colors.purple,
    'indigo': Colors.indigo,
    'teal': Colors.teal,
    'grey': Colors.grey,
    'red': Colors.red,
  };

  static IconData getIcon(String name) {
    return _iconMap[name] ?? Icons.help; // Icon mặc định
  }

  static Color getColor(String name) {
    return _colorMap[name] ?? Colors.grey; // Màu mặc định
  }
}

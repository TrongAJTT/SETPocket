import 'package:flutter/material.dart';
import 'package:setpocket/screens/converter_tools/speed_converter_screen.dart';
import 'package:setpocket/screens/converter_tools/length_converter_screen.dart';
import 'package:setpocket/screens/converter_tools/currency_converter_screen.dart';
import 'package:setpocket/screens/converter_tools/mass_converter_screen.dart';
import 'package:setpocket/screens/converter_tools/temperature_converter_screen.dart';
import 'package:setpocket/screens/converter_tools/volume_converter_screen.dart';
import 'package:setpocket/screens/converter_tools/area_converter_screen.dart';
import 'package:setpocket/screens/converter_tools/time_converter_screen.dart';
import 'package:setpocket/screens/converter_tools/data_converter_screen.dart';
import 'package:setpocket/screens/converter_tools/number_system_converter_screen.dart';
import 'package:setpocket/screens/p2lan_transfer/p2lan_transfer_screen.dart';
import 'package:setpocket/screens/calculator_tools/scientific_calculator_screen.dart';
import 'package:setpocket/screens/calculator_tools/bmi_calculator_screen.dart';
import 'package:setpocket/screens/text_template/text_template_list_screen.dart';
import 'package:setpocket/widgets/navigation/profile_tool_selection_screen.dart';

/// Service để tái tạo tool widgets dựa trên toolId
/// Được sử dụng khi khôi phục state sau app restart
class ProfileWidgetFactory {
  static ProfileWidgetFactory? _instance;
  static ProfileWidgetFactory get instance {
    _instance ??= ProfileWidgetFactory._();
    return _instance!;
  }

  ProfileWidgetFactory._();

  /// Tái tạo widget dựa trên toolId và các thông tin đã lưu
  Widget recreateWidget({
    required String toolId,
    bool isEmbedded = true,
    Function(Widget, String, {String? parentCategory, IconData? icon})?
        onToolSelected,
    int? forTabIndex,
    void Function(Widget)? onPushToTabStack,
  }) {
    switch (toolId) {
      case 'tool_selection':
        return ProfileToolSelectionScreen(
          isEmbedded: isEmbedded,
          onToolSelected: onToolSelected,
          forTabIndex: forTabIndex,
          onPushToTabStack: onPushToTabStack,
        );

      // Converter Tools
      case 'speed':
        return const SpeedConverterScreen(isEmbedded: true);
      case 'length':
        return const LengthConverterNewScreen(isEmbedded: true);
      case 'currency':
        return const CurrencyConverterScreen(isEmbedded: true);
      case 'mass':
        return const MassConverterNewScreen(isEmbedded: true);
      case 'temperature':
        return const TemperatureConverterScreen(isEmbedded: true);
      case 'volume':
        return const VolumeConverterScreen(isEmbedded: true);
      case 'area':
        return const AreaConverterScreen(isEmbedded: true);
      case 'time':
        return const TimeConverterScreen(isEmbedded: true);
      case 'data':
        return const DataConverterScreen(isEmbedded: true);
      case 'numberSystem':
        return const NumberSystemConverterScreen(isEmbedded: true);

      // P2P Tools
      case 'p2pDataTransfer':
        return const P2LanTransferScreen(isEmbedded: true);

      // Calculator Tools
      case 'scientific_calculator':
        return ScientificCalculatorScreen(isEmbedded: isEmbedded);
      case 'bmi_calculator':
        return BmiCalculatorScreen(isEmbedded: isEmbedded);

      // Text Template
      case 'textTemplate':
        return TemplateListScreen(isEmbedded: isEmbedded);

      // Unknown tools - fallback to tool selection
      default:
        return ProfileToolSelectionScreen(
          isEmbedded: isEmbedded,
          onToolSelected: onToolSelected,
          forTabIndex: forTabIndex,
          onPushToTabStack: onPushToTabStack,
        );
    }
  }

  /// Kiểm tra xem toolId có được hỗ trợ không
  bool isToolSupported(String toolId) {
    const supportedTools = {
      'tool_selection',
      'speed',
      'length',
      'currency',
      'mass',
      'temperature',
      'volume',
      'area',
      'time',
      'data',
      'numberSystem',
      'p2pDataTransfer',
      'scientific_calculator',
      'bmi_calculator',
      'textTemplate',
    };
    return supportedTools.contains(toolId);
  }

  /// Lấy danh sách tất cả tool IDs được hỗ trợ
  List<String> getSupportedToolIds() {
    return [
      'tool_selection',
      'speed',
      'length',
      'currency',
      'mass',
      'temperature',
      'volume',
      'area',
      'time',
      'data',
      'numberSystem',
      'p2pDataTransfer',
      'scientific_calculator',
      'bmi_calculator',
      'textTemplate',
    ];
  }
}

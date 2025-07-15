import 'package:flutter/material.dart';
import 'package:setpocket/controllers/mobile_appbar_controller.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/layouts/base_responsive_layout.dart';
import 'package:setpocket/models/tool_config.dart';
import 'package:setpocket/services/tool_visibility_service.dart';
import 'package:setpocket/services/profile_tab_service.dart';
import 'package:setpocket/services/profile_breadcrumb_service.dart';
import 'package:setpocket/utils/generic_settings_utils.dart';
import 'package:setpocket/utils/variables_utils.dart';
import 'package:setpocket/variables.dart';
import 'package:setpocket/widgets/tool_card.dart';
import 'package:setpocket/screens/text_template/text_template_list_screen.dart';
import 'package:setpocket/screens/random_tools_screen.dart';
import 'package:setpocket/screens/converter_tools_screen.dart';
import 'package:setpocket/screens/calculator_tools_screen.dart';
import 'package:setpocket/screens/p2lan_transfer/p2lan_transfer_screen.dart';

/// ToolSelectionScreen được tối ưu cho Profile Tab system
class ProfileToolSelectionScreen extends StatefulWidget {
  final bool isEmbedded;
  final Function(Widget, String, {String? parentCategory, IconData? icon})?
      onToolSelected;
  final int? forTabIndex; // Chỉ định tab nào đang sử dụng screen này

  const ProfileToolSelectionScreen({
    super.key,
    this.isEmbedded = false,
    this.onToolSelected,
    this.forTabIndex,
  });

  @override
  State<ProfileToolSelectionScreen> createState() =>
      _ProfileToolSelectionScreenState();
}

class _ProfileToolSelectionScreenState extends State<ProfileToolSelectionScreen>
    with SingleTickerProviderStateMixin, BaseResponsiveLayout {
  List<ToolConfig> _visibleTools = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVisibleTools();
  }

  @override
  void syncMobileAppBar() {
    final loc = AppLocalizations.of(context)!;

    if (isMobileLayoutContext(context)) {
      final controller = MobileAppBarController();
      controller.setAppBar(
        title: appName,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => GenericSettingsUtils.navigateAbout(context),
            tooltip: loc.about,
          ),
        ],
      );
    }
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) {
      _loadVisibleTools();
    }
  }

  Future<void> _loadVisibleTools() async {
    final tools = await ToolVisibilityService.getVisibleToolsInOrder();
    setState(() {
      _visibleTools = tools;
      _loading = false;
    });

    if (mounted && !hasInitialized) {
      hasInitialized = true;
      syncMobileAppBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if no tools are visible
    if (_visibleTools.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.visibility_off,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                loc.allToolsHidden,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.allToolsHiddenDesc,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final content = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tool cards
        ..._visibleTools.map((config) {
          return ToolCard(
            title: _getLocalizedName(context, config.nameKey),
            description: _getLocalizedDesc(context, config.descKey),
            icon: _getIconData(config.icon),
            iconColor: _getIconColor(config.iconColor),
            isSelected: false,
            onTap: () => _handleToolSelection(config),
          );
        }).toList(),
      ],
    );

    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.selectTool),
        ),
        body: content,
      );
    }
  }

  void _handleToolSelection(ToolConfig config) {
    final tool = _getToolWidget(config);
    final toolTitle = _getLocalizedName(context, config.nameKey);
    final toolIcon = _getIconData(config.icon);
    final toolIconColor = _getIconColor(config.iconColor);

    // Cập nhật tab profile nếu có chỉ định tab
    if (widget.forTabIndex != null) {
      ProfileTabService.instance.updateTabTool(
        tabIndex: widget.forTabIndex!,
        toolId: config.id,
        toolTitle: toolTitle,
        icon: toolIcon,
        iconColor: toolIconColor,
        toolWidget: tool,
        parentCategory: _getSelectedToolType(config),
      );

      // Thêm breadcrumb cho category tools (RandomToolsScreen, ConverterToolsScreen, etc.)
      if (widget.isEmbedded && _isCategoryTool(config.id)) {
        ProfileBreadcrumbService.instance.pushBreadcrumb(
          title: toolTitle,
          toolId: config.id,
          toolWidget: tool,
          icon: toolIcon,
          isCategory: true, // Đánh dấu đây là category level
        );
      }

      // Thêm breadcrumb cho direct tools (P2Lan, etc.)
      if (widget.isEmbedded && _isDirectTool(config.id)) {
        ProfileBreadcrumbService.instance.pushBreadcrumb(
          title: toolTitle,
          toolId: config.id,
          toolWidget: tool,
          icon: toolIcon,
          isCategory:
              true, // Direct tools được treat như category để có thể hiển thị breadcrumb
        );
      }
    }

    // Callback để hiển thị tool - gọi sau khi đã cập nhật tab và breadcrumb
    if (widget.onToolSelected != null) {
      widget.onToolSelected!(
        tool,
        toolTitle,
        icon: toolIcon,
        parentCategory: _getSelectedToolType(config),
      );
    } else if (!widget.isEmbedded) {
      // Mobile navigation
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => tool),
      );
    }
  }

  Widget _getToolWidget(ToolConfig config) {
    // Tạo callback để handle sub-navigation trong embedded mode
    void Function(Widget, String, {String? parentCategory, IconData? icon})?
        toolSelectedCallback;

    if (widget.isEmbedded && widget.onToolSelected != null) {
      toolSelectedCallback = (subWidget, title, {parentCategory, icon}) {
        // Thêm vào breadcrumb stack như sub-tool (không phải category)
        ProfileBreadcrumbService.instance.pushBreadcrumb(
          title: title,
          toolId: '${config.id}_sub',
          toolWidget: subWidget,
          icon: icon,
          isCategory: false, // Đánh dấu đây là sub-tool level
        );

        // Cập nhật tab hiện tại với sub-tool
        if (widget.forTabIndex != null) {
          ProfileTabService.instance.updateTabTool(
            tabIndex: widget.forTabIndex!,
            toolId: '${config.id}_sub',
            toolTitle: title,
            icon: icon ?? _getIconData(config.icon),
            iconColor: _getIconColor(config.iconColor),
            toolWidget: subWidget,
            parentCategory: parentCategory,
          );
        }
        widget.onToolSelected?.call(subWidget, title,
            parentCategory: parentCategory, icon: icon);
      };
    }

    switch (config.id) {
      case 'textTemplate':
        return TemplateListScreen(
          isEmbedded: widget.isEmbedded,
          onToolSelected: toolSelectedCallback,
        );
      case 'randomTools':
        return RandomToolsScreen(
          isEmbedded: widget.isEmbedded,
          onToolSelected: toolSelectedCallback,
        );
      case 'converterTools':
        return ConverterToolsScreen(
          isEmbedded: widget.isEmbedded,
          onToolSelected: toolSelectedCallback,
        );
      case 'calculatorTools':
        return CalculatorToolsScreen(
          isEmbedded: widget.isEmbedded,
          onToolSelected: toolSelectedCallback,
        );
      case 'p2pDataTransfer':
        return P2LanTransferScreen(isEmbedded: widget.isEmbedded);
      default:
        return const SizedBox.shrink();
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'description':
        return Icons.description;
      case 'casino':
        return Icons.casino;
      case 'swap_horiz':
        return Icons.swap_horiz;
      case 'calculate':
        return Icons.calculate;
      case 'share':
        return Icons.share;
      default:
        return Icons.extension;
    }
  }

  Color _getIconColor(String colorName) {
    switch (colorName) {
      case 'blue800':
        return Colors.blue.shade800;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getLocalizedName(BuildContext context, String nameKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (nameKey) {
      case 'textTemplateGen':
        return l10n.textTemplateGen;
      case 'random':
        return l10n.random;
      case 'converterTools':
        return l10n.converterTools;
      case 'calculatorTools':
        return l10n.calculatorTools;
      case 'p2pDataTransfer':
        return l10n.p2lanTransfer;
      default:
        return nameKey;
    }
  }

  String _getLocalizedDesc(BuildContext context, String descKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (descKey) {
      case 'textTemplateGenDesc':
        return l10n.textTemplateGenDesc;
      case 'randomDesc':
        return l10n.randomDesc;
      case 'converterToolsDesc':
        return l10n.converterToolsDesc;
      case 'calculatorToolsDesc':
        return l10n.calculatorToolsDesc;
      case 'p2pDataTransferDesc':
        return l10n.p2pDataTransferDesc;
      default:
        return descKey;
    }
  }

  String _getSelectedToolType(ToolConfig config) {
    switch (config.id) {
      case 'textTemplate':
        return 'TemplateListScreen';
      case 'randomTools':
        return 'RandomToolsScreen';
      case 'converterTools':
        return 'ConverterToolsScreen';
      case 'calculatorTools':
        return 'CalculatorToolsScreen';
      case 'p2pDataTransfer':
        return 'P2LanTransferScreen';
      default:
        return '';
    }
  }

  /// Kiểm tra xem tool có phải là category tool (có sub-tools) không
  bool _isCategoryTool(String toolId) {
    switch (toolId) {
      case 'randomTools':
      case 'converterTools':
      case 'calculatorTools':
      case 'textTemplate':
        return true;
      default:
        return false;
    }
  }

  /// Kiểm tra xem có phải là direct tool (cần breadcrumb nhưng không phải category)
  bool _isDirectTool(String toolId) {
    switch (toolId) {
      case 'p2pDataTransfer':
        return true;
      default:
        return false;
    }
  }
}

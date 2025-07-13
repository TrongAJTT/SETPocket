import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/widgets/generic/option_item.dart';
import 'package:setpocket/widgets/generic/option_card.dart';
import 'package:setpocket/widgets/settings/tool_visibility_dialog.dart';
import 'package:setpocket/widgets/settings/quick_actions_dialog.dart';
import 'package:setpocket/utils/generic_settings_utils.dart';

/// Tools Management Settings Module
/// Handles tool visibility, quick actions, and individual tool settings
class ToolsManagementSettings extends StatelessWidget {
  final bool isEmbedded;
  final VoidCallback? onToolVisibilityChanged;

  const ToolsManagementSettings({
    super.key,
    this.isEmbedded = false,
    this.onToolVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tools & Shortcuts Section
        _buildToolVisibilitySettings(context, loc),
        const SizedBox(height: 16),
        _buildQuickActionsSettings(context, loc),

        const SizedBox(height: 24),

        // Individual Tools Settings Section
        Text(
          'Individual Tools Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),

        _buildRandomToolsSettingsCard(context, loc),
        const SizedBox(height: 16),
        _buildConverterToolsSettingsCard(context, loc),
        const SizedBox(height: 16),
        _buildCalculatorToolsSettingsCard(context, loc),
        const SizedBox(height: 16),
        _buildP2PTransferSettingsCard(context, loc),
      ],
    );
  }

  Widget _buildToolVisibilitySettings(
      BuildContext context, AppLocalizations loc) {
    return OptionCard(
      onTap: () => _showToolVisibilityDialog(context),
      option: OptionItem.withIcon(
        value: null,
        label: loc.displayArrangeTools,
        subtitle: loc.displayArrangeToolsDesc,
        iconData: Icons.tune,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      decorator: const CardDecorator(),
    );
  }

  Widget _buildQuickActionsSettings(
      BuildContext context, AppLocalizations loc) {
    return OptionCard(
      onTap: () => _showQuickActionsDialog(context),
      option: OptionItem.withIcon(
        value: null,
        label: loc.manageQuickActions,
        subtitle: loc.manageQuickActionsDesc,
        iconData: Icons.flash_on,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildRandomToolsSettingsCard(
      BuildContext context, AppLocalizations loc) {
    return OptionCard(
      onTap: () => _showRandomToolsSettings(context),
      option: OptionItem.withIcon(
        value: null,
        label: 'Random Tools Settings',
        subtitle: 'Configure generation history and state saving',
        iconData: Icons.casino,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      decorator: const CardDecorator(),
    );
  }

  Widget _buildConverterToolsSettingsCard(
      BuildContext context, AppLocalizations loc) {
    return OptionCard(
      onTap: () => _showConverterToolsSettings(context),
      option: OptionItem.withIcon(
        value: null,
        label: 'Converter Tools Settings',
        subtitle: 'Configure currency fetching and state saving',
        iconData: Icons.transform,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      decorator: const CardDecorator(),
    );
  }

  Widget _buildCalculatorToolsSettingsCard(
      BuildContext context, AppLocalizations loc) {
    return OptionCard(
      onTap: () => _showCalculatorToolsSettings(context),
      option: OptionItem.withIcon(
        value: null,
        label: loc.calculatorTools,
        subtitle: 'History and computation settings',
        iconData: Icons.calculate,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      decorator: const CardDecorator(),
    );
  }

  Widget _buildP2PTransferSettingsCard(
      BuildContext context, AppLocalizations loc) {
    return OptionCard(
      onTap: () => _showP2PTransferSettings(context),
      option: OptionItem.withIcon(
        value: null,
        label: 'P2P Transfer Settings',
        subtitle: 'File transfer and network configuration',
        iconData: Icons.share,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      decorator: const CardDecorator(),
    );
  }

  // Event handlers
  void _showToolVisibilityDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => ToolVisibilityDialog(
        onChanged: () {
          // Refresh parent if needed
          if (isEmbedded && onToolVisibilityChanged != null) {
            onToolVisibilityChanged!();
          }
        },
      ),
    );
  }

  void _showQuickActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const QuickActionsDialog(),
    );
  }

  void _showRandomToolsSettings(BuildContext context) {
    GenericSettingsUtils.quickOpenRandomToolsSettings(
      context,
      showSuccessMessage: false, // No need for success message in main settings
    );
  }

  void _showConverterToolsSettings(BuildContext context) {
    GenericSettingsUtils.quickOpenConverterToolsSettings(
      context,
      showSuccessMessage: false, // No need for success message in main settings
    );
  }

  void _showCalculatorToolsSettings(BuildContext context) {
    GenericSettingsUtils.quickOpenCalculatorToolsSettings(context);
  }

  void _showP2PTransferSettings(BuildContext context) {
    GenericSettingsUtils.quickOpenP2PTransferSettings(context);
  }
}

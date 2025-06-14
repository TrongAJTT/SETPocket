import 'package:flutter/material.dart';
import 'package:setpocket/controllers/area_converter_controller.dart';
import 'package:setpocket/widgets/converter_tools/generic_converter_view.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/app_logger.dart';

class AreaConverterScreen extends StatefulWidget {
  final bool isEmbedded;

  const AreaConverterScreen({super.key, this.isEmbedded = false});

  @override
  State<AreaConverterScreen> createState() => _AreaConverterScreenState();
}

class _AreaConverterScreenState extends State<AreaConverterScreen> {
  late AreaConverterController _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _controller = AreaConverterController();
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      logError('AreaConverterScreen: Error initializing controller: $e');

      // Check if this is the DateTime casting error
      if (e.toString().contains('DateTime') &&
          e.toString().contains('String')) {
        logInfo(
            'AreaConverterScreen: Detected DateTime casting error, clearing cache');
        await _handleDateTimeCastingError();
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to initialize converter: $e';
          });
        }
      }
    }
  }

  Future<void> _handleDateTimeCastingError() async {
    try {
      // Force clear area converter cache
      await _controller.forceClearCache();

      // Try to initialize again
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      }

      logInfo(
          'AreaConverterScreen: Successfully recovered from DateTime casting error');
    } catch (e) {
      logError(
          'AreaConverterScreen: Failed to recover from DateTime casting error: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              'Failed to recover from data corruption. Please restart the app.';
        });
      }
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showAreaInfo() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: isDesktop ? 600 : screenWidth * 0.9,
          height: isDesktop ? 700 : MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.crop_free,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.areaConverterDetailedInfo,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.areaConverterOverview,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // How to Use
                      _buildInfoSection(
                        theme,
                        l10n.howToUse,
                        Icons.help_outline,
                        Colors.blue,
                        [
                          _buildStepItem(
                              theme, l10n.step1Area, l10n.step1AreaDesc),
                          _buildStepItem(
                              theme, l10n.step2Area, l10n.step2AreaDesc),
                          _buildStepItem(
                              theme, l10n.step3Area, l10n.step3AreaDesc),
                          _buildStepItem(
                              theme, l10n.step4Area, l10n.step4AreaDesc),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tips
                      _buildInfoSection(
                        theme,
                        l10n.tips,
                        Icons.lightbulb_outline,
                        Colors.green,
                        [
                          _buildTipItem(theme, l10n.tip1Area),
                          _buildTipItem(theme, l10n.tip2Area),
                          _buildTipItem(theme, l10n.tip3Area),
                          _buildTipItem(theme, l10n.tip4Area),
                          _buildTipItem(theme, l10n.tip5Area),
                          _buildTipItem(theme, l10n.tip6Area),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Unit Categories
                      _buildInfoSection(
                        theme,
                        l10n.areaUnitCategories,
                        Icons.category,
                        Colors.purple,
                        [
                          _buildCategoryItem(theme, l10n.commonUnits,
                              l10n.commonUnitsAreaDesc),
                          _buildCategoryItem(theme, l10n.lessCommonUnits,
                              l10n.lessCommonUnitsAreaDesc),
                          _buildCategoryItem(theme, l10n.uncommonUnits,
                              l10n.uncommonUnitsAreaDesc),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Practical Applications
                      _buildInfoSection(
                        theme,
                        l10n.practicalApplications,
                        Icons.build,
                        Colors.teal,
                        [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(
                              l10n.practicalApplicationsAreaDesc,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check),
                      label: Text(l10n.close),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String title, IconData icon,
      Color color, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(ThemeData theme, String step, String description) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.substring(5, 6), // Extract step number
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(ThemeData theme, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Text(
        tip,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildCategoryItem(ThemeData theme, String title, String description) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                  _initializeController();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return GenericConverterView(
          controller: _controller,
          isEmbedded: widget.isEmbedded,
          title: l10n.areaConverter,
          titleIcon: Icons.crop_free,
          onShowInfo: _showAreaInfo,
        );
      },
    );
  }
}

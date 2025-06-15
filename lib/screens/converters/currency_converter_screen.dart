import 'package:flutter/material.dart';
import 'package:setpocket/controllers/currency_converter_controller.dart';
import 'package:setpocket/widgets/converter_tools/generic_converter_view.dart';
import 'package:setpocket/widgets/converter_tools/currency_fetch_status_dialog.dart';
import 'package:setpocket/widgets/converter_tools/currency_fetch_progress_dialog.dart';
import 'package:setpocket/services/converter_services/currency_cache_service.dart';
import 'package:setpocket/services/converter_services/currency_service.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/l10n/app_localizations.dart';

class CurrencyConverterScreen extends StatefulWidget {
  final bool isEmbedded;

  const CurrencyConverterScreen({super.key, this.isEmbedded = false});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  late CurrencyConverterController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = CurrencyConverterController();
    await _controller.initialize();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _showFetchStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CurrencyFetchStatusDialog(),
    );
  }

  void _showRateLimitDialog(Duration remainingTime) {
    final l10n = AppLocalizations.of(context)!;

    // Format remaining time
    String formatDuration(Duration duration) {
      int hours = duration.inHours;
      int minutes = duration.inMinutes.remainder(60);

      if (hours > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${minutes}m';
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.access_time,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.rateLimitReached),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.rateLimitMessage),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .errorContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.nextFetchAllowedIn(
                              formatDuration(remainingTime)),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.rateLimitInfo,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onErrorContainer
                              .withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.understood),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshCurrencyRates() async {
    // Check rate limiting for manual fetch
    final isAllowed = await CurrencyCacheService.isManualFetchAllowed();
    if (!isAllowed) {
      final remainingTime =
          await CurrencyCacheService.getManualFetchCooldownRemaining();
      if (remainingTime != null && mounted) {
        _showRateLimitDialog(remainingTime);
        return;
      }
    }

    try {
      // Get timeout from settings
      final fetchTimeout = await SettingsService.getFetchTimeout();

      // Show progress dialog
      final currencies =
          CurrencyService.getSupportedCurrencies().map((c) => c.code).toList();

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return CurrencyFetchProgressDialog(
            timeoutSeconds: fetchTimeout,
            currencies: currencies,
            onCancel: () {
              CurrencyService.cancelFetch();
            },
            onComplete: () {},
          );
        },
      );

      // Small delay to ensure dialog is rendered
      await Future.delayed(const Duration(milliseconds: 200));

      await _controller.refreshData();

      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error refreshing rates')),
        );
      }
    }
  }

  void _showInfoDialog(BuildContext context) {
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
                        Icons.currency_exchange,
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
                            l10n.currencyConverterDetailedInfo,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.currencyConverterOverview,
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
                      // Key Features
                      _buildInfoSection(
                        theme,
                        l10n.keyFeatures,
                        Icons.star_outline,
                        Colors.orange,
                        [
                          _buildFeatureItem(theme, l10n.multipleCards,
                              l10n.multipleCardsDesc, Icons.credit_card),
                          _buildFeatureItem(theme, l10n.liveRates,
                              l10n.liveRatesDesc, Icons.trending_up),
                          _buildFeatureItem(theme, l10n.customizeCurrencies,
                              l10n.customizeCurrenciesDesc, Icons.tune),
                          _buildFeatureItem(theme, l10n.dragAndDrop,
                              l10n.dragAndDropDesc, Icons.drag_handle),
                          _buildFeatureItem(theme, l10n.cardAndTableView,
                              l10n.cardAndTableViewDesc, Icons.view_agenda),
                          _buildFeatureItem(theme, l10n.stateManagement,
                              l10n.stateManagementDesc, Icons.save),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // How to Use
                      _buildInfoSection(
                        theme,
                        l10n.howToUse,
                        Icons.help_outline,
                        Colors.blue,
                        [
                          _buildStepItem(theme, l10n.step1, l10n.step1Desc),
                          _buildStepItem(theme, l10n.step2, l10n.step2Desc),
                          _buildStepItem(theme, l10n.step3, l10n.step3Desc),
                          _buildStepItem(theme, l10n.step4, l10n.step4Desc),
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
                          _buildTipItem(theme, l10n.tip1),
                          _buildTipItem(theme, l10n.tip2),
                          _buildTipItem(theme, l10n.tip3),
                          _buildTipItem(theme, l10n.tip4),
                          _buildTipItem(theme, l10n.tip5),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Rate Updates
                      _buildInfoSection(
                        theme,
                        l10n.rateUpdate,
                        Icons.update,
                        Colors.purple,
                        [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              l10n.rateUpdateDesc,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Focus Mode
                      _buildInfoSection(
                        theme,
                        l10n.focusModeHelpTitle,
                        Icons.center_focus_strong,
                        Colors.indigo,
                        [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.focusModeHelpDescription,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.focusModeHelpHidden,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.focusModeHelpHiddenStatus,
                                    style: theme.textTheme.bodySmall),
                                Text(l10n.focusModeHelpHiddenButtons,
                                    style: theme.textTheme.bodySmall),
                                Text(l10n.focusModeHelpHiddenViewMode,
                                    style: theme.textTheme.bodySmall),
                                Text(l10n.focusModeHelpHiddenStats,
                                    style: theme.textTheme.bodySmall),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.focusModeHelpActivation,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.focusModeHelpActivationDesktop,
                                    style: theme.textTheme.bodySmall),
                                Text(l10n.focusModeHelpActivationMobile,
                                    style: theme.textTheme.bodySmall),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.focusModeHelpDeactivation,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(l10n.focusModeHelpDeactivationDesktop,
                                    style: theme.textTheme.bodySmall),
                                Text(l10n.focusModeHelpDeactivationMobile,
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Data Attribution
                      _buildInfoSection(
                        theme,
                        l10n.dataAttribution,
                        Icons.attribution,
                        Colors.teal,
                        [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.apiProviderAttribution,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.link,
                                        size: 16,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'ExchangeRate-API.com',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

  Widget _buildFeatureItem(
      ThemeData theme, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
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
                step.substring(0, 1),
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

  @override
  Widget build(BuildContext context) {
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
          title: l10n.currencyConverter,
          titleIcon: Icons.currency_exchange,
          onShowInfo: () => _showInfoDialog(context),
          onShowStatus: () => _showFetchStatusDialog(context),
          onRefresh: _refreshCurrencyRates,
        );
      },
    );
  }
}

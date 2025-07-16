import 'package:flutter/material.dart';
import 'package:setpocket/controllers/currency_converter_controller.dart';
import 'package:setpocket/services/function_info_service.dart';
import 'package:setpocket/widgets/converter_tools/generic_converter_view.dart';
import 'package:setpocket/widgets/converter_tools/currency_fetch_status_dialog.dart';
import 'package:setpocket/widgets/converter_tools/currency_fetch_progress_dialog.dart';
import 'package:setpocket/services/converter_services/currency_unified_service.dart';
import 'package:setpocket/services/converter_services/currency_service.dart';
import 'package:setpocket/services/settings_models_service.dart';
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
    final isAllowed = await CurrencyUnifiedService.isManualFetchAllowed();
    if (!isAllowed) {
      final remainingTime =
          await CurrencyUnifiedService.getManualFetchCooldownRemaining();
      if (remainingTime.inSeconds > 0 && mounted) {
        _showRateLimitDialog(remainingTime);
        return;
      }
    }

    try {
      // Get timeout from settings
      final converterSettings =
          await ExtensibleSettingsService.getConverterToolsSettings();
      final fetchTimeout = converterSettings.fetchTimeoutSeconds;

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
            onComplete: () {
              // Re-initialize the controller to pick up the new state from the
              // unified service after the fetch dialog completes. This ensures
              // the UI (like ConverterStatusWidget) reflects the latest data.
              _controller.initialize();
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        // Attempt to pop the dialog if it's still open on error
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing rates: ${e.toString()}')),
        );
      }
    }
  }

  void _showInfoDialog() {
    FunctionInfo.show(context, FunctionInfoKeys.currencyConverter);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                l10n.fetchingRates,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        return GenericConverterView(
          controller: _controller,
          isEmbedded: widget.isEmbedded,
          title: l10n.currencyConverter,
          titleIcon: Icons.currency_exchange,
          onShowInfo: _showInfoDialog,
          onShowStatus: () => _showFetchStatusDialog(context),
          onRefresh: _refreshCurrencyRates,
        );
      },
    );
  }
}

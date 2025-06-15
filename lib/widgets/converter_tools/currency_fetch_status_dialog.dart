import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/converter_services/currency_service.dart';

class CurrencyFetchStatusDialog extends StatefulWidget {
  const CurrencyFetchStatusDialog({super.key});

  @override
  State<CurrencyFetchStatusDialog> createState() =>
      _CurrencyFetchStatusDialogState();
}

class _CurrencyFetchStatusDialogState extends State<CurrencyFetchStatusDialog> {
  int _selectedTabIndex = 0; // 0 = Fetch Status, 1 = Value Status

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;

    final currencies = CurrencyService.getSupportedCurrencies();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 16,
        vertical: isDesktop ? 40 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 700 : screenSize.width * 0.9,
          maxHeight: screenSize.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  Icon(
                    Icons.wifi_tethering,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.currencyFetchStatus,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Mode selector tabs
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTabIndex == 0
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.fetchStatusTab,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: _selectedTabIndex == 0
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: _selectedTabIndex == 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _selectedTabIndex == 1
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          l10n.currencyValueTab,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: _selectedTabIndex == 1
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: _selectedTabIndex == 1
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content based on selected tab
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildFetchStatusView(currencies, l10n, theme)
                  : _buildValueStatusView(currencies, l10n, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFetchStatusView(
      List<Currency> currencies, AppLocalizations l10n, ThemeData theme) {
    final statuses = CurrencyService.currencyStatuses;

    // Group currencies by fetch status (only success, failed, timeout)
    final successCurrencies = <String>[];
    final failedCurrencies = <String>[];
    final timeoutCurrencies = <String>[];

    for (final currency in currencies) {
      final status = statuses[currency.code] ?? CurrencyStatus.staticRate;
      switch (status) {
        case CurrencyStatus.success:
        case CurrencyStatus.fetchedRecently:
          successCurrencies.add(currency.code);
          break;
        case CurrencyStatus.failed:
          failedCurrencies.add(currency.code);
          break;
        case CurrencyStatus.timeout:
          timeoutCurrencies.add(currency.code);
          break;
        case CurrencyStatus.staticRate:
        case CurrencyStatus.notSupported:
        case CurrencyStatus.fetching:
          // Don't show these in fetch status
          break;
      }
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                text: l10n.successfulCount(successCurrencies.length),
              ),
              Tab(
                icon: const Icon(Icons.error, color: Colors.red),
                text: l10n.failedCount(failedCurrencies.length),
              ),
              Tab(
                icon: const Icon(Icons.access_time, color: Colors.orange),
                text: l10n.timeoutCount(timeoutCurrencies.length),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCurrencyList(
                    context, successCurrencies, CurrencyStatus.success),
                _buildCurrencyList(
                    context, failedCurrencies, CurrencyStatus.failed),
                _buildCurrencyList(
                    context, timeoutCurrencies, CurrencyStatus.timeout),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueStatusView(
      List<Currency> currencies, AppLocalizations l10n, ThemeData theme) {
    // Group currencies by value status
    final recentlyUpdatedCurrencies = <String>[];
    final updatedCurrencies = <String>[];
    final staticCurrencies = <String>[];

    for (final currency in currencies) {
      final valueStatus = CurrencyService.getCurrencyValueStatus(currency.code);
      switch (valueStatus) {
        case CurrencyValueStatus.recentlyUpdated:
          recentlyUpdatedCurrencies.add(currency.code);
          break;
        case CurrencyValueStatus.updated:
          updatedCurrencies.add(currency.code);
          break;
        case CurrencyValueStatus.static:
          staticCurrencies.add(currency.code);
          break;
      }
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.access_time, color: Colors.green),
                text:
                    l10n.recentlyUpdatedCount(recentlyUpdatedCurrencies.length),
              ),
              Tab(
                icon: const Icon(Icons.update, color: Colors.blue),
                text: l10n.updatedCount(updatedCurrencies.length),
              ),
              Tab(
                icon: const Icon(Icons.storage, color: Colors.grey),
                text: l10n.staticCount(staticCurrencies.length),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildValueCurrencyList(context, recentlyUpdatedCurrencies,
                    CurrencyValueStatus.recentlyUpdated),
                _buildValueCurrencyList(
                    context, updatedCurrencies, CurrencyValueStatus.updated),
                _buildValueCurrencyList(
                    context, staticCurrencies, CurrencyValueStatus.static),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyList(
    BuildContext context,
    List<String> currencyCodes,
    CurrencyStatus status,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencies = CurrencyService.getSupportedCurrencies();

    if (currencyCodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getFetchStatusIcon(status),
              size: 48,
              color: _getFetchStatusColor(status).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCurrenciesInCategory,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: currencyCodes.length,
      itemBuilder: (context, index) {
        final currencyCode = currencyCodes[index];
        final currency = currencies.firstWhere(
          (c) => c.code == currencyCode,
          orElse: () => Currency(currencyCode, currencyCode, currencyCode),
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getFetchStatusColor(status).withValues(alpha: 0.05),
            border: Border.all(
              color: _getFetchStatusColor(status).withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Currency symbol
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getFetchStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    currency.symbol,
                    style: TextStyle(
                      color: _getFetchStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Currency info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currencyCode - ${currency.name}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyService.getLocalizedStatusDescription(
                          currencyCode, l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Fetch time
              Text(
                _getFetchTime(currencyCode),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),

              const SizedBox(width: 8),

              // Status icon
              Icon(
                _getFetchStatusIcon(status),
                color: _getFetchStatusColor(status),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildValueCurrencyList(
    BuildContext context,
    List<String> currencyCodes,
    CurrencyValueStatus valueStatus,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currencies = CurrencyService.getSupportedCurrencies();

    if (currencyCodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getValueStatusIcon(valueStatus),
              size: 48,
              color: _getValueStatusColor(valueStatus).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCurrenciesInCategory,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: currencyCodes.length,
      itemBuilder: (context, index) {
        final currencyCode = currencyCodes[index];
        final currency = currencies.firstWhere(
          (c) => c.code == currencyCode,
          orElse: () => Currency(currencyCode, currencyCode, currencyCode),
        );

        final fetchTime =
            CurrencyService.getCurrencyLastFetchTime(currencyCode);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getValueStatusColor(valueStatus).withValues(alpha: 0.05),
            border: Border.all(
              color: _getValueStatusColor(valueStatus).withValues(alpha: 0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Currency symbol
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      _getValueStatusColor(valueStatus).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    currency.symbol,
                    style: TextStyle(
                      color: _getValueStatusColor(valueStatus),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Currency info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currencyCode - ${currency.name}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getValueStatusDescription(valueStatus, fetchTime, l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Fetch time
              Text(
                _getFetchTime(currencyCode),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),

              const SizedBox(width: 8),

              // Value status icon
              Icon(
                _getValueStatusIcon(valueStatus),
                color: _getValueStatusColor(valueStatus),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getFetchStatusColor(CurrencyStatus status) {
    switch (status) {
      case CurrencyStatus.success:
      case CurrencyStatus.fetchedRecently:
        return Colors.green;
      case CurrencyStatus.failed:
        return Colors.red;
      case CurrencyStatus.timeout:
        return Colors.orange;
      case CurrencyStatus.staticRate:
      case CurrencyStatus.notSupported:
      case CurrencyStatus.fetching:
        return Colors.grey;
    }
  }

  IconData _getFetchStatusIcon(CurrencyStatus status) {
    switch (status) {
      case CurrencyStatus.success:
      case CurrencyStatus.fetchedRecently:
        return Icons.check_circle;
      case CurrencyStatus.failed:
        return Icons.error;
      case CurrencyStatus.timeout:
        return Icons.access_time;
      case CurrencyStatus.staticRate:
      case CurrencyStatus.notSupported:
        return Icons.storage;
      case CurrencyStatus.fetching:
        return Icons.sync;
    }
  }

  Color _getValueStatusColor(CurrencyValueStatus valueStatus) {
    switch (valueStatus) {
      case CurrencyValueStatus.recentlyUpdated:
        return Colors.green;
      case CurrencyValueStatus.updated:
        return Colors.blue;
      case CurrencyValueStatus.static:
        return Colors.grey;
    }
  }

  IconData _getValueStatusIcon(CurrencyValueStatus valueStatus) {
    switch (valueStatus) {
      case CurrencyValueStatus.recentlyUpdated:
        return Icons.access_time;
      case CurrencyValueStatus.updated:
        return Icons.update;
      case CurrencyValueStatus.static:
        return Icons.storage;
    }
  }

  String _getValueStatusDescription(CurrencyValueStatus valueStatus,
      DateTime? fetchTime, AppLocalizations l10n) {
    switch (valueStatus) {
      case CurrencyValueStatus.recentlyUpdated:
        return l10n.updatedWithinLastHour;
      case CurrencyValueStatus.updated:
        if (fetchTime != null) {
          final now = DateTime.now();
          final difference = now.difference(fetchTime);
          if (difference.inDays > 0) {
            return l10n.updatedDaysAgo(difference.inDays);
          } else {
            return l10n.updatedHoursAgo(difference.inHours);
          }
        }
        return l10n.hasUpdateData;
      case CurrencyValueStatus.static:
        return l10n.usingStaticRates;
    }
  }

  // Get the formatted fetch time for a currency
  String _getFetchTime(String currency) {
    final fetchTime = CurrencyService.getCurrencyLastFetchTime(currency);
    if (fetchTime != null) {
      return '${fetchTime.hour.toString().padLeft(2, '0')}:${fetchTime.minute.toString().padLeft(2, '0')}:${fetchTime.second.toString().padLeft(2, '0')}';
    }
    return '--:--:--'; // Use hardcoded fallback, this is technical format
  }
}

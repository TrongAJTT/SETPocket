import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/currency_service.dart';

class CurrencyFetchStatusDialog extends StatelessWidget {
  const CurrencyFetchStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;

    final statuses = CurrencyService.currencyStatuses;
    final currencies = CurrencyService.getSupportedCurrencies();

    // Group currencies by status
    final successCurrencies = <String>[];
    final failedCurrencies = <String>[];
    final timeoutCurrencies = <String>[];
    final staticCurrencies = <String>[];

    for (final currency in currencies) {
      final status = statuses[currency.code] ?? CurrencyStatus.staticRate;
      switch (status) {
        case CurrencyStatus.success:
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
          staticCurrencies.add(currency.code);
          break;
        case CurrencyStatus.fetchedRecently:
          // Treat fetchedRecently as success for status dialog
          successCurrencies.add(currency.code);
          break;
      }
    }

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
              color: Colors.black.withOpacity(0.15),
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
                    theme.colorScheme.primary.withOpacity(0.8),
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

            // Status summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assessment,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.fetchStatusSummary,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatusChip(
                        context,
                        l10n.success,
                        successCurrencies.length,
                        Colors.green,
                        Icons.check_circle,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        context,
                        l10n.failed,
                        failedCurrencies.length,
                        Colors.red,
                        Icons.error,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        context,
                        l10n.timeout,
                        timeoutCurrencies.length,
                        Colors.orange,
                        Icons.access_time,
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                        context,
                        l10n.static,
                        staticCurrencies.length,
                        Colors.grey,
                        Icons.storage,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Detailed status list
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      tabs: [
                        Tab(
                          icon: Icon(Icons.check_circle, color: Colors.green),
                          text: '${l10n.success} (${successCurrencies.length})',
                        ),
                        Tab(
                          icon: Icon(Icons.error, color: Colors.red),
                          text: '${l10n.failed} (${failedCurrencies.length})',
                        ),
                        Tab(
                          icon: Icon(Icons.access_time, color: Colors.orange),
                          text: '${l10n.timeout} (${timeoutCurrencies.length})',
                        ),
                        Tab(
                          icon: Icon(Icons.storage, color: Colors.grey),
                          text: '${l10n.static} (${staticCurrencies.length})',
                        ),
                      ],
                      isScrollable: true,
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildCurrencyList(context, successCurrencies,
                              CurrencyStatus.success),
                          _buildCurrencyList(
                              context, failedCurrencies, CurrencyStatus.failed),
                          _buildCurrencyList(context, timeoutCurrencies,
                              CurrencyStatus.timeout),
                          _buildCurrencyList(context, staticCurrencies,
                              CurrencyStatus.staticRate),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
              _getStatusIcon(status),
              size: 48,
              color: _getStatusColor(status).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCurrenciesInThisCategory,
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
            color: _getStatusColor(status).withOpacity(0.05),
            border: Border.all(
              color: _getStatusColor(status).withOpacity(0.2),
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
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    currency.symbol,
                    style: TextStyle(
                      color: _getStatusColor(status),
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
                      '${currencyCode} - ${currency.name}',
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
                _getStatusIcon(status),
                color: _getStatusColor(status),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(CurrencyStatus status) {
    switch (status) {
      case CurrencyStatus.success:
        return Colors.green;
      case CurrencyStatus.failed:
        return Colors.red;
      case CurrencyStatus.timeout:
        return Colors.orange;
      case CurrencyStatus.staticRate:
      case CurrencyStatus.notSupported:
        return Colors.grey;
      case CurrencyStatus.fetchedRecently:
        return Colors.green; // Same as success
    }
  }

  IconData _getStatusIcon(CurrencyStatus status) {
    switch (status) {
      case CurrencyStatus.success:
        return Icons.check_circle;
      case CurrencyStatus.failed:
        return Icons.error;
      case CurrencyStatus.timeout:
        return Icons.access_time;
      case CurrencyStatus.staticRate:
      case CurrencyStatus.notSupported:
        return Icons.storage;
      case CurrencyStatus.fetchedRecently:
        return Icons.check_circle; // Same as success
    }
  }

  // Get the formatted fetch time for a currency
  String _getFetchTime(String currency) {
    final fetchTime = CurrencyService.getCurrencyLastFetchTime(currency);
    if (fetchTime != null) {
      return '${fetchTime.hour.toString().padLeft(2, '0')}:${fetchTime.minute.toString().padLeft(2, '0')}:${fetchTime.second.toString().padLeft(2, '0')}';
    }
    return '--:--:--';
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/converter_services/currency_service.dart';
import '../../l10n/app_localizations.dart';

class CurrencyFetchProgressDialog extends StatefulWidget {
  final int timeoutSeconds;
  final List<String> currencies;
  final VoidCallback? onCancel;

  const CurrencyFetchProgressDialog({
    super.key,
    required this.timeoutSeconds,
    required this.currencies,
    this.onCancel,
  });

  @override
  State<CurrencyFetchProgressDialog> createState() =>
      _CurrencyFetchProgressDialogState();
}

class _CurrencyFetchProgressDialogState
    extends State<CurrencyFetchProgressDialog> with TickerProviderStateMixin {
  late Timer _countdownTimer;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  int _remainingSeconds = 0;
  Map<String, CurrencyStatus> _currencyStatuses = {};
  int _completedCount = 0;
  bool _isCompleted = false;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeoutSeconds;

    // Initialize progress animation
    _progressController = AnimationController(
      duration: Duration(seconds: widget.timeoutSeconds),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    // Initialize currency statuses
    for (String currency in widget.currencies) {
      _currencyStatuses[currency] = CurrencyStatus.staticRate; // Initial state
    }

    // Set up progress callback
    CurrencyService.setProgressCallback(_onCurrencyProgress);

    // Start countdown timer
    _startCountdown();

    // Start progress animation
    _progressController.forward();
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    _progressController.dispose();
    CurrencyService.setProgressCallback(null);
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });

        if (_remainingSeconds <= 0 || _isCompleted) {
          timer.cancel();
          if (!_isCompleted) {
            _markAsCompleted();
          }
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _onCurrencyProgress(String currency, CurrencyStatus status) {
    if (mounted && !_isCancelled) {
      setState(() {
        _currencyStatuses[currency] = status;

        // Count completed currencies
        _completedCount = _currencyStatuses.values
            .where((s) => s != CurrencyStatus.staticRate)
            .length;

        // Check if all currencies are completed
        if (_completedCount >= widget.currencies.length) {
          _markAsCompleted();
        }
      });
    }
  }

  void _markAsCompleted() {
    if (!_isCompleted && mounted) {
      setState(() {
        _isCompleted = true;
      });
      _progressController.stop();

      // Auto close after 2 seconds
      Timer(const Duration(seconds: 2), () {
        if (mounted && !_isCancelled) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _cancelFetch() {
    setState(() {
      _isCancelled = true;
    });
    CurrencyService.cancelFetch();
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
    Navigator.of(context).pop();
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
        return Colors.grey;
      case CurrencyStatus.notSupported:
        return Colors.grey;
      case CurrencyStatus.fetchedRecently:
        return Colors.lightBlue;
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
        return Icons.pending;
      case CurrencyStatus.notSupported:
        return Icons.not_interested;
      case CurrencyStatus.fetchedRecently:
        return Icons.schedule;
    }
  }

  String _getStatusText(
      AppLocalizations l10n, String currency, CurrencyStatus status) {
    switch (status) {
      case CurrencyStatus.success:
        return CurrencyService.getLocalizedStatus(currency, l10n);
      case CurrencyStatus.failed:
        return CurrencyService.getLocalizedStatus(currency, l10n);
      case CurrencyStatus.timeout:
        return CurrencyService.getLocalizedStatus(currency, l10n);
      case CurrencyStatus.staticRate:
        return l10n.fetchingCurrency(currency);
      case CurrencyStatus.notSupported:
        return CurrencyService.getLocalizedStatus(currency, l10n);
      case CurrencyStatus.fetchedRecently:
        return CurrencyService.getLocalizedStatus(currency, l10n);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;

    return WillPopScope(
      // Prevent dialog from closing with back button when not completed
      onWillPop: () async => _isCompleted,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 60 : 16,
          vertical: isDesktop ? 40 : 40,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 500 : screenSize.width * 0.9,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade600,
                      Colors.blue.shade500,
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
                      Icons.sync,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.fetchingRates,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_isCompleted)
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                        tooltip: l10n.close,
                      ),
                  ],
                ),
              ),

              // Progress section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Circular progress with countdown
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 8,
                            backgroundColor:
                                theme.colorScheme.outline.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          // Progress circle
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return CircularProgressIndicator(
                                value: _isCompleted
                                    ? 1.0
                                    : (_progressAnimation.value),
                                strokeWidth: 8,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _isCompleted ? Colors.green : Colors.blue,
                                ),
                              );
                            },
                          ),
                          // Center text
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isCompleted) ...[
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 32,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.fetchComplete,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  '$_remainingSeconds',
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  l10n.timeRemaining(_remainingSeconds),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Progress text
                    Text(
                      l10n.fetchingProgress(
                          _completedCount, widget.currencies.length),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Currency status list
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.fetchingStatus,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: widget.currencies.length,
                          itemBuilder: (context, index) {
                            final currency = widget.currencies[index];
                            final status = _currencyStatuses[currency] ??
                                CurrencyStatus.staticRate;

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  // Currency code
                                  SizedBox(
                                    width: 50,
                                    child: Text(
                                      currency,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Status indicator
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Status text
                                  Expanded(
                                    child: Text(
                                      _getStatusText(l10n, currency, status),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Fetch time
                                  Text(
                                    _getFetchTime(currency),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontFamily: 'monospace',
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Status icon
                                  Icon(
                                    _getStatusIcon(status),
                                    size: 16,
                                    color: _getStatusColor(status),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

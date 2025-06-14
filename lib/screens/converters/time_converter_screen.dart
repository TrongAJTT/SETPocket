import 'package:flutter/material.dart';
import 'package:setpocket/controllers/time_converter_controller.dart';
import 'package:setpocket/widgets/converter_tools/generic_converter_view.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/app_logger.dart';

class TimeConverterScreen extends StatefulWidget {
  final bool isEmbedded;

  const TimeConverterScreen({super.key, this.isEmbedded = false});

  @override
  State<TimeConverterScreen> createState() => _TimeConverterScreenState();
}

class _TimeConverterScreenState extends State<TimeConverterScreen> {
  late TimeConverterController _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _controller = TimeConverterController();
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      logError('TimeConverterScreen: Error initializing controller: $e');

      // Check if this is the DateTime casting error
      if (e.toString().contains('DateTime') &&
          e.toString().contains('String')) {
        logInfo(
            'TimeConverterScreen: Detected DateTime casting error, clearing cache');
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
      // Force clear time converter cache
      await _controller.forceClearTimeCache();

      // Try to initialize again
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      }

      logInfo(
          'TimeConverterScreen: Successfully recovered from DateTime casting error');
    } catch (e) {
      logError(
          'TimeConverterScreen: Failed to recover from DateTime casting error: $e');
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
          title: l10n.timeConverter,
          titleIcon: Icons.access_time,
          onShowInfo: () {
            // Simple info dialog for now
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.timeConverter),
                content: Text(l10n.timeConverterOverview),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.close),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

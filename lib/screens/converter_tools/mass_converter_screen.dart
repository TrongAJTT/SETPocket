import 'package:flutter/material.dart';
import 'package:setpocket/controllers/mass_converter_controller.dart';
import 'package:setpocket/services/function_info_service.dart';
import 'package:setpocket/widgets/converter_tools/generic_converter_view.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/app_logger.dart';

class MassConverterNewScreen extends StatefulWidget {
  final bool isEmbedded;

  const MassConverterNewScreen({super.key, this.isEmbedded = false});

  @override
  State<MassConverterNewScreen> createState() => _MassConverterNewScreenState();
}

class _MassConverterNewScreenState extends State<MassConverterNewScreen> {
  late MassConverterController _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _controller = MassConverterController();
      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      logError('MassConverterNewScreen: Error initializing controller: $e');

      // Check if this is the DateTime casting error
      if (e.toString().contains('DateTime') &&
          e.toString().contains('String')) {
        logInfo(
            'MassConverterNewScreen: Detected DateTime casting error, clearing cache');
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
      // Force clear mass converter cache
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
          'MassConverterNewScreen: Successfully recovered from DateTime casting error');
    } catch (e) {
      logError(
          'MassConverterNewScreen: Failed to recover from DateTime casting error: $e');
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

  void _showMassInfo() {
    FunctionInfo.show(context, FunctionInfoKeys.massConverter);
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
          title: l10n.massConverter,
          titleIcon: Icons.monitor_weight,
          onShowInfo: _showMassInfo,
        );
      },
    );
  }
}

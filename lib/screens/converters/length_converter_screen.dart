import 'package:flutter/material.dart';
import '../../controllers/length_converter_controller.dart';
import '../../widgets/converter_tools/generic_converter_view.dart';
import '../../l10n/app_localizations.dart';

class LengthConverterNewScreen extends StatefulWidget {
  final bool isEmbedded;

  const LengthConverterNewScreen({super.key, this.isEmbedded = false});

  @override
  State<LengthConverterNewScreen> createState() =>
      _LengthConverterNewScreenState();
}

class _LengthConverterNewScreenState extends State<LengthConverterNewScreen> {
  late LengthConverterController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = LengthConverterController();
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

  void _showLengthInfo() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.straighten,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.lengthConverter),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Professional length converter with high precision calculations and multiple display formats.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Features',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildFeatureItem(
                  'High precision calculations with up to 10 decimal places',
                  Icons.precision_manufacturing),
              _buildFeatureItem('Card and table view modes', Icons.view_module),
              _buildFeatureItem(
                  'Save and load presets (coming soon)', Icons.bookmark),
              _buildFeatureItem(
                  'Scientific and engineering units', Icons.calculate),
              _buildFeatureItem(
                  'Real-time conversion across multiple units', Icons.science),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
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
          title: l10n.lengthConverter,
          titleIcon: Icons.straighten,
          onShowInfo: _showLengthInfo,
        );
      },
    );
  }
}

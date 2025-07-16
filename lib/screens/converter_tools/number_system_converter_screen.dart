import 'package:flutter/material.dart';
import 'package:setpocket/controllers/number_system_converter_controller.dart';
import 'package:setpocket/services/function_info_service.dart';
import 'package:setpocket/widgets/converter_tools/generic_converter_view.dart';
import 'package:setpocket/l10n/app_localizations.dart';

class NumberSystemConverterScreen extends StatefulWidget {
  final bool isEmbedded;

  const NumberSystemConverterScreen({super.key, this.isEmbedded = false});

  @override
  State<NumberSystemConverterScreen> createState() =>
      _NumberSystemConverterScreenState();
}

class _NumberSystemConverterScreenState
    extends State<NumberSystemConverterScreen> {
  late NumberSystemConverterController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = NumberSystemConverterController();
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

  void _showNumberSystemInfo() {
    FunctionInfo.show(context, FunctionInfoKeys.numberSystemConverter);
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
          title: l10n.numberSystemConverter,
          titleIcon: Icons.code,
          onShowInfo: _showNumberSystemInfo,
        );
      },
    );
  }
}

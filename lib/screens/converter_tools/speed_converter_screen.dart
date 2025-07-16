import 'package:flutter/material.dart';
import 'package:setpocket/controllers/speed_converter_controller.dart';
import 'package:setpocket/services/function_info_service.dart';
import 'package:setpocket/widgets/converter_tools/generic_converter_view.dart';
import 'package:setpocket/l10n/app_localizations.dart';

class SpeedConverterScreen extends StatefulWidget {
  final bool isEmbedded;

  const SpeedConverterScreen({super.key, this.isEmbedded = false});

  @override
  State<SpeedConverterScreen> createState() => _SpeedConverterScreenState();
}

class _SpeedConverterScreenState extends State<SpeedConverterScreen> {
  late SpeedConverterController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = SpeedConverterController();
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

  void _showSpeedInfo() {
    FunctionInfo.show(context, FunctionInfoKeys.speedConverter);
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
          title: l10n.speedConverter,
          titleIcon: Icons.speed,
          onShowInfo: _showSpeedInfo,
        );
      },
    );
  }
}

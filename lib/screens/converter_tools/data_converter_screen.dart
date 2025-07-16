import 'package:flutter/material.dart';
import 'package:setpocket/controllers/data_converter_controller.dart';
import 'package:setpocket/services/function_info_service.dart';
import 'package:setpocket/widgets/converter_tools/generic_converter_view.dart';
import 'package:setpocket/l10n/app_localizations.dart';

class DataConverterScreen extends StatefulWidget {
  final bool isEmbedded;

  const DataConverterScreen({super.key, this.isEmbedded = false});

  @override
  State<DataConverterScreen> createState() => _DataConverterScreenState();
}

class _DataConverterScreenState extends State<DataConverterScreen> {
  late DataConverterController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = DataConverterController();
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

  void _showDataInfo() {
    FunctionInfo.show(context, FunctionInfoKeys.dataConverter);
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
          title: l10n.dataConverter,
          titleIcon: Icons.storage,
          onShowInfo: _showDataInfo,
        );
      },
    );
  }
}

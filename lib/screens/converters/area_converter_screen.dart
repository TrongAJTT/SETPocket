import 'package:flutter/material.dart';
import '../../models/converter_models.dart';
import '../../widgets/converter_tools/converter_widget.dart';
import '../../l10n/app_localizations.dart';

class AreaConverterScreen extends StatelessWidget {
  final bool isEmbedded;

  const AreaConverterScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isEmbedded) {
      return ConverterWidget(
        converter: AreaConverter(),
        isEmbedded: true,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.areaConverter),
      ),
      body: ConverterWidget(
        converter: AreaConverter(),
        isEmbedded: false,
      ),
    );
  }
}

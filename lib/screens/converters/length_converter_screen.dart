import 'package:flutter/material.dart';
import '../../models/converter_models.dart';
import '../../widgets/converter_widget.dart';
import '../../l10n/app_localizations.dart';

class LengthConverterScreen extends StatelessWidget {
  final bool isEmbedded;

  const LengthConverterScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isEmbedded) {
      return ConverterWidget(
        converter: LengthConverter(),
        isEmbedded: true,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lengthConverter),
      ),
      body: ConverterWidget(
        converter: LengthConverter(),
        isEmbedded: false,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/converter_models.dart';
import '../../widgets/converter_tools/converter_widget.dart';
import '../../l10n/app_localizations.dart';

class TimeConverterScreen extends StatelessWidget {
  final bool isEmbedded;

  const TimeConverterScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isEmbedded) {
      return ConverterWidget(
        converter: TimeConverter(),
        isEmbedded: true,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.timeConverter),
      ),
      body: ConverterWidget(
        converter: TimeConverter(),
        isEmbedded: false,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/converter_models.dart';
import '../../widgets/converter_widget.dart';
import '../../l10n/app_localizations.dart';

class VolumeConverterScreen extends StatelessWidget {
  final bool isEmbedded;

  const VolumeConverterScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isEmbedded) {
      return ConverterWidget(
        converter: VolumeConverter(),
        isEmbedded: true,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.volumeConverter),
      ),
      body: ConverterWidget(
        converter: VolumeConverter(),
        isEmbedded: false,
      ),
    );
  }
}

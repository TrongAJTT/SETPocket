import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/variables.dart';

extension VersionTypeExtension on VersionType {
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case VersionType.release:
        return l10n.versionTypeReleaseDisplay;
      case VersionType.beta:
        return l10n.versionTypeBetaDisplay;
      case VersionType.dev:
        return l10n.versionTypeDevDisplay;
    }
  }

  String getShortName(AppLocalizations l10n) {
    switch (this) {
      case VersionType.release:
        return l10n.versionTypeRelease;
      case VersionType.beta:
        return l10n.versionTypeBeta;
      case VersionType.dev:
        return l10n.versionTypeDev;
    }
  }
}

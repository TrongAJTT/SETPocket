/// Currency fetch mode options
enum CurrencyFetchMode {
  manual,
  autoDaily,
}

extension CurrencyFetchModeExtension on CurrencyFetchMode {
  String get displayName {
    switch (this) {
      case CurrencyFetchMode.manual:
        return 'Manual Only';
      case CurrencyFetchMode.autoDaily:
        return 'Auto Everyday';
    }
  }

  String displayNameLocalized(dynamic loc) {
    // For now, return the English name - can be localized later
    return displayName;
  }

  String get description {
    switch (this) {
      case CurrencyFetchMode.manual:
        return 'Never fetch currency rates automatically';
      case CurrencyFetchMode.autoDaily:
        return 'Fetch currency rates once per day';
    }
  }

  Duration? get duration {
    switch (this) {
      case CurrencyFetchMode.manual:
        return null;
      case CurrencyFetchMode.autoDaily:
        return const Duration(days: 1);
    }
  }
}

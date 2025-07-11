/// Enum for different function types used throughout the application
enum FunctionType {
  /// P2Lan transfer related functions
  p2lanTransfer,

  /// Text template generation functions
  textTemplate,

  /// Random tools functions
  randomTools,

  /// Converter tools functions
  converterTools,

  /// Calculator tools functions
  calculatorTools,

  /// General application settings
  appSettings,

  /// Cache/Storage management
  storageManagement,

  /// User interface settings
  userInterface,

  /// Network settings
  networkSettings,

  /// Security settings
  securitySettings,

  /// Notification settings
  notificationSettings,

  /// File management settings
  fileManagement,
}

/// Extension to provide display names for function types
extension FunctionTypeExtension on FunctionType {
  String get displayName {
    switch (this) {
      case FunctionType.p2lanTransfer:
        return 'P2Lan Transfer Settings';
      case FunctionType.textTemplate:
        return 'Text Template Settings';
      case FunctionType.randomTools:
        return 'Random Tools Settings';
      case FunctionType.converterTools:
        return 'Converter Tools Settings';
      case FunctionType.calculatorTools:
        return 'Calculator Tools Settings';
      case FunctionType.appSettings:
        return 'Application Settings';
      case FunctionType.storageManagement:
        return 'Storage Management';
      case FunctionType.userInterface:
        return 'User Interface Settings';
      case FunctionType.networkSettings:
        return 'Network Settings';
      case FunctionType.securitySettings:
        return 'Security Settings';
      case FunctionType.notificationSettings:
        return 'Notification Settings';
      case FunctionType.fileManagement:
        return 'File Management Settings';
    }
  }

  String get identifier {
    switch (this) {
      case FunctionType.p2lanTransfer:
        return 'p2lan_transfer';
      case FunctionType.textTemplate:
        return 'text_template';
      case FunctionType.randomTools:
        return 'random_tools';
      case FunctionType.converterTools:
        return 'converter_tools';
      case FunctionType.calculatorTools:
        return 'calculator_tools';
      case FunctionType.appSettings:
        return 'app_settings';
      case FunctionType.storageManagement:
        return 'storage_management';
      case FunctionType.userInterface:
        return 'user_interface';
      case FunctionType.networkSettings:
        return 'network_settings';
      case FunctionType.securitySettings:
        return 'security_settings';
      case FunctionType.notificationSettings:
        return 'notification_settings';
      case FunctionType.fileManagement:
        return 'file_management';
    }
  }
}

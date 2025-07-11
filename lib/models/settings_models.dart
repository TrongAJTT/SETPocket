import 'dart:convert';
import 'package:isar/isar.dart';
import 'converter_models/currency_fetch_mode.dart';

part 'settings_models.g.dart';

/// Enum for different types of settings models
enum SettingsModelType {
  global, // Global app settings
  converterTools, // Converter-specific settings
  randomTools, // Random tools-specific settings
  calculatorTools, // Calculator-specific settings
  textTemplate, // Text template-specific settings
  p2pTransfer, // P2P transfer-specific settings
  userProfile, // User profile settings (future)
}

@Collection()
class ExtensibleSettings {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String modelCode; // Unique identifier for each settings type

  @Enumerated(EnumType.ordinal)
  SettingsModelType modelType;

  String settingsJson; // JSON string containing the actual settings data

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  ExtensibleSettings({
    required this.modelCode,
    required this.modelType,
    required this.settingsJson,
  });

  ExtensibleSettings copyWith({
    String? modelCode,
    SettingsModelType? modelType,
    String? settingsJson,
  }) {
    final result = ExtensibleSettings(
      modelCode: modelCode ?? this.modelCode,
      modelType: modelType ?? this.modelType,
      settingsJson: settingsJson ?? this.settingsJson,
    );
    result.id = id;
    result.updatedAt = DateTime.now();
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'modelCode': modelCode,
      'modelType': modelType.index,
      'settingsJson': settingsJson,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ExtensibleSettings.fromJson(Map<String, dynamic> json) {
    final result = ExtensibleSettings(
      modelCode: json['modelCode'] ?? '',
      modelType: SettingsModelType.values[json['modelType'] ?? 0],
      settingsJson: json['settingsJson'] ?? '{}',
    );
    result.id = json['id'] ?? Isar.autoIncrement;
    result.createdAt =
        DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();
    result.updatedAt =
        DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now();
    return result;
  }

  /// Parse the settings JSON and return as a Map
  Map<String, dynamic> getSettingsAsMap() {
    try {
      final decoded =
          Map<String, dynamic>.from(const JsonDecoder().convert(settingsJson));
      return decoded;
    } catch (e) {
      // Return empty map if JSON parsing fails
      return <String, dynamic>{};
    }
  }
}

/// Global app settings data structure
class GlobalSettingsData {
  final bool featureStateSavingEnabled;
  final int logRetentionDays;
  final bool focusModeEnabled;

  GlobalSettingsData({
    this.featureStateSavingEnabled = true,
    this.logRetentionDays = 5,
    this.focusModeEnabled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'featureStateSavingEnabled': featureStateSavingEnabled,
      'logRetentionDays': logRetentionDays,
      'focusModeEnabled': focusModeEnabled,
    };
  }

  factory GlobalSettingsData.fromJson(Map<String, dynamic> json) {
    return GlobalSettingsData(
      featureStateSavingEnabled: json['featureStateSavingEnabled'] ?? true,
      logRetentionDays: json['logRetentionDays'] ?? 5,
      focusModeEnabled: json['focusModeEnabled'] ?? false,
    );
  }

  GlobalSettingsData copyWith({
    bool? featureStateSavingEnabled,
    int? logRetentionDays,
    bool? focusModeEnabled,
  }) {
    return GlobalSettingsData(
      featureStateSavingEnabled:
          featureStateSavingEnabled ?? this.featureStateSavingEnabled,
      logRetentionDays: logRetentionDays ?? this.logRetentionDays,
      focusModeEnabled: focusModeEnabled ?? this.focusModeEnabled,
    );
  }
}

/// Converter tools settings data structure
class ConverterToolsSettingsData {
  final CurrencyFetchMode currencyFetchMode;
  final int fetchTimeoutSeconds;
  final int fetchRetryTimes;
  final bool saveConverterToolsState;

  ConverterToolsSettingsData({
    this.currencyFetchMode = CurrencyFetchMode.autoDaily,
    this.fetchTimeoutSeconds = 10,
    this.fetchRetryTimes = 1,
    this.saveConverterToolsState = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'currencyFetchMode': currencyFetchMode.index,
      'fetchTimeoutSeconds': fetchTimeoutSeconds,
      'fetchRetryTimes': fetchRetryTimes,
      'saveConverterToolsState': saveConverterToolsState,
    };
  }

  factory ConverterToolsSettingsData.fromJson(Map<String, dynamic> json) {
    return ConverterToolsSettingsData(
      currencyFetchMode:
          CurrencyFetchMode.values[json['currencyFetchMode'] ?? 1],
      fetchTimeoutSeconds: json['fetchTimeoutSeconds'] ?? 10,
      fetchRetryTimes: json['fetchRetryTimes'] ?? 1,
      saveConverterToolsState: json['saveConverterToolsState'] ?? true,
    );
  }

  ConverterToolsSettingsData copyWith({
    CurrencyFetchMode? currencyFetchMode,
    int? fetchTimeoutSeconds,
    int? fetchRetryTimes,
    bool? saveConverterToolsState,
  }) {
    return ConverterToolsSettingsData(
      currencyFetchMode: currencyFetchMode ?? this.currencyFetchMode,
      fetchTimeoutSeconds: fetchTimeoutSeconds ?? this.fetchTimeoutSeconds,
      fetchRetryTimes: fetchRetryTimes ?? this.fetchRetryTimes,
      saveConverterToolsState:
          saveConverterToolsState ?? this.saveConverterToolsState,
    );
  }
}

/// Random tools settings data structure
class RandomToolsSettingsData {
  final bool saveRandomToolsState;
  final bool saveGenerationHistory;

  RandomToolsSettingsData({
    this.saveRandomToolsState = true,
    this.saveGenerationHistory = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'saveRandomToolsState': saveRandomToolsState,
      'saveGenerationHistory': saveGenerationHistory,
    };
  }

  factory RandomToolsSettingsData.fromJson(Map<String, dynamic> json) {
    return RandomToolsSettingsData(
      saveRandomToolsState: json['saveRandomToolsState'] ?? true,
      saveGenerationHistory: json['saveGenerationHistory'] ?? true,
    );
  }

  RandomToolsSettingsData copyWith({
    bool? saveRandomToolsState,
    bool? saveGenerationHistory,
  }) {
    return RandomToolsSettingsData(
      saveRandomToolsState: saveRandomToolsState ?? this.saveRandomToolsState,
      saveGenerationHistory:
          saveGenerationHistory ?? this.saveGenerationHistory,
    );
  }
}

/// Calculator tools settings data structure
class CalculatorToolsSettingsData {
  final bool rememberHistory;
  final bool saveFeatureState;
  final bool? bookmarkFunctionsBeforeLoading;

  CalculatorToolsSettingsData({
    this.rememberHistory = true,
    this.saveFeatureState = true,
    this.bookmarkFunctionsBeforeLoading,
  });

  Map<String, dynamic> toJson() {
    return {
      'rememberHistory': rememberHistory,
      'saveFeatureState': saveFeatureState,
      'bookmarkFunctionsBeforeLoading': bookmarkFunctionsBeforeLoading,
    };
  }

  factory CalculatorToolsSettingsData.fromJson(Map<String, dynamic> json) {
    return CalculatorToolsSettingsData(
      rememberHistory: json['rememberHistory'] ?? true,
      saveFeatureState: json['saveFeatureState'] ?? true,
      bookmarkFunctionsBeforeLoading: json['bookmarkFunctionsBeforeLoading'],
    );
  }

  CalculatorToolsSettingsData copyWith({
    bool? rememberHistory,
    bool? saveFeatureState,
    bool? bookmarkFunctionsBeforeLoading,
  }) {
    return CalculatorToolsSettingsData(
      rememberHistory: rememberHistory ?? this.rememberHistory,
      saveFeatureState: saveFeatureState ?? this.saveFeatureState,
      bookmarkFunctionsBeforeLoading:
          bookmarkFunctionsBeforeLoading ?? this.bookmarkFunctionsBeforeLoading,
    );
  }

  // Helper getter for backwards compatibility and UI logic
  bool get askBeforeLoadingHistory => bookmarkFunctionsBeforeLoading == null;
}

/// P2P transfer settings data structure (replaces P2PDataTransferSettings and P2PFileStorageSettings)
class P2PTransferSettingsData {
  final String downloadPath;
  final bool createDateFolders;
  final bool createSenderFolders;
  final int maxReceiveFileSize; // In bytes
  final int maxTotalReceiveSize; // In bytes
  final int maxConcurrentTasks;
  final String sendProtocol; // e.g., 'TCP', 'UDP'
  final int maxChunkSize; // In kilobytes
  final String? customDisplayName;
  final int uiRefreshRateSeconds;
  final bool enableNotifications;
  final bool askBeforeDownload;
  final bool rememberBatchExpandState;

  P2PTransferSettingsData({
    this.downloadPath = '',
    this.createDateFolders = false,
    this.createSenderFolders = true,
    this.maxReceiveFileSize = 1073741824, // 1GB in bytes
    this.maxTotalReceiveSize = 5368709120, // 5GB in bytes
    this.maxConcurrentTasks = 3,
    this.sendProtocol = 'TCP',
    this.maxChunkSize = 1024, // 1MB in KB
    this.customDisplayName,
    this.uiRefreshRateSeconds = 0,
    this.enableNotifications = true,
    this.askBeforeDownload = true,
    this.rememberBatchExpandState = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'downloadPath': downloadPath,
      'createDateFolders': createDateFolders,
      'createSenderFolders': createSenderFolders,
      'maxReceiveFileSize': maxReceiveFileSize,
      'maxTotalReceiveSize': maxTotalReceiveSize,
      'maxConcurrentTasks': maxConcurrentTasks,
      'sendProtocol': sendProtocol,
      'maxChunkSize': maxChunkSize,
      'customDisplayName': customDisplayName,
      'uiRefreshRateSeconds': uiRefreshRateSeconds,
      'enableNotifications': enableNotifications,
      'askBeforeDownload': askBeforeDownload,
      'rememberBatchExpandState': rememberBatchExpandState,
    };
  }

  factory P2PTransferSettingsData.fromJson(Map<String, dynamic> json) {
    return P2PTransferSettingsData(
      downloadPath: json['downloadPath'] ?? '',
      createDateFolders: json['createDateFolders'] ?? false,
      createSenderFolders: json['createSenderFolders'] ?? true,
      maxReceiveFileSize: json['maxReceiveFileSize'] ?? 1073741824,
      maxTotalReceiveSize: json['maxTotalReceiveSize'] ?? 5368709120,
      maxConcurrentTasks: json['maxConcurrentTasks'] ?? 3,
      sendProtocol: json['sendProtocol'] ?? 'TCP',
      maxChunkSize: json['maxChunkSize'] ?? 1024,
      customDisplayName: json['customDisplayName'],
      uiRefreshRateSeconds: json['uiRefreshRateSeconds'] ?? 0,
      enableNotifications: json['enableNotifications'] ?? true,
      askBeforeDownload: json['askBeforeDownload'] ?? true,
      rememberBatchExpandState: json['rememberBatchExpandState'] ?? false,
    );
  }

  P2PTransferSettingsData copyWith({
    String? downloadPath,
    bool? createDateFolders,
    bool? createSenderFolders,
    int? maxReceiveFileSize,
    int? maxTotalReceiveSize,
    int? maxConcurrentTasks,
    String? sendProtocol,
    int? maxChunkSize,
    String? customDisplayName,
    int? uiRefreshRateSeconds,
    bool? enableNotifications,
    bool? askBeforeDownload,
    bool? rememberBatchExpandState,
  }) {
    return P2PTransferSettingsData(
      downloadPath: downloadPath ?? this.downloadPath,
      createDateFolders: createDateFolders ?? this.createDateFolders,
      createSenderFolders: createSenderFolders ?? this.createSenderFolders,
      maxReceiveFileSize: maxReceiveFileSize ?? this.maxReceiveFileSize,
      maxTotalReceiveSize: maxTotalReceiveSize ?? this.maxTotalReceiveSize,
      maxConcurrentTasks: maxConcurrentTasks ?? this.maxConcurrentTasks,
      sendProtocol: sendProtocol ?? this.sendProtocol,
      maxChunkSize: maxChunkSize ?? this.maxChunkSize,
      customDisplayName: customDisplayName ?? this.customDisplayName,
      uiRefreshRateSeconds: uiRefreshRateSeconds ?? this.uiRefreshRateSeconds,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      askBeforeDownload: askBeforeDownload ?? this.askBeforeDownload,
      rememberBatchExpandState:
          rememberBatchExpandState ?? this.rememberBatchExpandState,
    );
  }
}

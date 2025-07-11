# Settings Model Refactoring Proposal

## Overview
Refactor from single `SettingsModel` to multiple `SettingsModels` with ID/model_code for better extensibility and organization.

## Current Issues
1. **Monolithic Design**: All settings in one model (global + tool-specific)
2. **Fixed ID**: Uses hardcoded ID=1 for singleton pattern
3. **Hard to Extend**: Adding tool-specific settings makes the model grow
4. **Migration Complexity**: Schema changes affect all settings at once

## Proposed New Structure

### 1. Settings Model Types
```dart
enum SettingsModelType {
  global,           // Global app settings
  converterTools,   // Converter-specific settings
  randomTools,      // Random tools-specific settings
  calculatorTools,  // Calculator-specific settings
  textTemplate,     // Text template-specific settings
  p2pTransfer,      // P2P transfer-specific settings
  userProfile,      // User profile settings (future)
}
```

### 2. New SettingsModels Schema
```dart
@Collection()
class SettingsModels {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  String modelCode; // e.g., "global", "converter_tools", "random_tools"
  
  @Enumerated(EnumType.ordinal)
  SettingsModelType type;
  
  // JSON storage for flexibility
  String settingsData; // JSON-encoded settings specific to each type
  
  DateTime createdAt;
  DateTime updatedAt;
  
  int version; // For future schema migrations
}
```

### 3. Specific Settings Models

#### Global Settings
```dart
class GlobalSettings {
  bool featureStateSavingEnabled;
  int logRetentionDays;
  bool focusModeEnabled;
  
  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() => {
    'featureStateSavingEnabled': featureStateSavingEnabled,
    'logRetentionDays': logRetentionDays,
    'focusModeEnabled': focusModeEnabled,
  };
  
  factory GlobalSettings.fromJson(Map<String, dynamic> json) => GlobalSettings(
    featureStateSavingEnabled: json['featureStateSavingEnabled'] ?? true,
    logRetentionDays: json['logRetentionDays'] ?? 5,
    focusModeEnabled: json['focusModeEnabled'] ?? false,
  );
}
```

#### Converter Tools Settings
```dart
class ConverterToolsSettings {
  CurrencyFetchMode currencyFetchMode;
  int fetchTimeoutSeconds;
  int fetchRetryTimes;
  bool saveConverterToolsState;
  
  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() => {
    'currencyFetchMode': currencyFetchMode.index,
    'fetchTimeoutSeconds': fetchTimeoutSeconds,
    'fetchRetryTimes': fetchRetryTimes,
    'saveConverterToolsState': saveConverterToolsState,
  };
  
  factory ConverterToolsSettings.fromJson(Map<String, dynamic> json) => ConverterToolsSettings(
    currencyFetchMode: CurrencyFetchMode.values[json['currencyFetchMode'] ?? 1],
    fetchTimeoutSeconds: json['fetchTimeoutSeconds'] ?? 10,
    fetchRetryTimes: json['fetchRetryTimes'] ?? 1,
    saveConverterToolsState: json['saveConverterToolsState'] ?? true,
  );
}
```

#### Random Tools Settings
```dart
class RandomToolsSettings {
  bool saveRandomToolsState;
  bool historyEnabled;
  int maxHistoryItems;
  
  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() => {
    'saveRandomToolsState': saveRandomToolsState,
    'historyEnabled': historyEnabled,
    'maxHistoryItems': maxHistoryItems,
  };
  
  factory RandomToolsSettings.fromJson(Map<String, dynamic> json) => RandomToolsSettings(
    saveRandomToolsState: json['saveRandomToolsState'] ?? true,
    historyEnabled: json['historyEnabled'] ?? true,
    maxHistoryItems: json['maxHistoryItems'] ?? 100,
  );
}
```

### 4. New Settings Service

```dart
class SettingsService {
  // Generic method to get any settings type
  static Future<T> getSettings<T>(
    SettingsModelType type, 
    T Function(Map<String, dynamic>) fromJson,
    T Function() defaultFactory,
  ) async {
    final isar = IsarService.isar;
    final modelCode = _getModelCode(type);
    
    final settingsModel = await isar.settingsModels
        .filter()
        .modelCodeEqualTo(modelCode)
        .findFirst();
    
    if (settingsModel == null) {
      final defaultSettings = defaultFactory();
      await saveSettings(type, defaultSettings);
      return defaultSettings;
    }
    
    final json = jsonDecode(settingsModel.settingsData);
    return fromJson(json);
  }
  
  // Generic method to save any settings type
  static Future<void> saveSettings<T>(
    SettingsModelType type,
    T settings, {
    Map<String, dynamic> Function(T)? toJson,
  }) async {
    final isar = IsarService.isar;
    final modelCode = _getModelCode(type);
    
    await isar.writeTxn(() async {
      final existing = await isar.settingsModels
          .filter()
          .modelCodeEqualTo(modelCode)
          .findFirst();
      
      final settingsData = toJson?.call(settings) ?? 
          (settings as dynamic).toJson();
      
      if (existing != null) {
        existing.settingsData = jsonEncode(settingsData);
        existing.updatedAt = DateTime.now();
        await isar.settingsModels.put(existing);
      } else {
        final newModel = SettingsModels()
          ..modelCode = modelCode
          ..type = type
          ..settingsData = jsonEncode(settingsData)
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..version = 1;
        await isar.settingsModels.put(newModel);
      }
    });
  }
  
  // Convenience methods for each settings type
  static Future<GlobalSettings> getGlobalSettings() async {
    return getSettings(
      SettingsModelType.global,
      GlobalSettings.fromJson,
      () => GlobalSettings(),
    );
  }
  
  static Future<ConverterToolsSettings> getConverterToolsSettings() async {
    return getSettings(
      SettingsModelType.converterTools,
      ConverterToolsSettings.fromJson,
      () => ConverterToolsSettings(),
    );
  }
  
  static Future<RandomToolsSettings> getRandomToolsSettings() async {
    return getSettings(
      SettingsModelType.randomTools,
      RandomToolsSettings.fromJson,
      () => RandomToolsSettings(),
    );
  }
  
  // Helper method
  static String _getModelCode(SettingsModelType type) {
    switch (type) {
      case SettingsModelType.global:
        return 'global';
      case SettingsModelType.converterTools:
        return 'converter_tools';
      case SettingsModelType.randomTools:
        return 'random_tools';
      case SettingsModelType.calculatorTools:
        return 'calculator_tools';
      case SettingsModelType.textTemplate:
        return 'text_template';
      case SettingsModelType.p2pTransfer:
        return 'p2p_transfer';
      case SettingsModelType.userProfile:
        return 'user_profile';
    }
  }
}
```

## Migration Strategy

### Phase 1: Create New Models (Non-breaking)
1. Create new `SettingsModels` collection alongside existing `SettingsModel`
2. Create specific settings classes (GlobalSettings, ConverterToolsSettings, etc.)
3. Update SettingsService to support both old and new models

### Phase 2: Migrate Data
1. Create migration utility to copy data from old SettingsModel to new SettingsModels
2. Test migration thoroughly
3. Update all settings layouts to use new service methods

### Phase 3: Remove Old Model
1. Remove old SettingsModel and related code
2. Clean up Isar schema
3. Update documentation

## Benefits

### 1. **Better Organization**
- Tool-specific settings are separated
- Easier to add new tool settings without affecting others
- Clear ownership of settings

### 2. **Extensibility**
- Easy to add new settings types (user profiles, themes, etc.)
- JSON storage allows flexible schema evolution
- Version field supports migrations

### 3. **Performance**
- Only load settings needed for specific tools
- Smaller data transfers for specific settings
- Better caching possibilities

### 4. **Maintainability**
- Changes to one tool's settings don't affect others
- Easier testing of specific settings
- Clear separation of concerns

### 5. **Future Features**
- Multiple user profiles
- Tool-specific themes
- Export/import of specific settings
- Tool-specific backup/restore

## Implementation Priority

### High Priority (Should implement)
1. Separate converter tools settings (fetchTimeout, retryTimes, etc.)
2. Separate random tools settings (saveState, history, etc.)
3. Keep global settings separate (focus mode, logging, etc.)

### Medium Priority (Nice to have)
1. Calculator tools settings
2. Text template settings
3. P2P transfer settings

### Low Priority (Future)
1. User profile settings
2. Theme-specific settings
3. Tool-specific UI preferences

## Conclusion
This refactoring would significantly improve the settings architecture while maintaining backward compatibility during migration. The modular approach makes it easier to add new features and maintain existing ones.

# ExtensibleSettings Architecture - Internal Beta v0.5.0

## 🎯 Overview
Clean, extensible settings architecture implemented for SetPocket internal beta v0.5.0. No legacy migration needed.

## 📁 Architecture

### Core Components

#### 1. **ExtensibleSettings** (`lib/models/settings_models.dart`)
```dart
@Collection()
class ExtensibleSettings {
  Id id = Isar.autoIncrement;
  @Index(unique: true) String modelCode;  // e.g., 'global_settings'
  @Enumerated(EnumType.ordinal) SettingsModelType modelType;
  String settingsJson;  // JSON string containing actual settings
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
```

#### 2. **Settings Data Classes**
- `GlobalSettingsData`: Feature flags, log retention, focus mode
- `ConverterToolsSettingsData`: Currency fetch settings, timeouts, state saving
- `RandomToolsSettingsData`: Random tools state saving preferences

#### 3. **ExtensibleSettingsService** (`lib/services/settings_models_service.dart`)
- Type-safe CRUD operations
- Default settings creation
- JSON serialization/deserialization
- Clean API without migration complexity

## 🚀 Usage Examples

### Getting Settings
```dart
// Get typed settings
final globalSettings = await ExtensibleSettingsService.getGlobalSettings();
final converterSettings = await ExtensibleSettingsService.getConverterToolsSettings();
final randomSettings = await ExtensibleSettingsService.getRandomToolsSettings();
```

### Updating Settings
```dart
// Update with copyWith pattern
final newGlobalSettings = globalSettings.copyWith(
  logRetentionDays: 10,
  focusModeEnabled: true,
);
await ExtensibleSettingsService.updateGlobalSettings(newGlobalSettings);
```

### Adding New Settings Types
1. Add new enum to `SettingsModelType`
2. Create new data class (e.g., `CalculatorSettingsData`)
3. Add constants and methods to `ExtensibleSettingsService`

## 🎨 Benefits

- **✅ Type Safety**: Strong typing for all settings
- **✅ Extensible**: Easy to add new settings categories
- **✅ Clean**: No legacy migration code
- **✅ Testable**: Comprehensive test coverage
- **✅ Maintainable**: Clear separation of concerns

## 📱 Integration Points

- **main.dart**: `ExtensibleSettingsService.initialize()`
- **app_logger.dart**: Uses global settings for log retention
- **unified_random_state_service.dart**: Uses random tools settings
- **Cache Dialog**: Debug features for storage management

## 🔧 Debug Features

- **Delete Storage & Exit**: Complete data reset (debug mode only)
- **Settings Inspector**: Via Isar Inspector in debug mode
- **Test Coverage**: Unit & integration tests

## 📊 Database Schema

```
ExtensibleSettings Collection:
├── id (auto-increment)
├── modelCode (unique index) 
├── modelType (enum)
├── settingsJson (JSON string)
├── createdAt (timestamp)
└── updatedAt (timestamp)
```

## 🎯 Future Enhancements

- Add calculator-specific settings
- Text template preferences
- User profile settings
- Export/import functionality

---
**Internal Beta v0.5.0** - Clean architecture without legacy baggage

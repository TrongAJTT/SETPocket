# Sync Preset Button Implementation

## Overview
Added a "Sync Preset" button to the Generic Unit Custom Dialog for component cards in Converter Tools. This allows component cards to sync their unit selection with global presets.

## Implementation Details

### 1. Added `displaySyncButton` Parameter
- Added a new boolean parameter `displaySyncButton` to `EnhancedGenericUnitCustomizationDialog`
- Defaults to `false` for main dialogs
- Set to `true` for component cards/tables

### 2. Created `_syncWithGlobalPreset` Method
- Fetches available presets for the current converter type using `GenericPresetService.getAllPresets()`
- Uses the first available preset as the sync source
- Updates the temporary visible units with preset units
- Uses SnackbarUtils for consistent feedback messages (success, warning, error)

### 3. Updated Dialog UI
- Added conditional sync button in the actions row when `displaySyncButton` is true
- Button appears between Save and Load preset buttons in the top toolbar
- Uses sync icon and consistent styling with other preset buttons
- Maintains responsive layout

### 4. Applied to All Component Dialogs
- **converter_card_widget.dart**: ✅ `displaySyncButton: true` for card components
- **converter_table_widget.dart**: ✅ `displaySyncButton: true` for table components  
- **generic_converter_view.dart**: ✅ No parameter (defaults to false) for main dialog

### 5. Standardized SnackBar Usage
- Migrated all manual SnackBar implementations to SnackbarUtils
- Uses consistent typed messages: success, warning, error
- Provides better visual feedback with icons and consistent styling

## Usage Patterns

### For Component Cards/Tables:
```dart
EnhancedGenericUnitCustomizationDialog(
  title: AppLocalizations.of(context)!.customizeUnits,
  availableUnits: availableUnits,
  visibleUnits: validVisibleUnits,
  onChanged: (newUnits) {
    controller.updateCardUnits(cardIndex, newUnits);
  },
  maxSelection: 10,
  minSelection: 2,
  presetType: controller.converterService.converterType,
  showPresetOptions: true,
  displaySyncButton: true, // Show sync button for components
  globalVisibleUnits: controller.state.globalVisibleUnits, // Pass global units for sync
)
```

### For Main Dialog:
```dart
EnhancedGenericUnitCustomizationDialog(
  title: 'Customize Units',
  availableUnits: availableUnits,
  visibleUnits: controller.state.globalVisibleUnits,
  onChanged: controller.updateGlobalVisibleUnits,
  maxSelection: 10,
  minSelection: 2,
  presetType: controller.converterService.converterType,
  // displaySyncButton defaults to false
)
```

## Button Layout
- **Without Sync Button**: `[Cancel] [Apply Changes]`
- **With Sync Button**: `[Cancel] [Sync Preset] [Apply Changes]`

## Sync Logic
1. For component cards/tables, syncs with the global visible units from the main function settings
2. Uses the `globalVisibleUnits` parameter passed from the controller
3. Updates the dialog's temporary unit selection to match global settings
4. Shows success message when sync is completed
5. Shows warning if no global settings are available
6. On error, shows red error message

## Updated Constructor Parameters
- Added `globalVisibleUnits: Set<String>?` parameter
- Only needed when `displaySyncButton: true`
- Contains the global visible units from the main function to sync with

## Benefits
- Provides quick way to sync component cards with global settings
- Distinguishes between main dialog (global settings) and component dialogs
- Maintains consistent UX patterns across all converter tools
- Preserves existing functionality while adding new feature

## Testing
- All component cards now show the sync button when editing units
- Main unit customization dialogs do not show the sync button
- Sync functionality works with existing preset system
- No breaking changes to existing code

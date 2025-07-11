# Generic Settings System

Hệ thống generic settings được thiết kế để cung cấp một cách thống nhất để hiển thị và quản lý các settings trong ứng dụng.

## Cấu trúc

### 1. FunctionType Enum (`utils/function_type_utils.dart`)
Định nghĩa các loại function khác nhau trong ứng dụng:
- `p2lanTransfer`: P2Lan transfer settings
- `textTemplate`: Text template settings
- `randomTools`: Random tools settings
- `converterTools`: Converter tools settings
- `calculatorTools`: Calculator tools settings
- `appSettings`: Application settings
- `storageManagement`: Storage management
- `userInterface`: User interface settings
- `networkSettings`: Network settings
- `securitySettings`: Security settings
- `notificationSettings`: Notification settings
- `fileManagement`: File management settings

### 2. GenericSettingsHelper (`widgets/generic/generic_settings_helper.dart`)
Core helper class cung cấp các phương thức chung để hiển thị settings:
- `showSettings()`: Hiển thị settings (tự động chọn dialog hoặc screen)
- `showQuickSettings()`: Hiển thị quick settings dialog
- `showBottomSheetSettings()`: Hiển thị settings dưới dạng bottom sheet

### 3. GenericSettingsUtils (`utils/generic_settings_utils.dart`)
Factory class cung cấp các phương thức factory để navigate đến settings:
- `navigateSettings()`: Factory method chính
- `navigateQuickSettings()`: Factory method cho quick settings
- `navigateBottomSheetSettings()`: Factory method cho bottom sheet

### 4. GenericSettingsConfig
Configuration class chứa tất cả thông tin cần thiết cho settings:
- `title`: Tiêu đề
- `settingsLayout`: Widget layout
- `currentSettings`: Settings hiện tại
- `onSettingsChanged`: Callback khi settings thay đổi
- `onCancel`: Callback khi cancel
- `showActions`: Hiển thị action buttons
- `isCompact`: Sử dụng layout compact
- `preferredSize`: Kích thước ưa thích (cho dialog)
- `barrierDismissible`: Có thể dismiss dialog

## Cách sử dụng

### 1. Sử dụng Factory method trực tiếp (Recommended)
```dart
// Ví dụ với P2Lan Transfer Settings
GenericSettingsUtils.navigateSettings(
  context,
  FunctionType.p2lanTransfer,
  currentSettings: mySettings,
  onSettingsChanged: (dynamic settings) {
    final p2pSettings = settings as P2PDataTransferSettings;
    // Handle settings change
  },
  showActions: true,
  isCompact: false,
  barrierDismissible: false,
);
```

### 2. Quick Settings
```dart
GenericSettingsUtils.navigateQuickSettings(
  context,
  FunctionType.p2lanTransfer,
  currentSettings: mySettings,
  onSettingsChanged: (dynamic settings) {
    final p2pSettings = settings as P2PDataTransferSettings;
    // Handle quick settings change
  },
  quickSize: const Size(600, 500),
  barrierDismissible: true,
);
```

### 3. Bottom Sheet Settings
```dart
GenericSettingsUtils.navigateBottomSheetSettings(
  context,
  FunctionType.p2lanTransfer,
  currentSettings: mySettings,
  onSettingsChanged: (dynamic settings) {
    final p2pSettings = settings as P2PDataTransferSettings;
    // Handle settings change
  },
  height: 600,
  isDismissible: true,
  enableDrag: true,
);
```

## Responsive Design

Hệ thống tự động chọn UI phù hợp:
- **Desktop (width > 800px)**: Sử dụng Dialog
- **Mobile/Tablet (width <= 800px)**: Sử dụng full screen

## Thêm Function Type mới

1. Thêm enum value vào `FunctionType` trong `function_type_utils.dart`
2. Cập nhật `displayName` và `identifier` extensions
3. Thêm case mới trong `_createSettingsConfig()` của `GenericSettingsUtils`
4. Tạo method `_createXxxConfig()` cho function type mới
5. (Optional) Tạo helper class wrapper nếu cần thiết cho API đơn giản hóa

## Ví dụ

Xem file `examples/settings_usage_example.dart` để có ví dụ chi tiết về cách sử dụng.

## Lợi ích

1. **Thống nhất**: Tất cả settings đều có cùng behavior
2. **Responsive**: Tự động chọn UI phù hợp với screen size
3. **Flexible**: Hỗ trợ nhiều kiểu hiển thị (dialog, screen, bottom sheet)
4. **Maintainable**: Dễ thêm function type mới
5. **Type-safe**: Sử dụng generics để đảm bảo type safety
6. **Reusable**: Code có thể tái sử dụng cho nhiều loại settings khác nhau

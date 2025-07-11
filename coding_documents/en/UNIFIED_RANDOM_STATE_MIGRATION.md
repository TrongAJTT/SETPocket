# Unified Random State System

## Tổng quan

Hệ thống quản lý trạng thái Random Tools đã được tối ưu hóa từ việc sử dụng nhiều collection riêng biệt sang một collection thống nhất `UnifiedRandomState`. Điều này giúp giảm thiểu việc tạo ra nhiều bản ghi trùng lặp và cải thiện hiệu suất.

## Kiến trúc mới

### UnifiedRandomState Model

```dart
@Collection()
class UnifiedRandomState {
  String toolId = '';         // ID công cụ (vd: "password", "number", "date")
  String stateData = '{}';    // Dữ liệu JSON của trạng thái
  DateTime lastUpdated;       // Thời gian cập nhật cuối
  int version = 1;           // Phiên bản cho tương thích migration
  Id id = Isar.autoIncrement; // ID tự động của Isar
}
```

### Tool IDs

```dart
class RandomToolIds {
  static const String password = 'password';
  static const String number = 'number';
  static const String latinLetter = 'latin_letter';
  static const String diceRoll = 'dice_roll';
  static const String playingCard = 'playing_card';
  static const String color = 'color';
  static const String date = 'date';
  static const String time = 'time';
  static const String dateTime = 'date_time';
  static const String uuid = 'uuid';
  static const String coinFlip = 'coin_flip';
  static const String yesNo = 'yes_no';
  static const String rockPaperScissors = 'rock_paper_scissors';
}
```

## Ưu điểm của hệ thống mới

### 1. Tối ưu hóa lưu trữ
- **Trước**: Mỗi lần lưu tạo một bản ghi mới với ID tự động tăng
- **Sau**: Chỉ có một bản ghi duy nhất cho mỗi công cụ, được cập nhật đè lên

### 2. Hiệu suất tốt hơn
- Giảm số lượng bản ghi trong database
- Truy vấn nhanh hơn với toolId làm key
- Không có dữ liệu trùng lặp

### 3. Dễ quản lý
- Một collection duy nhất cho tất cả Random Tools
- Dễ theo dõi và debug
- Cấu trúc rõ ràng với toolId

## Cách sử dụng

### Lưu trạng thái

```dart
// Tạo state object
final passwordState = PasswordGeneratorState.createDefault()
  ..passwordLength = 16
  ..includeUppercase = true;

// Lưu trạng thái
await UnifiedRandomStateService.savePasswordGeneratorState(passwordState);
```

### Tải trạng thái

```dart
// Tải trạng thái (tự động tạo default nếu không có)
final passwordState = await UnifiedRandomStateService.getPasswordGeneratorState();
```

### Xóa trạng thái

```dart
// Xóa một công cụ cụ thể
await UnifiedRandomStateService.clearStateByToolId(RandomToolIds.password);

// Xóa tất cả
await UnifiedRandomStateService.clearAllStates();
```

## Migration System

### Tự động migration
Hệ thống có khả năng tự động migrate từ `RandomStateService` cũ sang `UnifiedRandomStateService` mới:

```dart
// Kiểm tra cần migration không
final needsMigration = await RandomStateMigration.isMigrationNeeded();

// Thực hiện migration hoàn chỉnh
final success = await RandomStateMigration.performCompleteWorkflow();
```

### Quy trình migration
1. **Kiểm tra**: Service cũ có dữ liệu và service mới chưa có
2. **Migration**: Chuyển đổi tất cả trạng thái từ cũ sang mới
3. **Cleanup**: Xóa dữ liệu cũ sau khi migration thành công

## Kiểm tra và Debug

### Thông tin trạng thái
```dart
// Số lượng trạng thái đã lưu
final count = await UnifiedRandomStateService.getStateCount();

// Danh sách tool IDs đã có dữ liệu
final toolIds = await UnifiedRandomStateService.getSavedToolIds();

// Thông tin chi tiết cho debug
final info = await UnifiedRandomStateService.getStateInfo();
```

### Demo Screen
Sử dụng `UnifiedRandomStateDemo` screen để test và verify hoạt động của hệ thống mới.

## So sánh với hệ thống cũ

| Aspect | Old System | New System |
|--------|-----------|------------|
| Collections | 11 collections riêng biệt | 1 collection thống nhất |
| Records per tool | Nhiều bản ghi (ID auto-increment) | 1 bản ghi duy nhất |
| Storage efficiency | Thấp (nhiều duplicate) | Cao (no duplicate) |
| Query complexity | Đơn giản nhưng không tối ưu | Đơn giản và tối ưu |
| Maintenance | Khó (nhiều collection) | Dễ (1 collection) |

## Files liên quan

- `lib/models/random_models/unified_random_state.dart` - Model mới
- `lib/services/random_services/unified_random_state_service.dart` - Service mới
- `lib/services/random_services/random_state_migration.dart` - Migration utility
- `lib/screens/demos/unified_random_state_demo.dart` - Demo screen
- `lib/services/random_services/random_state_service.dart` - Service cũ (deprecated)

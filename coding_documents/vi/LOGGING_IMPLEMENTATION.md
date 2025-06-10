# Triển Khai Hệ Thống Logging - Multi Tools Flutter App

## Tổng Quan
Ứng dụng triển khai hệ thống logging toàn diện với lưu trữ dựa trên file, tự động dọn dẹp và tối ưu hóa hiệu năng. Hệ thống logging bao gồm nhiều lớp cung cấp khả năng logging có cấu trúc với tích hợp quản lý cache và settings.

**Cập nhật mới nhất**: Đã cải thiện logic xóa log với tự động tạo lại file để tránh xung đột và tích hợp với settings service.

## Kiến Trúc

### Các Thành Phần Cốt Lõi

#### 1. FileLoggerService (Backend)
Dịch vụ file logging hiệu năng cao với buffering và tự động xoay vòng file.

**Vị trí**: `lib/services/file_logger_service.dart`

**Tính năng chính**:
- Ghi buffer để tối ưu I/O
- Tự động xoay vòng file hàng ngày
- Xoay vòng dựa trên kích thước file (giới hạn 5MB)
- Bộ lập lịch dọn dẹp hàng ngày
- Quản lý tài nguyên hợp lý
- **Logic xóa log an toàn**: Tự động tạo lại file log sau khi xóa để tránh xung đột
- **Tích hợp Settings**: Sử dụng user-configurable retention period

#### 2. AppLogger (Frontend)
Wrapper logger toàn ứng dụng cung cấp giao diện đơn giản.

**Vị trí**: `lib/services/app_logger.dart`

**Tính năng chính**:
- Pattern Singleton cho truy cập toàn cục
- Phương thức logging đơn giản
- Extension methods cho object logging dễ dàng
- Tích hợp tự động dọn dẹp
- **Quản lý Log Files**: Đọc, xóa và lấy thông tin log files
- **Tích hợp Cache Management**: Hiển thị log info trong cache details

### Luồng Kiến Trúc Logging
```
Mã Ứng Dụng -> AppLogger -> FileLoggerService -> Log Files
                                     ↓
                            Bộ Lập Lịch Dọn Dẹp Hàng Ngày
                                     ↓
                               Settings Service (Log Retention)
                                     ↓
                              Cache Management Integration
```

### Tích Hợp UI
- **Cache Details Dialog**: Hiển thị thông tin log files và cung cấp nút xóa
- **Settings Screen**: Cung cấp cấu hình log retention
- **Log Viewer Screen**: Xem và quản lý nội dung log files

## Chi Tiết Triển Khai

### Tổ Chức File
```
{Thư Mục Tài Liệu App}/logs/
├── app_2024-01-15.log
├── app_2024-01-16.log
└── app_2024-01-17.log
```

### Cấp Độ Logging
- **DEBUG**: Thông tin phát triển, truy vết chi tiết
- **INFO**: Sự kiện và thay đổi trạng thái ứng dụng chung
- **WARNING**: Tình huống có thể gây hại
- **ERROR**: Sự kiện lỗi cho phép ứng dụng tiếp tục
- **SEVERE**: Lỗi nghiêm trọng có thể gây dừng ứng dụng

### Tối Ưu Hóa Hiệu Năng

#### 1. Ghi Buffer
```dart
static const int _maxBufferSize = 1024 * 10; // 10KB buffer
static const Duration _flushInterval = Duration(seconds: 3);
```

- **Kích Thước Buffer**: 10KB buffer trong bộ nhớ
- **Khoảng Flush**: Mỗi 3 giây hoặc khi buffer đầy
- **Hiệu Năng**: Giảm thao tác I/O ~90%

#### 2. Xoay Vòng File
```dart
static const int _maxFileSize = 1024 * 1024 * 5; // 5MB mỗi file
```

- **Giới Hạn Kích Thước**: 5MB mỗi file log
- **Chiến Lược**: Xoay vòng hàng ngày + xoay vòng dựa trên kích thước
- **Lợi Ích**: Ngăn file lớn, cải thiện hiệu năng đọc

#### 3. Bộ Lập Lịch Dọn Dẹp Hàng Ngày
```dart
void _setupDailyCleanup() {
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final timeUntilMidnight = tomorrow.difference(now);
  
  _dailyCleanupTimer = Timer(timeUntilMidnight, () {
    cleanupOldLogs();
    // Thiết lập timer định kỳ hàng ngày
    _dailyCleanupTimer = Timer.periodic(
      const Duration(days: 1),
      (_) => cleanupOldLogs(),
    );
  });
}
```

- **Lịch trình**: Chạy vào nửa đêm hàng ngày
- **Tác Động Hiệu Năng**: Không đáng kể (thực thi một lần mỗi ngày)
- **Sử Dụng Tài Nguyên**: Đối tượng timer nhẹ duy nhất
- **Logic Dọn Dẹp**: Xóa file cũ hơn thời gian lưu trữ

## Logic Xóa Log An Toàn

### Vấn Đề Trước Đây
Khi xóa log files, có thể xảy ra xung đột khi:
- `_logSink` vẫn giữ reference đến file đã bị xóa
- Service cần ghi log mới ngay sau khi xóa
- Không có cơ chế recovery khi file không tồn tại

### Giải Pháp Hiện Tại

#### Method `clearAllLogs()` Cải Tiến
```dart
Future<void> clearAllLogs() async {
  try {
    // 1. Đóng sink hiện tại trước khi xóa
    await _logSink.close();
    
    // 2. Xóa tất cả file log
    final files = await getLogFiles();
    for (final file in files) {
      await file.delete();
    }
    
    // 3. Tự động tạo lại file log mới cho ngày hôm nay
    await _createLogFile();
    
    _logger.info('All log files cleared and new log file created');
  } catch (e) {
    _logger.severe('Failed to clear log files', e);
    // 4. Đảm bảo có file log để ghi dù có lỗi
    try {
      await _createLogFile();
    } catch (createError) {
      _logger.severe('Failed to recreate log file after clear error', createError);
    }
  }
}
```

#### Lợi Ích
- ✅ **Không có xung đột**: `_logSink` được đóng và tạo lại
- ✅ **Immediate availability**: File log sẵn sàng ngay lập tức
- ✅ **Error handling mạnh mẽ**: Fallback để tạo file dù có lỗi
- ✅ **Seamless experience**: User không bị gián đoạn logging capability

## Mẫu Sử Dụng

### Logging Cơ Bản
```dart
// Sử dụng AppLogger trực tiếp
AppLogger.instance.info('Người dùng thực hiện hành động');
AppLogger.instance.error('Thao tác thất bại', error, stackTrace);

// Sử dụng extension method
class MyService {
  void performAction() {
    logInfo('Bắt đầu hành động');
    try {
      // ... thao tác
      logInfo('Hành động hoàn thành thành công');
    } catch (e, stackTrace) {
      logError('Hành động thất bại', e, stackTrace);
    }
  }
}
```

### Khởi Tạo
```dart
// Trong main.dart hoặc khởi tạo app
await AppLogger.instance.initialize(loggerName: 'MyMultiTools');
```

### Tích Hợp Quản Lý Log
Hệ thống logging tích hợp với UI Quản Lý Cache:

**Vị trí**: `lib/widgets/cache_details_dialog.dart`

**Tính năng**:
- Hiển thị số lượng file log và tổng kích thước
- Chức năng xóa log thủ công
- Định dạng kích thước thân thiện người dùng
- Dialog xác nhận cho các thao tác phá hủy

## Cấu Hình

### Thời Gian Lưu Trữ Log
**Vị trí**: Settings Service
```dart
// Mặc định: lưu trữ 7 ngày
await SettingsService.updateLogRetentionDays(days);
```

**Kiểm Soát Người Dùng**:
- Có thể cấu hình qua UI Settings
- Phạm vi: 5-15 ngày
- Tự động dọn dẹp dựa trên thời gian lưu trữ

### Đường Dẫn File
- **Thư Mục Log**: `{AppDocuments}/logs/`
- **Mẫu File**: `app_{YYYY-MM-DD}.log`
- **Kích Thước File Tối Đa**: 5MB mỗi file

## Đặc Tính Hiệu Năng

### Sử Dụng Bộ Nhớ
- **Buffer**: 10KB buffer trong bộ nhớ
- **Timer**: Đối tượng timer đơn (~100 bytes)
- **Stream Subscription**: Overhead tối thiểu
- **Tổng**: < 15KB footprint bộ nhớ

### Hiệu Năng I/O
- **Thao Tác Ghi**: Giảm ~90% qua buffering
- **Truy Cập File**: Mẫu truy cập ghi tuần tự
- **Sử Dụng Đĩa**: Tự động quản lý qua xoay vòng và dọn dẹp

### Tác Động CPU
- **Dọn Dẹp Hàng Ngày**: Không đáng kể (một lần mỗi ngày, I/O bound)
- **Buffer Flushing**: Sử dụng CPU tối thiểu
- **Xử Lý Log**: Bất đồng bộ, không chặn

## Xử Lý Lỗi

### Degradation Graceful
```dart
void _handleLogRecord(LogRecord record) {
  if (!_isInitialized) return; // Thất bại âm thầm nếu chưa khởi tạo
  
  try {
    // ... logic logging
  } catch (e) {
    // Fallback về console logging
    print('Ghi log thất bại: $e');
  }
}
```

### Bảo Vệ Tài Nguyên
- **Quản Lý File Handle**: Mở/đóng stream file hợp lý
- **Dọn Dẹp Timer**: Tự động hủy trong disposal
- **Khôi Phục Lỗi**: Xử lý graceful các lỗi I/O

## Điểm Tích Hợp

### 1. Lifecycle Ứng Dụng
```dart
// Khởi Động App
await AppLogger.instance.initialize();

// Kết Thúc App
await AppLogger.instance.dispose();
```

### 2. Quản Lý Cache
- File log bao gồm trong tính toán kích thước cache
- Xóa thủ công qua Cache Details Dialog
- Tích hợp với quản lý storage tổng thể

### 3. Tích Hợp Settings
- Thời gian lưu trữ có thể cấu hình người dùng
- Trigger tự động dọn dẹp khi thay đổi settings
- Lưu trữ persistent của preferences người dùng

## Tích Hợp Settings Service

### Log Retention Configuration
```dart
// Update log retention days
static Future<void> updateLogRetentionDays(int days) async {
  final currentSettings = await getSettings();
  final updatedSettings = currentSettings.copyWith(logRetentionDays: days);
  await saveSettings(updatedSettings);
}

// Get log retention days
static Future<int> getLogRetentionDays() async {
  final settings = await getSettings();
  return settings.logRetentionDays;
}
```

### Automatic Cleanup với User Settings
```dart
Future<void> cleanupOldLogs() async {
  try {
    final retentionDays = await SettingsService.getLogRetentionDays();
    final files = await getLogFiles();
    final cutoffTime = DateTime.now().subtract(Duration(days: retentionDays));

    for (final file in files) {
      final lastModified = await file.lastModified();
      if (lastModified.isBefore(cutoffTime)) {
        await file.delete();
        _logger.info('Deleted old log file: ${file.path} (${retentionDays}d retention)');
      }
    }
  } catch (e) {
    _logger.severe('Failed to cleanup old logs', e);
  }
}
```

### Settings UI Integration
- **Log Retention Section**: Cho phép user cấu hình retention period
- **Expandable Section**: Trong main settings screen
- **Range**: 5-30 ngày hoặc "keep forever"
- **Auto-cleanup**: Trigger khi settings thay đổi

## Best Practices

### Cho Developers
1. **Sử Dụng Extensions**: Tận dụng extension `AppLogging` cho object-specific logging
2. **Bao Gồm Context**: Luôn bao gồm context object/class liên quan
3. **Error Logging**: Bao gồm error objects và stack traces
4. **Performance**: Tránh debug logging quá mức trong production

### Cho Bảo Trì
1. **Theo Dõi Kích Thước Log**: Kiểm tra định kỳ tăng trưởng file log
2. **Điều Chỉnh Retention**: Điều chỉnh dựa trên ràng buộc storage
3. **Theo Dõi Performance**: Quan sát các bottleneck I/O
4. **Mẫu Lỗi**: Xem xét định kỳ error logs

## Cải Tiến Tương Lai

### Cải Tiến Tiềm Năng
1. **Log Levels**: Cấu hình runtime log level
2. **Remote Logging**: Tập hợp log dựa trên cloud
3. **Phân Tích Log**: Log viewer tích hợp với tìm kiếm
4. **Nén**: Tự động nén file log cũ
5. **Structured Logging**: Log định dạng JSON để parsing tốt hơn

### Cân Nhắc Scalability
- **Multi-threading**: Triển khai hiện tại là single-threaded
- **Giới Hạn Storage**: Theo dõi sử dụng đĩa trên thiết bị hạn chế
- **Network Logging**: Cân nhắc remote logging cho debugging

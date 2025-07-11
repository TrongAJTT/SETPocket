# P2P AES-GCM Encryption Feature

## 📖 **Tổng Quan**

Đã nâng cấp tính năng **Encryption Transfer** trong P2LAN từ `AES-CBC + HMAC` sang **`AES-256-GCM`** để tăng cường hiệu năng và cải thiện bảo mật.

## 🔧 **Thay Đổi Được Thực Hiện**

### **1. Models & Settings (Không đổi)**
Các model `P2PTransferSettingsData` và `FileTransferRequest` không thay đổi, vẫn sử dụng các cờ `enableEncryption` và `useEncryption` như trước.

### **2. UI Settings (Không đổi)**
Giao diện người dùng trong P2LAN Transfer Settings vẫn giữ nguyên switch "Encryption Transfer".

### **3. Logic Mã Hóa (Nâng cấp lên GCM)**

#### **EncryptionService** (`lib/services/encryption_service.dart`)
- **Loại bỏ hoàn toàn CBC+HMAC**: Xóa các phương thức `encrypt`, `decrypt`, `encryptChunk`, `decryptChunk`.
- **Chỉ sử dụng GCM**: Giờ đây service chỉ cung cấp `encryptGCM` và `decryptGCM`.

```dart
/// Encrypts data using AES-256-GCM.
static Map<String, Uint8List> encryptGCM(Uint8List data, Uint8List key);

/// Decrypts data using AES-256-GCM.
static Uint8List? decryptGCM(Map<String, Uint8List> encryptedData, Uint8List key);
```

#### **P2PTransferService** (`lib/services/p2p_services/p2p_transfer_service.dart`)
- **Gửi Dữ Liệu**: `_staticDataTransferIsolate` giờ gọi `encryptGCM` và tạo payload mới.
- **Nhận Dữ Liệu**: `_handleDataChunk` được tối ưu để chỉ giải mã payload GCM.
- **Tương thích ngược**: Vẫn xử lý được các chunk không mã hóa từ client cũ.

## 🔄 **Luồng Hoạt Động (Cập nhật)**

### **1. Gửi File (Sender)**
1. User bật "Encryption Transfer".
2. Tạo `FileTransferRequest` với `useEncryption = true`.
3. Chuẩn bị session key.
4. Mã hóa từng chunk bằng **`EncryptionService.encryptGCM()`**.
5. Gửi chunk với payload chứa `ct`, `iv`, `tag`, và `enc: 'gcm'`.

### **2. Nhận File (Receiver)**
1. Nhận `FileTransferRequest` với `useEncryption = true`.
2. Chuẩn bị session key.
3. Khi nhận chunk, kiểm tra `enc: 'gcm'`.
4. Nếu là GCM, giải mã bằng **`EncryptionService.decryptGCM()`**.
5. Nếu không có cờ `enc`, xử lý như dữ liệu không mã hóa.

## 🔒 **Tính Năng Bảo Mật (Nâng cao)**

### **Encryption Details:**
- **Algorithm**: **AES-256-GCM (AEAD)**
- **Ưu điểm so với CBC+HMAC**:
    - **Tốc độ cao hơn**: Mã hóa và xác thực trong một bước.
    - **Bảo mật hơn**: Miễn nhiễm với Padding Oracle Attacks.
    - **Đơn giản hơn**: Giảm nguy cơ lỗi triển khai.
- **IV**: Random 128 bits cho mỗi chunk.
- **Authentication Tag**: 128-bit tag để xác thực.

### **Session Management (Không đổi):**
- Vẫn sử dụng session key cho mỗi user, được tạo tự động và lưu trong memory.

## 🧪 **Testing (Cập nhật)**

File test: `test/encryption_transfer_test.dart`

**Test Cases tập trung vào GCM:**
- ✅ Mã hóa và giải mã GCM thành công.
- ✅ Giải mã thất bại với key sai.
- ✅ Giải mã thất bại khi `ciphertext` bị thay đổi.
- ✅ Giải mã thất bại khi `tag` xác thực bị thay đổi.

**Để chạy test:**
```bash
flutter test test/encryption_transfer_test.dart
```

## ✅ **Kết Luận Nâng Cấp**
- **Hiệu năng**: Tăng tốc độ truyền file, đặc biệt trên các thiết bị có hỗ trợ AES phần cứng, và tiết kiệm pin hơn.
- **Bảo mật**: Nâng cấp lên một tiêu chuẩn mã hóa hiện đại và mạnh mẽ hơn, giảm thiểu các rủi ro tiềm ẩn.
- **Mã nguồn**: Gọn gàng, dễ bảo trì hơn sau khi loại bỏ các logic cũ.
- **Tính tương thích**: Vẫn đảm bảo hoạt động với các client cũ hơn không hỗ trợ mã hóa. 
## Demo Multi-file Import Feature

### Tính năng mới: Import nhiều template JSON cùng lúc

#### Cách sử dụng:
1. Vào **Text Template Generator** 
2. Nhấn nút **+** → **Add from file**
3. Chọn **nhiều file JSON** cùng lúc (Ctrl+Click hoặc Shift+Click)
4. Nhấn **Open**
5. **Dialog kết quả** sẽ hiển thị:
   - ✅ **Thành công**: Danh sách file import thành công
   - ❌ **Thất bại**: Danh sách file thất bại + lý do lỗi

#### Test Files đã tạo:
- `test_template_1.json` - Email template (✅ hợp lệ)
- `test_template_2.json` - Invoice template với loops (✅ hợp lệ) 
- `test_invalid_template.json` - File không hợp lệ (❌ sẽ thất bại)

#### Các cải tiến:
- **UI/UX**: Subtitle đã cập nhật "Import nhiều template từ file JSON"
- **Localization**: Hỗ trợ tiếng Anh và tiếng Việt đầy đủ
- **Error Handling**: Xử lý lỗi chi tiết cho từng file
- **Import Dialog**: Giao diện đẹp hiển thị kết quả import

#### Technical Details:
- `FilePicker.platform.pickFiles(allowMultiple: true)`
- Xử lý từng file riêng biệt với try-catch
- Import status tracking với `ImportResult` class
- Beautiful dialog với icons và colors cho success/error

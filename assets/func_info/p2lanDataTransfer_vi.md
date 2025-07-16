# P2Lan Data Transfer
Chuyển dữ liệu nhanh chóng, an toàn qua mạng LAN giữa các thiết bị trong cùng mạng WiFi, hỗ trợ gửi/nhận file, thư mục, và nhiều tuỳ chọn bảo mật, tối ưu hoá hiệu suất.

## [lan, blue] Tính năng nổi bật
- [icon:devices] Kết nối nhiều thiết bị: Tự động phát hiện và kết nối các thiết bị trong cùng mạng LAN.
- [icon:send] Gửi & nhận file/thư mục: Hỗ trợ gửi nhiều file hoặc cả thư mục với tốc độ cao.
- [icon:security] Tuỳ chọn mã hoá: Bảo vệ dữ liệu với nhiều chế độ mã hoá (None, AES, ...).
- [icon:settings] Tuỳ chỉnh cài đặt: Đa dạng tuỳ chọn về vị trí lưu, giới hạn dung lượng, số luồng truyền, giao thức, thông báo, v.v.
- [icon:history] Quản lý lịch sử & batch: Theo dõi tiến trình, quản lý các batch truyền file, xoá hoặc làm sạch cache dễ dàng.
- [icon:notifications] Thông báo thông minh: Nhận thông báo khi có yêu cầu ghép đôi, nhận file, hoặc hoàn thành truyền dữ liệu.

## [play_circle, green] Hướng dẫn sử dụng nhanh
1. Bắt đầu: Mở chức năng P2Lan Data Transfer trên cả hai thiết bị cùng mạng WiFi.
2. Cấp quyền: Đảm bảo cấp quyền truy cập bộ nhớ, mạng, và thông báo (nếu cần).
3. Mở mạng: Thiết bị sẽ tự động quét và hiển thị các thiết bị khả dụng.
4. Ghép đôi: Chọn thiết bị muốn gửi file, nhấn vào tên thiết bị để ghép đôi (nếu chưa ghép).
5. Gửi file: Sau khi ghép đôi thành công, chọn file/thư mục để gửi.
6. Xử lý yêu cầu gửi: Thiết bị nhận sẽ nhận được thông báo và xác nhận đồng ý nhận file.
7. Truyền file: Theo dõi tiến trình truyền file ở tab "Transfers". Có thể huỷ, xoá, hoặc mở file sau khi truyền xong.

## [settings, indigo] Giải thích các cài đặt quan trọng
- [icon:folder] Download Path: Chọn thư mục lưu file nhận được. Có thể tuỳ chỉnh hoặc dùng mặc định.
- [icon:category] Tổ chức tập tin: Theo ngày, theo người gửi hoặc mặc định.
- Theo ngày: Tự động tạo thư mục theo ngày nhận file.
- Theo người gửi: Tạo thư mục theo tên thiết bị gửi.
- Không phân loại: Lưu tất cả file vào một thư mục.
- [icon:lock] Encryption Type: Chọn chế độ mã hoá dữ liệu truyền (None/AES/...).
- [icon:bolt] Max Chunk Size: Kích thước gói dữ liệu truyền (tăng để tối ưu tốc độ trên mạng mạnh, giảm nếu mạng yếu).
- [icon:layers] Max Concurrent Tasks: Số luồng truyền song song (tăng để truyền nhiều file cùng lúc, giảm nếu thiết bị yếu).
- [icon:notifications] Enable Notifications: Bật/tắt thông báo khi có sự kiện mới.
- [icon:cloud_upload] Max Receive File Size: Giới hạn dung lượng tối đa cho mỗi file nhận.
- [icon:cloud_download] Max Total Receive Size: Giới hạn tổng dung lượng nhận trong một batch.
- [icon:network_wifi] Send Protocol: Chọn giao thức truyền (TCP/UDP).

## [build, purple] Mẹo sử dụng & tối ưu hoá
- Đặt tên thiết bị dễ nhớ để nhận diện nhanh khi ghép đôi.
- Sử dụng mã hoá khi truyền dữ liệu nhạy cảm.
- Tăng chunk size và số luồng trên mạng nội bộ mạnh để đạt tốc độ tối đa.
- Dùng tính năng "Clear Cache" để giải phóng bộ nhớ khi cần.
- Bật thông báo để không bỏ lỡ các yêu cầu nhận file quan trọng.
- Có thể gửi nhiều file/thư mục cùng lúc bằng cách chọn batch gửi.

## [security, orange] Lưu ý bảo mật
- Chỉ ghép đôi và truyền file với thiết bị tin cậy trong cùng mạng LAN.
- Kiểm tra kỹ thông tin thiết bị trước khi xác nhận nhận file.
- Không chia sẻ mạng WiFi với người lạ khi sử dụng chức năng này.
- Sử dụng mã hoá để bảo vệ dữ liệu cá nhân.

## [help_outline, teal] Xử lý sự cố thường gặp
- Không thấy thiết bị khác: Kiểm tra kết nối WiFi, cấp quyền mạng, tắt VPN/chặn mạng.
- Không gửi/nhận được file: Kiểm tra quyền truy cập bộ nhớ, dung lượng còn trống, hoặc thử khởi động lại ứng dụng.
- Lỗi ghép đôi: Đảm bảo cả hai thiết bị đều mở chức năng P2Lan và trong cùng mạng.

## [info_outline, red] Lưu ý quan trọng
- Chức năng chỉ hoạt động trong cùng mạng LAN/WiFi, không hỗ trợ qua Internet.
- Tốc độ truyền phụ thuộc vào chất lượng mạng nội bộ và cấu hình thiết bị.
- Không nên truyền file quá lớn trên thiết bị cấu hình yếu hoặc mạng không ổn định.
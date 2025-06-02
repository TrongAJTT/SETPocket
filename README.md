# my_multi_tools

# Giới thiệu
Đây là một ứng dụng flutter bao gồm nhiều công cụ hữu ích nhỏ.
Giao diện đơn giản như sau:
- Trên các thiết bị màn hình nhỏ (như điện thoại):
    + Landing Screen là một giao diện chọn các công cụ chức năng.
    + Khi nhấn vào chức năng thì sẽ truy cập vào màn hình chức năng tương ứng.
- Trên các thiết bị màn hình lớn (như tablet, pc):
    + Giao diện gồm thanh sidebar chọn các chức năng ở bên trái và main widget hiển thị giao diện của chức năng chiếm phần lớn ở bên phải.

# Các chức năng:

## 1. Xem thông tin của hàng loạt video.
    - Chọn một hoặc nhiều video, màn hình sẽ hiển thị bảng thông tin với các thông tin tương ứng của video:
        + Tên video.
        + Tiện ích (phần mở rộng video).
        + Ngày tạo (dd/MM/yyyy HH:mm).
        + Kích thước (MB).
        + Thời lượng (HH:mm:ss).
        + Bitrate tổng (Kbps).
        + Chiều cao khung hình (pixel).
        + Chiều rộng khung hình (pixel).
        + Tần số khung hình (fps).
        + Bitrate âm thanh.
        + Số kênh âm thanh.
    - Mỗi dòng trong bảng tương ứng với 1 video, mỗi cột ứng với 1 thông số.
    - Sau khi hiển thị hết thì hiện 4 dòng thống kê min, max, avg và common (thông số hiện nhiều nhất).

## 2. Tạo custom paragraph theo biểu mẫu:
    - Chức năng này nhằm giúp soạn văn bản theo một format cố định, chỉ cần điền lại các trường thông tin thay đổi mà thôi.
    - Màn hình chính:
        - Bao gồm list view (builder) liệt kê các template và nút thêm template.
        - Nhấn vào nút thêm template thì đi vào màn hình thêm template.
        - Template được liệt kê dưới dạng các list tile bao gồm tiêu đề template và dấu ... ở cuối list tile.
            - Khi nhấn vào list tile thì đi vào màn hình chức năng tạo văn bản mới theo mẫu.
            - Khi nhấn vào nút ... thì hiện lên 2 tùy chọn là sửa hoặc xóa, khi nhấn vào sửa thì đi vào màn hình sửa template, nhấn vào nút xóa thì hiện dialog xác nhận xong mới xóa.
    - Màn hình tạo hoặc sửa một template:
        - Giao diện bao gồm:
            - Widget textfield để điền tên template.
            - Widget textfield để soạn vản bản mẫu.
            - 3 nút 'Lưu', 'Thêm trường dữ liệu' và 'THêm vòng lặp dữ liệu'.
            - Widget thống kê các trường dữ liệu trong textfield văn bản mẫu.
        - Khi nhấn vào nút thêm trường dữ liệu, hiện lên dialog bao gồm textfield nhập tiêu đề của trường nhập dữ liệu, các radio button để chọn kiểu dữ liệu. 
            - Người dùng cần chọn kiểu dữ liệu và nhập tiêu đề, sau đó nhấn nút 'Thêm' và một template element đại diện cho trường dữ liệu sẽ được thêm vào textfield văn bản mẫu ngay tại vị trí con trỏ hiện tại (nếu không được focus thì thêm vào cuối textfield).
        - Các template element bao gồm:
            - <elm:text:TITLE:ID>       đại diện cho 1 trường nhập văn bản.
            - <elm:largetext:TITLE:ID>  đại diện cho 1 trường nhập văn bản lớn, hỗ trợ xuống dòng (widget cho phép kéo để tùy chỉnh chiều cao).
            - <elm:number:TITLE:ID>     đại diện cho 1 trường nhập số
            - <elm:date:TITLE:ID>       đại diện cho 1 bộ chọn ngày.
            - <elm:time:TITLE:ID>       đại diện cho 1 bộ chọn giờ trong ngày (24h) 
            - <elm:datetime:TITLE:ID>   đại diện cho 1 bộ chọn ngày và giờ trong ngày.
        - Giải thích về các template element:
            - '<' và '>': cú pháp mark up đùng để đánh dấu thẻ.
            - 'elm': để hệ thống nhận biết thẻ này dùng để đánh dấu trường cần điền.
            - 'text', 'largetext', 'number', 'date', 'time', 'datetime': các kiểu dữ liệu để chọn các widget tương ứng.
            - TITLE: tiêu đề của trường nhập dữ liệu.
            - ID: id để phân biệt các template element, tự động tạo theo thứ tự thêm element.
        - Khi nhấn vào nút 'Thêm vòng lặp dữ liệu', 1 dialog hiện lên với TextField yêu cầu nhập tiêu đề vòng lặp và nút 'Thêm', người dùng cần nhập tiêu đề vòng lặp và dữ liệu văn bản sẽ được thêm vào TextField văn bản mẫu.
        - Vòng lặp dữ liệu được định nghĩa là 1 dòng siêu dữ liệu mà người dùng có thể tùy chỉnh số lượng lặp lại của nó với nhiều section widget dữ liệu khác nhau.
            - Format: {{loop:TITLE:ID:\nCONTENT\n}}
            - '{{loop' và '}}' dùng để cho hệ thống nhận biết các vòng lặp dữ liệu.
            - TITLE là tiêu đề của vòng lặp dữ liệu.
            - ID là id dùng để phân biệt các vòng lặp dữ liệu, tự động tạo theo thứ tự thêm vòng lặp.
            - CONTENT là nội dung của 1 vòng lặp dữ liệu, giá trị mặc định khi thêm vào TextField văn bản mẫu là 'Nội dung vòng lặp'.
            - '\n' là ký hiệu xuống dòng văn bản, mặc định khi thêm vào TextField văn bản mẫu thì xuống vòng để thuận tiện tỏng quá trình nhập liệu. Khi xử lý sẽ bỏ các ký tự khoảng trống và xuống dòng giữa đầu và cuối các thành phần.
            - 1 vòng lặp dữ liệu phải có ít nhất 1 widget element, nếu không sẽ báo lỗi ở widget thống kê.
        - Widget thống kê là 1 siêu widget bao gồm nhiều widget con, có tác dụng:
            - Đếm và liệt kê các template element (không nằm trong vòng lặp dữ liệu).
            - Đếm và liệt kê các vòng lặp dữ liệu cùng các template element bên trong nó.
            - Đếm và liệt kê các lỗi (dữ liệu trùng lặp, lỗi template element, lỗi liên quan đến vòng lặp dữ liệu).
        - Khi lưu (thêm hoặc sửa) 1 template: Cần kiểm tra trước có các template element nào có id trùng lặp không thì mới lưu vào dữ liệu, nếu là thêm mới thì tạo id dựa trên timestamp (giây).
    - Màn hình tạo văn bản dựa trên template:
        - Bao gồm widget hiển thị văn bản xem trước, danh sách các widget dữ liệu được tạo tự động dựa theo các template element và nút 'Tạo văn bản' và danh sách các section vòng lặp dữ liệu được tạo tự động.
        - Danh sách các widget dữ liệu được tạo tự động dựa trên các template element, lấy các kiểu dữ liệu tương ứng của widget element ('text', 'largetext', 'number', 'date', 'time', 'datetime') để quyết định các widget được tạo tương ứng. Trên mỗi widget dữ liệu là các dòng chữ tiêu đề (TITLE) để người dùng biết các widget đó đóng vai trò gì. Khi một widget dữ liệu thay đổi thì widget hiển thị văn bản xem trước sẽ được cập nhật tương ứng.
            - Đối với widget 'largetext', cho phép kéo thả để co dãn chiều cao của widget tùy ý.
        - 1 section vòng lặp dữ liệu bao gồm dòng chữ tiêu đề và danh sách section các widget dữ liệu tương ứng trong vòng lặp dữ liệu kèm nút 'Thêm 1 dòng', khi nhấn vào nút thêm 1 dòng thì sẽ thêm 1 section các widget dữ liệu mới trong section vòng lặp dữ liệu tương ứng.
            - Mỗi section các widget dữ liệu bao gồm danh sách các widget dữ iệu được tạo tự động (theo cơ chế bên trên) và nút 'Xóa dòng này', nếu chỉ còn 1 dòng dữ liệu trong vòng lặp dữ liệu thì nút này sẽ bị ẩn đi. Khi nhấn nút thì hiện dialog xác nhận xóa trước khi xóa.
        - Khi nhấn vào nút 'Tạo văn bản', hiển thị một dialog bao gồm widget TextField hiển thị nội dung của widget xem trước văn bản để người dùng có thể tùy ý copy và xử lý với dữ liệu đó.


## 3. Random
    - Bao gồm hàng loạt chức năng random con với các thành phần và điều kiện như liệt kê sau:
        - Mật khẩu: (Số ký tự, các checkbox chữ thường, chữ hoa, số và ký tự đặc biệt, cần chọn ít nhất 1 checkbox).
        - Số học: (Số nguyên dương hay số thực, random bao nhiêu số, giới hạn min max, cho phép random trùng).
        - Yes or No?
        - Tung đồng xu (Sấp hay ngửa)
        - Kéo búa bao.
        - Tung xúc xắc (tung bao nhiêu cục, số mặt? 3,4,5,6,7,8,10,12,14,16,20,24,30,48,50,100)
        - Random màu (dựa trên hex6, hex8)
        - Random chữ cái Latin (Bao nhiêu chữ cái)
        - Random lá bài trong bộ bài tây (bài chuẩn 52 lá)
        - Random ngày (Số lượng, giới hạn min max, cho phép random trùng).
        - Random giờ (Số lượng, giới hạn min, max, cho phép random trùng).
        - Random cả ngày và giờ (Số lượng, giới hạn min max ngày, giới hạn min max giờ, cho phép random trùng).
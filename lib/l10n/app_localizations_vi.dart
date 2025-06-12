// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get title => 'SETPocket';

  @override
  String get settings => 'Cài đặt';

  @override
  String get theme => 'Chủ đề';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get userInterface => 'Giao diện người dùng';

  @override
  String get system => 'Theo hệ thống';

  @override
  String get light => 'Sáng';

  @override
  String get dark => 'Tối';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get cache => 'Bộ nhớ đệm';

  @override
  String get clearCache => 'Xóa bộ nhớ đệm';

  @override
  String get cacheDetails => 'Chi tiết bộ nhớ đệm';

  @override
  String get viewCacheDetails => 'Xem chi tiết';

  @override
  String get cacheSize => 'Kích thước bộ nhớ đệm';

  @override
  String get cacheItems => 'Mục';

  @override
  String get clearAllCache => 'Xóa tất cả bộ nhớ đệm';

  @override
  String get logs => 'Nhật ký ứng dụng';

  @override
  String get viewLogs => 'Xem nhật ký';

  @override
  String get clearLogs => 'Xóa nhật ký';

  @override
  String get logRetention => 'Thời gian lưu nhật ký';

  @override
  String logRetentionDays(int days) {
    return '$days ngày';
  }

  @override
  String get logRetentionForever => 'Vĩnh viễn';

  @override
  String get logRetentionDesc => 'Tự động xóa các file nhật ký cũ hơn số ngày đã chỉ định';

  @override
  String get logRetentionDescDetail => 'Nhật ký sẽ được lưu trữ trong bộ nhớ đệm và có thể được xóa tự động sau một khoảng thời gian nhất định. Bạn có thể đặt thời gian lưu giữ nhật ký từ 5 đến 30 ngày (bước nhảy 5 ngày) hoặc chọn lưu vĩnh viễn.';

  @override
  String get logRetentionAutoDelete => 'Tự động xóa sau một khoảng thời gian';

  @override
  String get logManagement => 'Quản lý nhật ký';

  @override
  String get logManagementDesc => 'Quản lý các file nhật ký ứng dụng và thông tin debug';

  @override
  String get logStatus => 'Trạng thái nhật ký';

  @override
  String get logsDesc => 'Các file nhật ký ứng dụng và thông tin debug';

  @override
  String get dataAndStorage => 'Dữ liệu & Lưu trữ';

  @override
  String confirmClearCache(Object cacheName) {
    return 'Bạn có chắc chắn muốn xóa bộ nhớ đệm \"$cacheName\"?';
  }

  @override
  String get confirmClearAllCache => 'Bạn có chắc chắn muốn xóa TẤT CẢ dữ liệu bộ nhớ đệm? Điều này sẽ xóa tất cả template đã lưu nhưng giữ lại cài đặt của bạn.';

  @override
  String cacheCleared(Object cacheName) {
    return 'Đã xóa bộ nhớ đệm $cacheName thành công';
  }

  @override
  String get allCacheCleared => 'Đã xóa tất cả bộ nhớ đệm thành công';

  @override
  String errorClearingCache(Object error) {
    return 'Lỗi khi xóa bộ nhớ đệm: $error';
  }

  @override
  String get close => 'Đóng';

  @override
  String get options => 'Tùy chọn';

  @override
  String get about => 'Giới thiệu';

  @override
  String get save => 'Lưu';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get copy => 'Sao chép';

  @override
  String get cancel => 'Hủy';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get searchHint => 'Tìm kiếm...';

  @override
  String get total => 'Tổng cộng';

  @override
  String get selectTool => 'Chọn một chức năng ở thanh bên';

  @override
  String get selectToolDesc => 'Chọn một công cụ từ thanh bên trái để bắt đầu';

  @override
  String get settingsDesc => 'Cá nhân hóa trải nghiệm sử dụng ứng dụng';

  @override
  String get random => 'Trình tạo ngẫu nhiên';

  @override
  String get randomDesc => 'Tạo mật khẩu, số, ngày và nhiều thứ ngẫu nhiên khác';

  @override
  String get textTemplateGen => 'Tạo văn bản theo mẫu';

  @override
  String get textTemplateGenDesc => 'Tạo văn bản theo biểu mẫu có sẵn. Bạn có thể tạo các mẫu văn bản với các trường thông tin cần điền như văn bản, số, ngày tháng để sử dụng lại nhiều lần.';

  @override
  String get editTemplate => 'Sửa mẫu';

  @override
  String get createTemplate => 'Tạo mẫu mới';

  @override
  String get contentTab => 'Nội dung';

  @override
  String get structureTab => 'Cấu trúc';

  @override
  String get templateTitleLabel => 'Tiêu đề mẫu *';

  @override
  String get templateTitleHint => 'Nhập tiêu đề cho mẫu này';

  @override
  String get pleaseEnterTitle => 'Vui lòng nhập tiêu đề';

  @override
  String get addDataField => 'Thêm trường dữ liệu';

  @override
  String get addDataLoop => 'Thêm vòng lặp dữ liệu';

  @override
  String get fieldTypeText => 'Văn bản';

  @override
  String get fieldTypeLargeText => 'Văn bản nhiều dòng';

  @override
  String get fieldTypeNumber => 'Số';

  @override
  String get fieldTypeDate => 'Ngày';

  @override
  String get fieldTypeTime => 'Giờ';

  @override
  String get fieldTypeDateTime => 'Ngày & Giờ';

  @override
  String get fieldTitleLabel => 'Tiêu đề trường *';

  @override
  String get fieldTitleHint => 'VD: Tên khách hàng';

  @override
  String get pleaseEnterFieldTitle => 'Vui lòng nhập tiêu đề trường';

  @override
  String get copyAndClose => 'Sao chép và đóng';

  @override
  String get insertAtCursor => 'Chèn tại vị trí con trỏ';

  @override
  String get appendToEnd => 'Thêm vào cuối';

  @override
  String get loopTitleLabel => 'Tiêu đề vòng lặp *';

  @override
  String get loopTitleHint => 'VD: Danh sách sản phẩm';

  @override
  String get pleaseFixDuplicateIds => 'Vui lòng sửa các ID trùng lặp không nhất quán trước khi lưu';

  @override
  String errorSavingTemplate(Object error) {
    return 'Lỗi khi lưu mẫu: $error';
  }

  @override
  String get templateContentLabel => 'Nội dung mẫu *';

  @override
  String get templateContentHint => 'Nhập nội dung mẫu và thêm trường dữ liệu...';

  @override
  String get pleaseEnterTemplateContent => 'Vui lòng nhập nội dung mẫu';

  @override
  String get templateStructure => 'Cấu trúc mẫu';

  @override
  String get templateStructureOverview => 'Xem tổng quan các trường và vòng lặp trong mẫu.';

  @override
  String get textTemplatesTitle => 'Các mẫu văn bản';

  @override
  String get addNewTemplate => 'Thêm mẫu mới';

  @override
  String get noTemplatesYet => 'Chưa có mẫu nào';

  @override
  String get createTemplatesHint => 'Tạo mẫu đầu tiên để bắt đầu.';

  @override
  String get createNewTemplate => 'Tạo mẫu mới';

  @override
  String get exportToJson => 'Xuất ra JSON';

  @override
  String get confirmDeletion => 'Xác nhận xóa';

  @override
  String confirmDeleteTemplateMsg(Object title) {
    return 'Bạn có chắc muốn xóa \"$title\"?';
  }

  @override
  String get templateDeleted => 'Đã xóa mẫu.';

  @override
  String errorDeletingTemplate(Object error) {
    return 'Lỗi khi xóa mẫu: $error';
  }

  @override
  String get help => 'Trợ giúp';

  @override
  String get usageGuide => 'Hướng dẫn sử dụng';

  @override
  String get textTemplateToolIntro => 'Công cụ này giúp bạn quản lý và sử dụng các mẫu văn bản hiệu quả.';

  @override
  String get helpCreateNewTemplate => 'Tạo mẫu mới bằng nút +.';

  @override
  String get helpTapToUseTemplate => 'Nhấn vào mẫu để sử dụng.';

  @override
  String get helpTapMenuForActions => 'Nhấn vào menu (⋮) để xem thêm tùy chọn.';

  @override
  String get textTemplateScreenHint => 'Các mẫu được lưu cục bộ trên thiết bị của bạn.';

  @override
  String get gotIt => 'Đã hiểu';

  @override
  String get addTemplate => 'Thêm mẫu';

  @override
  String get addManually => 'Thêm thủ công';

  @override
  String get createTemplateFromScratch => 'Tạo mẫu từ đầu';

  @override
  String get addFromFile => 'Thêm từ file';

  @override
  String get importTemplateFromJson => 'Nhập nhiều template từ file JSON';

  @override
  String get templateImported => 'Nhập template thành công.';

  @override
  String templatesImported(Object count) {
    return 'Đã nhập $count template thành công.';
  }

  @override
  String get importResults => 'Kết quả nhập';

  @override
  String importSummary(Object failCount, Object successCount) {
    return '$successCount thành công, $failCount thất bại';
  }

  @override
  String successfulImports(Object count) {
    return 'Nhập thành công ($count)';
  }

  @override
  String failedImports(Object count) {
    return 'Nhập thất bại ($count)';
  }

  @override
  String get noImportsAttempted => 'Không có file nào được chọn để nhập';

  @override
  String invalidTemplateFormat(Object error) {
    return 'Định dạng template không hợp lệ: $error';
  }

  @override
  String errorImportingTemplate(Object error) {
    return 'Lỗi khi nhập mẫu: $error';
  }

  @override
  String get copySuffix => 'bản sao';

  @override
  String get templateCopied => 'Đã sao chép mẫu.';

  @override
  String errorCopyingTemplate(Object error) {
    return 'Lỗi khi sao chép mẫu: $error';
  }

  @override
  String get saveTemplateAsJson => 'Lưu mẫu thành file JSON';

  @override
  String templateExported(Object path) {
    return 'Đã xuất mẫu ra $path';
  }

  @override
  String errorExportingTemplate(Object error) {
    return 'Lỗi khi xuất mẫu: $error';
  }

  @override
  String generateDocumentTitle(Object title) {
    return 'Tạo tài liệu: $title';
  }

  @override
  String get fillDataTab => 'Điền dữ liệu';

  @override
  String get previewTab => 'Xem trước';

  @override
  String get showDocument => 'Hiển thị tài liệu';

  @override
  String get fillInformation => 'Điền thông tin';

  @override
  String get dataLoops => 'Vòng lặp dữ liệu';

  @override
  String get generateDocument => 'Tạo tài liệu';

  @override
  String get preview => 'Xem trước';

  @override
  String get addNewRow => 'Thêm dòng mới';

  @override
  String rowNumber(Object number) {
    return 'Dòng $number';
  }

  @override
  String get deleteThisRow => 'Xóa dòng này';

  @override
  String enterField(Object field) {
    return 'Nhập $field';
  }

  @override
  String unsupportedFieldType(Object type) {
    return 'Không hỗ trợ kiểu trường $type';
  }

  @override
  String get selectDate => 'Chọn ngày';

  @override
  String get selectTime => 'Chọn giờ';

  @override
  String get selectDateTime => 'Chọn ngày và giờ';

  @override
  String get copiedToClipboard => 'Đã sao chép vào clipboard';

  @override
  String get completedDocument => 'Tài liệu đã hoàn thành';

  @override
  String fieldCount(Object count) {
    return 'Trường dữ liệu: $count';
  }

  @override
  String get basicFieldCount => 'trường dữ liệu cơ bản';

  @override
  String get loopFieldCount => 'trường dữ liệu trong vòng lặp';

  @override
  String loopDataCount(Object count) {
    return 'Vòng lặp dữ liệu: $count';
  }

  @override
  String duplicateIdWarning(Object count) {
    return 'Phát hiện $count ID trùng lặp không nhất quán. Element có cùng ID phải có cùng loại và tiêu đề.';
  }

  @override
  String get normalFields => 'Trường dữ liệu thông thường:';

  @override
  String loopLabel(Object title) {
    return 'Vòng lặp: $title';
  }

  @override
  String get structureDetail => 'Chi tiết cấu trúc';

  @override
  String get basicFields => 'Trường dữ liệu cơ bản';

  @override
  String get loopContent => 'Nội dung vòng lặp';

  @override
  String fieldInLoop(Object field, Object loop) {
    return 'Trường \"$field\" thuộc vòng lặp \"$loop\"';
  }

  @override
  String characterCount(Object count) {
    return '$count ký tự';
  }

  @override
  String fieldsAndLoops(Object fields, Object loops) {
    return '$fields trường, $loops vòng lặp';
  }

  @override
  String get longPressToSelect => 'Nhấn giữ để chọn mẫu';

  @override
  String selectedTemplates(Object count) {
    return 'Đã chọn $count';
  }

  @override
  String get selectAll => 'Chọn tất cả';

  @override
  String get deselectAll => 'Bỏ chọn tất cả';

  @override
  String get batchExport => 'Xuất đã chọn';

  @override
  String get batchDelete => 'Xóa đã chọn';

  @override
  String get exportTemplates => 'Xuất mẫu';

  @override
  String get editFilenames => 'Chỉnh sửa tên tệp trước khi xuất:';

  @override
  String filenameFor(Object title) {
    return 'Tên tệp cho \"$title\":';
  }

  @override
  String get confirmBatchDelete => 'Xác nhận xóa hàng loạt';

  @override
  String typeConfirmToDelete(Object count) {
    return 'Gõ \"confirm\" để xóa $count mẫu đã chọn:';
  }

  @override
  String get confirmText => 'confirm';

  @override
  String get confirmationRequired => 'Vui lòng gõ \"confirm\" để tiếp tục';

  @override
  String batchExportCompleted(Object count) {
    return 'Đã xuất $count mẫu thành công';
  }

  @override
  String batchDeleteCompleted(Object count) {
    return 'Đã xóa $count mẫu thành công';
  }

  @override
  String errorDuringBatchExport(Object errors) {
    return 'Lỗi khi xuất một số mẫu: $errors';
  }

  @override
  String get passwordGenerator => 'Tạo mật khẩu';

  @override
  String get numCharacters => 'Số ký tự';

  @override
  String get includeLowercase => 'Bao gồm chữ thường';

  @override
  String get includeUppercase => 'Bao gồm chữ hoa';

  @override
  String get includeNumbers => 'Bao gồm số';

  @override
  String get includeSpecial => 'Bao gồm ký tự đặc biệt';

  @override
  String get generate => 'Tạo';

  @override
  String get generatedPassword => 'Mật khẩu đã tạo';

  @override
  String get copyToClipboard => 'Sao chép';

  @override
  String get copied => 'Đã sao chép!';

  @override
  String get numberGenerator => 'Tạo số ngẫu nhiên';

  @override
  String get integers => 'Số nguyên';

  @override
  String get floatingPoint => 'Số thực';

  @override
  String get minValue => 'Giá trị tối thiểu';

  @override
  String get maxValue => 'Giá trị tối đa';

  @override
  String get quantity => 'Số lượng';

  @override
  String get allowDuplicates => 'Cho phép trùng lặp';

  @override
  String get generatedNumbers => 'Các số đã tạo';

  @override
  String get other => 'Khác';

  @override
  String get yesNo => 'Có hay Không?';

  @override
  String get flipCoin => 'Tung đồng xu';

  @override
  String get flipCoinInstruction => 'Lật đồng xu để xem kết quả';

  @override
  String get rockPaperScissors => 'Kéo búa bao';

  @override
  String get rollDice => 'Tung xúc xắc';

  @override
  String get diceCount => 'Số lượng xúc xắc';

  @override
  String get diceSides => 'Số mặt mỗi xúc xắc';

  @override
  String get colorGenerator => 'Tạo màu ngẫu nhiên';

  @override
  String get hex6 => 'HEX (6 chữ số)';

  @override
  String get hex8 => 'HEX (8 chữ số với alpha)';

  @override
  String get generatedColor => 'Màu đã tạo';

  @override
  String get latinLetters => 'Chữ cái Latin';

  @override
  String get letterCount => 'Số lượng chữ cái';

  @override
  String get tens => 'Chục';

  @override
  String get units => 'Đơn vị';

  @override
  String get playingCards => 'Bài tây';

  @override
  String get includeJokers => 'Bao gồm lá Joker';

  @override
  String get cardCount => 'Số lượng lá bài';

  @override
  String get currencyConverter => 'Quy đổi tiền tệ';

  @override
  String get updatingRates => 'Đang cập nhật tỷ giá tiền tệ...';

  @override
  String lastUpdatedAt(Object date, Object time) {
    return 'Cập nhật lần cuối: $date lúc $time';
  }

  @override
  String get noRatesAvailable => 'Chưa có thông tin tỷ giá tiền tệ, đang lấy tỷ giá...';

  @override
  String get liveRates => 'Tỷ giá thời gian thực';

  @override
  String get staticRates => 'Tĩnh';

  @override
  String get refreshRates => 'Làm mới tỷ giá';

  @override
  String get resetLayout => 'Đặt lại bố cục';

  @override
  String get customizeCurrencies => 'Tùy chỉnh tiền tệ';

  @override
  String get addCard => 'Thêm thẻ';

  @override
  String get addRow => 'Thêm dòng';

  @override
  String get cardView => 'Chế độ thẻ';

  @override
  String get cards => 'Thẻ';

  @override
  String get rows => 'Dòng';

  @override
  String get converter => 'Bộ chuyển đổi';

  @override
  String get amount => 'Số tiền';

  @override
  String get from => 'Từ';

  @override
  String get fromCurrency => 'Từ loại tiền';

  @override
  String get convertedTo => 'Chuyển đổi thành';

  @override
  String get removeCard => 'Xóa thẻ';

  @override
  String get removeRow => 'Xóa dòng';

  @override
  String get liveRatesUpdated => 'Đã cập nhật tỷ giá trực tiếp thành công';

  @override
  String get staticRatesUsed => 'Đang sử dụng tỷ giá tĩnh (không có dữ liệu trực tiếp)';

  @override
  String get failedToUpdateRates => 'Không thể cập nhật tỷ giá';

  @override
  String get actions => 'Hành động';

  @override
  String get customizeCurrenciesDialog => 'Tùy chỉnh tiền tệ';

  @override
  String get searchCurrencies => 'Tìm kiếm tiền tệ...';

  @override
  String get noCurrenciesFound => 'Không tìm thấy tiền tệ';

  @override
  String currenciesSelected(Object count) {
    return 'Đã chọn $count loại tiền';
  }

  @override
  String get applyChanges => 'Áp dụng thay đổi';

  @override
  String get currencyStatusSuccess => 'Tỷ giá trực tiếp';

  @override
  String get currencyStatusFailed => 'Lỗi lấy dữ liệu';

  @override
  String get currencyStatusTimeout => 'Hết thời gian';

  @override
  String get currencyStatusNotSupported => 'Không hỗ trợ';

  @override
  String get currencyStatusStatic => 'Tỷ giá tĩnh';

  @override
  String get currencyStatusFetchedRecently => 'Đã fetch gần đây';

  @override
  String get currencyStatusSuccessDesc => 'Đã lấy tỷ giá trực tiếp thành công';

  @override
  String get currencyStatusFailedDesc => 'Không thể lấy tỷ giá trực tiếp, sử dụng tỷ giá tĩnh';

  @override
  String get currencyStatusTimeoutDesc => 'Hết thời gian chờ, sử dụng tỷ giá tĩnh';

  @override
  String get currencyStatusNotSupportedDesc => 'API không hỗ trợ loại tiền này';

  @override
  String get currencyStatusStaticDesc => 'Đang sử dụng tỷ giá tĩnh';

  @override
  String get currencyStatusFetchedRecentlyDesc => 'Đã fetch thành công trong vòng 1 giờ qua';

  @override
  String get currencyConverterInfo => 'Thông tin chuyển đổi tiền tệ';

  @override
  String get aboutThisFeature => 'Về chức năng này';

  @override
  String get aboutThisFeatureDesc => 'Chuyển đổi tiền tệ cho phép bạn quy đổi giữa các loại tiền khác nhau bằng tỷ giá trực tiếp hoặc tỷ giá tĩnh. Hỗ trợ hơn 80 loại tiền tệ trên thế giới.';

  @override
  String get howToUse => 'Cách sử dụng';

  @override
  String get howToUseDesc => '• Thêm hoặc xóa thẻ/dòng cho nhiều phép chuyển đổi\n• Tùy chỉnh các loại tiền hiển thị\n• Chuyển đổi giữa chế độ thẻ và bảng\n• Tỷ giá tự động cập nhật theo cài đặt của bạn';

  @override
  String get staticRatesInfo => 'Tỷ giá tĩnh';

  @override
  String get staticRatesInfoDesc => 'Tỷ giá tĩnh là giá trị dự phòng được sử dụng khi không thể lấy tỷ giá trực tiếp. Các tỷ giá này được cập nhật định kỳ và có thể không phản ánh giá thị trường thời gian thực.';

  @override
  String get viewStaticRates => 'Xem tỷ giá tĩnh';

  @override
  String get lastStaticUpdate => 'Lần cập nhật tỷ giá tĩnh cuối: Tháng 5/2025';

  @override
  String get staticRatesList => 'Danh sách tỷ giá tĩnh';

  @override
  String get rateBasedOnUSD => 'Tất cả tỷ giá dựa trên 1 USD';

  @override
  String get maxCurrenciesSelected => 'Tối đa 10 loại tiền có thể được chọn';

  @override
  String get savePreset => 'Lưu Cấu Hình';

  @override
  String get loadPreset => 'Lấy Cấu Hình';

  @override
  String get presetName => 'Tên Cấu Hình';

  @override
  String get enterPresetName => 'Nhập tên cấu hình';

  @override
  String get presetNameRequired => 'Tên cấu hình là bắt buộc';

  @override
  String presetSaved(String name) {
    return 'Đã lưu cấu hình: $name';
  }

  @override
  String get presetLoaded => 'Cấu hình đã được tải thành công';

  @override
  String get presetDeleted => 'Cấu hình đã được xóa thành công';

  @override
  String get deletePreset => 'Xóa Cấu Hình';

  @override
  String get confirmDeletePreset => 'Bạn có chắc chắn muốn xóa cấu hình này không?';

  @override
  String get sortBy => 'Sắp xếp theo';

  @override
  String get sortByName => 'Tên';

  @override
  String get sortByDate => 'Ngày tạo';

  @override
  String get noPresetsFound => 'Không tìm thấy cấu hình nào';

  @override
  String get select => 'Chọn';

  @override
  String get delete => 'Xóa';

  @override
  String createdOn(Object date) {
    return 'Tạo vào $date';
  }

  @override
  String currencies(Object count) {
    return '$count loại tiền';
  }

  @override
  String currenciesCount(Object count) {
    return '$count loại tiền';
  }

  @override
  String createdDate(Object date) {
    return 'Tạo: $date';
  }

  @override
  String get sortByLabel => 'Sắp xếp theo:';

  @override
  String get selectPreset => 'Chọn';

  @override
  String get deletePresetAction => 'Xóa';

  @override
  String get deletePresetTitle => 'Xóa Cấu Hình';

  @override
  String get deletePresetConfirm => 'Bạn có chắc chắn muốn xóa cấu hình này không?';

  @override
  String get presetDeletedSuccess => 'Đã xóa cấu hình';

  @override
  String get errorLabel => 'Lỗi:';

  @override
  String get fetchTimeout => 'Thời Gian Chờ Fetch';

  @override
  String get fetchTimeoutDesc => 'Thiết lập thời gian chờ khi lấy tỷ giá (5-20 giây)';

  @override
  String fetchTimeoutSeconds(Object seconds) {
    return '${seconds}s';
  }

  @override
  String get fetchRetryIncomplete => 'Thử lại khi chưa hoàn tất';

  @override
  String get fetchRetryIncompleteDesc => 'Tự động thử lại các loại tiền bị lỗi/timeout trong quá trình fetch';

  @override
  String fetchRetryTimes(int times) {
    return '$times lần thử';
  }

  @override
  String get fetchingRates => 'Đang Lấy Tỷ Giá';

  @override
  String fetchingProgress(Object completed, Object total) {
    return 'Tiến độ: $completed/$total';
  }

  @override
  String timeRemaining(Object seconds) {
    return 'Thời gian còn lại: ${seconds}s';
  }

  @override
  String get fetchingStatus => 'Tình Trạng';

  @override
  String fetchingCurrency(Object currency) {
    return 'Đang lấy $currency...';
  }

  @override
  String get fetchComplete => 'Hoàn Thành';

  @override
  String get fetchCancelled => 'Đã Hủy';

  @override
  String get dateGenerator => 'Tạo ngày ngẫu nhiên';

  @override
  String get startDate => 'Ngày bắt đầu';

  @override
  String get endDate => 'Ngày kết thúc';

  @override
  String get dateCount => 'Số lượng ngày';

  @override
  String get timeGenerator => 'Tạo giờ ngẫu nhiên';

  @override
  String get startTime => 'Giờ bắt đầu';

  @override
  String get endTime => 'Giờ kết thúc';

  @override
  String get timeCount => 'Số lượng giờ';

  @override
  String get dateTimeGenerator => 'Tạo ngày giờ ngẫu nhiên';

  @override
  String get heads => 'Sấp';

  @override
  String get tails => 'Ngửa';

  @override
  String get rock => 'Búa';

  @override
  String get paper => 'Bao';

  @override
  String get scissors => 'Kéo';

  @override
  String get randomResult => 'Kết quả';

  @override
  String get flipping => 'Đang lật...';

  @override
  String get cacheTypeTextTemplates => 'Mẫu văn bản';

  @override
  String get cacheTypeTextTemplatesDesc => 'Các mẫu văn bản và nội dung đã lưu';

  @override
  String get cacheTypeAppSettings => 'Cài đặt ứng dụng';

  @override
  String get cacheTypeAppSettingsDesc => 'Giao diện, ngôn ngữ và tùy chọn người dùng';

  @override
  String get cacheTypeRandomGenerators => 'Trình tạo ngẫu nhiên';

  @override
  String get cacheTypeRandomGeneratorsDesc => 'Lịch sử tạo và cài đặt';

  @override
  String get saveGenerationHistory => 'Ghi nhớ lịch sử tạo';

  @override
  String get saveGenerationHistoryDesc => 'Ghi nhớ và hiển thị lịch sử các mục đã tạo';

  @override
  String get generationHistory => 'Lịch sử tạo';

  @override
  String get generatedAt => 'Tạo lúc';

  @override
  String get noHistoryYet => 'Chưa có lịch sử';

  @override
  String get clearHistory => 'Xóa lịch sử';

  @override
  String get typeConfirmToProceed => 'Nhập \"confirm\" để tiếp tục:';

  @override
  String get toolsShortcuts => 'Công cụ & Phím tắt';

  @override
  String get displayArrangeTools => 'Hiển thị và sắp xếp công cụ';

  @override
  String get displayArrangeToolsDesc => 'Điều khiển công cụ nào hiển thị và thứ tự của chúng';

  @override
  String get manageToolVisibility => 'Quản lý Hiển thị và Thứ tự Công cụ';

  @override
  String get dragToReorder => 'Kéo để sắp xếp lại công cụ';

  @override
  String get allToolsHidden => 'Tất cả công cụ đã ẩn';

  @override
  String get allToolsHiddenDesc => 'Vui lòng bật ít nhất một công cụ để tiếp tục sử dụng ứng dụng';

  @override
  String get enableAtLeastOneTool => 'Vui lòng bật ít nhất một công cụ';

  @override
  String get toolVisibilityChanged => 'Hiển thị công cụ đã được cập nhật';

  @override
  String get resetToDefault => 'Đặt lại mặc định';

  @override
  String get manageQuickActions => 'Quản lý Thao tác nhanh';

  @override
  String get manageQuickActionsDesc => 'Cấu hình phím tắt để truy cập nhanh các công cụ';

  @override
  String get quickActionsDialogTitle => 'Thao tác nhanh';

  @override
  String get quickActionsDialogDesc => 'Chọn tối đa 4 công cụ để truy cập nhanh qua biểu tượng ứng dụng hoặc thanh tác vụ';

  @override
  String get quickActionsLimit => 'Tối đa 4 thao tác nhanh được phép';

  @override
  String get quickActionsLimitReached => 'Bạn chỉ có thể chọn tối đa 4 công cụ cho thao tác nhanh';

  @override
  String get clearAllQuickActions => 'Xóa tất cả';

  @override
  String get quickActionsCleared => 'Đã xóa thao tác nhanh';

  @override
  String get quickActionsUpdated => 'Đã cập nhật thao tác nhanh';

  @override
  String get quickActionsInfo => 'Thao tác nhanh';

  @override
  String get selectUpTo4Tools => 'Chọn tối đa 4 công cụ để truy cập nhanh.';

  @override
  String get quickActionsEnableDesc => 'Thao tác nhanh sẽ xuất hiện khi bạn nhấn giữ biểu tượng ứng dụng trên Android hoặc nhấp chuột phải vào biểu tượng thanh tác vụ trên Windows.';

  @override
  String get quickActionsEnableDescMobile => 'Thao tác nhanh sẽ xuất hiện khi bạn nhấn giữ biểu tượng ứng dụng (chỉ Android/iOS).';

  @override
  String selectedCount(int current, int max) {
    return 'Đã chọn: $current trong $max';
  }

  @override
  String get maxQuickActionsReached => 'Đã đạt tối đa 4 thao tác nhanh';

  @override
  String get clearAll => 'Xóa tất cả';

  @override
  String get converterTools => 'Công cụ Chuyển đổi';

  @override
  String get converterToolsDesc => 'Chuyển đổi giữa các đơn vị và hệ thống khác nhau';

  @override
  String get calculatorTools => 'Công cụ Tính toán';

  @override
  String get calculatorToolsDesc => 'Máy tính chuyên dụng cho sức khỏe, tài chính và nhiều hơn nữa';

  @override
  String get lengthConverter => 'Chuyển đổi Chiều dài';

  @override
  String get temperatureConverter => 'Chuyển đổi Nhiệt độ';

  @override
  String get volumeConverter => 'Chuyển đổi Thể tích';

  @override
  String get areaConverter => 'Chuyển đổi Diện tích';

  @override
  String get speedConverter => 'Chuyển đổi Tốc độ';

  @override
  String get timeConverter => 'Chuyển đổi Thời gian';

  @override
  String get dataConverter => 'Chuyển đổi Dung lượng';

  @override
  String get numberSystemConverter => 'Chuyển đổi Hệ số';

  @override
  String get tables => 'Bảng';

  @override
  String get tableView => 'Chế độ bảng';

  @override
  String get listView => 'Chế độ danh sách';

  @override
  String get customizeUnits => 'Tùy chỉnh Đơn vị';

  @override
  String get visibleUnits => 'Đơn vị hiển thị';

  @override
  String get selectUnitsToShow => 'Chọn đơn vị để hiển thị';

  @override
  String get enterValue => 'Nhập giá trị';

  @override
  String get conversionResults => 'Kết quả chuyển đổi';

  @override
  String get meters => 'Mét';

  @override
  String get kilometers => 'Kilômét';

  @override
  String get centimeters => 'Xentimét';

  @override
  String get millimeters => 'Milimét';

  @override
  String get inches => 'Inch';

  @override
  String get feet => 'Feet';

  @override
  String get yards => 'Yard';

  @override
  String get miles => 'Dặm';

  @override
  String get grams => 'Gram';

  @override
  String get kilograms => 'Kilogram';

  @override
  String get pounds => 'Pound';

  @override
  String get ounces => 'Ounce';

  @override
  String get tons => 'Tấn';

  @override
  String get celsius => 'Độ C';

  @override
  String get fahrenheit => 'Độ F';

  @override
  String get kelvin => 'Kelvin';

  @override
  String get liters => 'Lít';

  @override
  String get milliliters => 'Mililít';

  @override
  String get gallons => 'Gallon';

  @override
  String get quarts => 'Quart';

  @override
  String get pints => 'Pint';

  @override
  String get cups => 'Cốc';

  @override
  String get squareMeters => 'Mét vuông';

  @override
  String get squareKilometers => 'Kilômét vuông';

  @override
  String get squareFeet => 'Feet vuông';

  @override
  String get squareInches => 'Inch vuông';

  @override
  String get acres => 'Acre';

  @override
  String get hectares => 'Hecta';

  @override
  String get metersPerSecond => 'Mét/giây';

  @override
  String get kilometersPerHour => 'Kilômét/giờ';

  @override
  String get milesPerHour => 'Dặm/giờ';

  @override
  String get knots => 'Hải lý/giờ';

  @override
  String get seconds => 'Giây';

  @override
  String get minutes => 'Phút';

  @override
  String get hours => 'Giờ';

  @override
  String get days => 'Ngày';

  @override
  String get weeks => 'Tuần';

  @override
  String get months => 'Tháng';

  @override
  String get years => 'Năm';

  @override
  String get bytes => 'Byte';

  @override
  String get kilobytes => 'Kilobyte';

  @override
  String get megabytes => 'Megabyte';

  @override
  String get gigabytes => 'Gigabyte';

  @override
  String get terabytes => 'Terabyte';

  @override
  String get bits => 'Bit';

  @override
  String get decimal => 'Thập phân';

  @override
  String get binary => 'Nhị phân';

  @override
  String get octal => 'Bát phân';

  @override
  String get hexadecimal => 'Thập lục phân';

  @override
  String get usd => 'Đô la Mỹ';

  @override
  String get eur => 'Euro';

  @override
  String get gbp => 'Bảng Anh';

  @override
  String get jpy => 'Yên Nhật';

  @override
  String get cad => 'Đô la Canada';

  @override
  String get aud => 'Đô la Úc';

  @override
  String get vnd => 'Đồng Việt Nam';

  @override
  String get currencyConverterDesc => 'Quy đổi giữa các loại tiền tệ với tỷ giá thời gian thực';

  @override
  String get lengthConverterDesc => 'Chuyển đổi giữa các đơn vị chiều dài khác nhau';

  @override
  String get weightConverterDesc => 'Chuyển đổi giữa các đơn vị trọng lượng khác nhau';

  @override
  String get temperatureConverterDesc => 'Chuyển đổi giữa các thang đo nhiệt độ khác nhau';

  @override
  String get volumeConverterDesc => 'Chuyển đổi giữa các đơn vị thể tích khác nhau';

  @override
  String get areaConverterDesc => 'Chuyển đổi giữa các đơn vị diện tích khác nhau';

  @override
  String get speedConverterDesc => 'Chuyển đổi giữa các đơn vị tốc độ khác nhau';

  @override
  String get timeConverterDesc => 'Chuyển đổi giữa các đơn vị thời gian khác nhau';

  @override
  String get dataConverterDesc => 'Chuyển đổi giữa các đơn vị lưu trữ dữ liệu khác nhau';

  @override
  String get numberSystemConverterDesc => 'Chuyển đổi giữa các hệ đếm khác nhau';

  @override
  String get fromUnit => 'Từ đơn vị';

  @override
  String get unit => 'Đơn vị';

  @override
  String get value => 'Giá trị';

  @override
  String get showAll => 'Hiển thị tất cả';

  @override
  String get apply => 'Áp dụng';

  @override
  String get bmiCalculator => 'Máy tính BMI';

  @override
  String get bmiCalculatorDesc => 'Tính chỉ số khối cơ thể và phân loại sức khỏe';

  @override
  String get scientificCalculator => 'Máy tính Khoa học';

  @override
  String get scientificCalculatorDesc => 'Máy tính nâng cao với các hàm lượng giác, logarit';

  @override
  String get graphingCalculator => 'Máy tính Vẽ đồ thị';

  @override
  String get graphingCalculatorDesc => 'Vẽ và hiển thị các hàm toán học';

  @override
  String get metric => 'Hệ mét';

  @override
  String get imperial => 'Hệ Anh';

  @override
  String get enterMeasurements => 'Nhập số đo của bạn';

  @override
  String get heightCm => 'Chiều cao (cm)';

  @override
  String get heightInches => 'Chiều cao (inches)';

  @override
  String get weightKg => 'Cân nặng (kg)';

  @override
  String get weightPounds => 'Cân nặng (pounds)';

  @override
  String get yourBMI => 'BMI của bạn';

  @override
  String get bmiScale => 'Thang đo BMI';

  @override
  String get underweight => 'Thiếu cân';

  @override
  String get normalWeight => 'Bình thường';

  @override
  String get overweight => 'Thừa cân';

  @override
  String get obese => 'Béo phì';

  @override
  String get currencyFetchMode => 'Tải tỷ giá Tiền tệ';

  @override
  String get currencyFetchModeDesc => 'Chọn cách cập nhật tỷ giá hối đoái';

  @override
  String get fetchModeManual => 'Thủ công';

  @override
  String get fetchModeManualDesc => 'Chỉ sử dụng tỷ giá đã lưu, cập nhật thủ công bằng nút làm mới (giới hạn 6 tiếng 1 lần)';

  @override
  String get fetchModeOnceADay => 'Một lần mỗi ngày';

  @override
  String get fetchModeOnceADayDesc => 'Tự động tải tỷ giá một lần mỗi ngày';

  @override
  String get currencyFetchStatus => 'Trạng thái tải tiền tệ';

  @override
  String get fetchStatusSummary => 'Tóm tắt trạng thái tải';

  @override
  String get success => 'Thành công';

  @override
  String get failed => 'Thất bại';

  @override
  String get timeout => 'Hết thời gian';

  @override
  String get static => 'Tĩnh';

  @override
  String get noCurrenciesInThisCategory => 'Không có tiền tệ nào trong danh mục này';

  @override
  String get saveFeatureState => 'Lưu trạng thái tính năng';

  @override
  String get saveFeatureStateDesc => 'Ghi nhớ trạng thái của các tính năng giữa các phiên sử dụng';

  @override
  String get testCache => 'Kiểm tra bộ nhớ đệm';

  @override
  String get viewDataStatus => 'Xem trạng thái dữ liệu';

  @override
  String retryAttempt(int current, int max) {
    return 'Thử lại lần $current/$max';
  }

  @override
  String ratesUpdatedWithErrors(int errorCount) {
    return 'Đã cập nhật tỷ giá với $errorCount lỗi';
  }

  @override
  String get newRatesAvailable => 'Có tỷ giá mới khả dụng. Bạn có muốn tải ngay bây giờ không?';

  @override
  String get progressDialogInfo => 'Điều này sẽ hiện dialog tiến trình trong khi tải tỷ giá.';

  @override
  String get calculating => 'Đang tính toán...';

  @override
  String get unknown => 'Không rõ';

  @override
  String get logsManagement => 'Quản lý log ứng dụng và cài đặt lưu trữ';

  @override
  String statusInfo(String info) {
    return 'Trạng thái: $info';
  }

  @override
  String get logsAvailable => 'Log khả dụng';

  @override
  String get noTimeData => '--:--:--';

  @override
  String get fetchStatusTab => 'Trạng thái fetch';

  @override
  String get currencyValueTab => 'Giá trị tiền tệ';

  @override
  String successfulCount(int count) {
    return 'Thành công ($count)';
  }

  @override
  String failedCount(int count) {
    return 'Thất bại ($count)';
  }

  @override
  String timeoutCount(int count) {
    return 'Timeout ($count)';
  }

  @override
  String recentlyUpdatedCount(int count) {
    return 'Cập nhật gần đây ($count)';
  }

  @override
  String updatedCount(int count) {
    return 'Đã cập nhật ($count)';
  }

  @override
  String staticCount(int count) {
    return 'Static ($count)';
  }

  @override
  String get noCurrenciesInCategory => 'Không có tiền tệ nào trong danh mục này';

  @override
  String get updatedWithinLastHour => 'Cập nhật trong vòng 1 giờ qua';

  @override
  String updatedDaysAgo(int days) {
    return 'Cập nhật $days ngày trước';
  }

  @override
  String updatedHoursAgo(int hours) {
    return 'Cập nhật $hours giờ trước';
  }

  @override
  String get hasUpdateData => 'Có dữ liệu cập nhật';

  @override
  String get usingStaticRates => 'Sử dụng tỷ giá tĩnh';

  @override
  String get scrollToTop => 'Lên đầu trang';

  @override
  String get scrollToBottom => 'Xuống cuối trang';

  @override
  String get logActions => 'Hành động log';

  @override
  String get previousChunk => 'Phần trước';

  @override
  String get nextChunk => 'Phần sau';

  @override
  String get loadAll => 'Tải tất cả';

  @override
  String get firstPart => 'Phần đầu';

  @override
  String get lastPart => 'Phần cuối';

  @override
  String get largeFile => 'File lớn';

  @override
  String get loadingLargeFile => 'Đang tải file lớn...';

  @override
  String get loadingLogContent => 'Đang tải nội dung log...';

  @override
  String get largeFileDetected => 'Phát hiện file lớn. Đang sử dụng tải tối ưu...';

  @override
  String get cacheTypeConverterTools => 'Công cụ chuyển đổi';

  @override
  String get cacheTypeConverterToolsDesc => 'Trạng thái tiền tệ/chiều dài, cài đặt sẵn và bộ nhớ đệm tỷ giá';

  @override
  String get cardName => 'Tên Thẻ';

  @override
  String get cardNameHint => 'Nhập tên thẻ (tố đa 20 ký tự)';

  @override
  String converterCardNameDefault(Object position) {
    return 'Thẻ $position';
  }

  @override
  String unitSelectedStatus(Object count, Object max) {
    return 'Đã chọn $count trong $max';
  }

  @override
  String unitVisibleStatus(Object count) {
    return '$count đơn vị hiển thị';
  }

  @override
  String get moveDown => 'Di chuyển xuống';

  @override
  String get moveUp => 'Di chuyển lên';

  @override
  String get lengthUnits => 'Đơn vị chiều dài';

  @override
  String get angstroms => 'Angstrom';

  @override
  String get nanometers => 'Nanometer';

  @override
  String get microns => 'Micron';

  @override
  String get nauticalMiles => 'Hải lý';

  @override
  String get customizeLengthUnits => 'Tùy chỉnh đơn vị chiều dài';

  @override
  String get selectLengthUnits => 'Chọn đơn vị chiều dài để hiển thị';

  @override
  String get lengthConverterInfo => 'Thông tin bộ chuyển đổi chiều dài';

  @override
  String get weightConverter => 'Chuyển đổi Trọng lượng';

  @override
  String get weightConverterInfo => 'Thông tin Chuyển đổi Trọng lượng';

  @override
  String get customizeWeightUnits => 'Tùy chỉnh đơn vị Trọng lượng';

  @override
  String get massConverter => 'Chuyển đổi Khối lượng';

  @override
  String get massConverterInfo => 'Thông tin Chuyển đổi Khối lượng';

  @override
  String get massConverterDesc => 'Chuyển đổi giữa các đơn vị khối lượng (kg, lb, oz)';

  @override
  String get customizeMassUnits => 'Tùy chỉnh đơn vị Khối lượng';

  @override
  String get availableUnits => 'Đơn vị có sẵn';

  @override
  String get scientificNotation => 'Hỗ trợ ký hiệu khoa học cho giá trị cực lớn/nhỏ';

  @override
  String get dragging => 'Đang kéo...';

  @override
  String get editName => 'Sửa tên';

  @override
  String get editCurrencies => 'Sửa tiền tệ';

  @override
  String tableWith(int count) {
    return 'Bảng $count thẻ';
  }

  @override
  String get noUnitsSelected => 'Chưa chọn đơn vị nào';

  @override
  String get maximumSelectionExceeded => 'Vượt quá giới hạn lựa chọn tối đa';

  @override
  String errorSavingPreset(String error) {
    return 'Lỗi lưu cấu hình: $error';
  }

  @override
  String errorLoadingPresets(String error) {
    return 'Lỗi tải cấu hình: $error';
  }

  @override
  String get maximumSelectionReached => 'Đã đạt giới hạn lựa chọn tối đa';

  @override
  String minimumSelectionRequired(int count) {
    return 'Cần tối thiểu $count lựa chọn';
  }

  @override
  String get renamePreset => 'Đổi tên cấu hình';

  @override
  String get rename => 'Đổi tên';

  @override
  String get presetRenamedSuccessfully => 'Đã đổi tên cấu hình thành công';

  @override
  String get chooseFromSavedPresets => 'Chọn từ các cấu hình đã lưu';

  @override
  String get currencyConverterDetailedInfo => 'Bộ chuyển đổi tiền tệ - Thông tin chi tiết';

  @override
  String get currencyConverterOverview => 'Bộ chuyển đổi tiền tệ mạnh mẽ này cho phép bạn chuyển đổi giữa các loại tiền tệ khác nhau với tỷ giá thời gian thực.';

  @override
  String get keyFeatures => 'Tính năng chính';

  @override
  String get multipleCards => 'Nhiều thẻ chuyển đổi';

  @override
  String get multipleCardsDesc => 'Tạo nhiều thẻ chuyển đổi, mỗi thẻ có bộ tiền tệ và số tiền riêng.';

  @override
  String get liveRatesDesc => 'Nhận tỷ giá hối đoái thời gian thực từ các nguồn tài chính đáng tin cậy.';

  @override
  String get customizeCurrenciesDesc => 'Chọn tiền tệ hiển thị và lưu cấu hình tùy chỉnh.';

  @override
  String get dragAndDrop => 'Kéo thả';

  @override
  String get dragAndDropDesc => 'Sắp xếp lại thứ tự các thẻ chuyển đổi bằng cách kéo thả.';

  @override
  String get cardAndTableView => 'Chế độ thẻ & bảng';

  @override
  String get cardAndTableViewDesc => 'Chuyển đổi giữa chế độ thẻ để dễ sử dụng hoặc chế độ bảng để so sánh.';

  @override
  String get stateManagement => 'Quản lý trạng thái';

  @override
  String get stateManagementDesc => 'Trạng thái chuyển đổi của bạn được tự động lưu và khôi phục.';

  @override
  String get step1 => '1. Thêm thẻ';

  @override
  String get step1Desc => 'Nhấn \'Thêm thẻ\' để tạo thẻ chuyển đổi mới.';

  @override
  String get step2 => '2. Nhập số tiền';

  @override
  String get step2Desc => 'Nhập số tiền vào bất kỳ trường tiền tệ nào.';

  @override
  String get step3 => '3. Chọn tiền tệ gốc';

  @override
  String get step3Desc => 'Sử dụng menu thả xuống để chọn loại tiền tệ bạn muốn chuyển đổi từ đó.';

  @override
  String get step4 => '4. Xem kết quả';

  @override
  String get step4Desc => 'Xem kết quả chuyển đổi tức thì sang tất cả các loại tiền tệ khác trong thẻ.';

  @override
  String get tips => 'Mẹo sử dụng';

  @override
  String get tip1 => '• Nhấn vào biểu tượng chỉnh sửa để đổi tên thẻ';

  @override
  String get tip2 => '• Sử dụng biểu tượng tiền tệ để tùy chỉnh tiền tệ hiển thị';

  @override
  String get tip3 => '• Lưu cấu hình tiền tệ để truy cập nhanh';

  @override
  String get tip4 => '• Kiểm tra chỉ báo trạng thái để biết độ mới của tỷ giá';

  @override
  String get tip5 => '• Sử dụng chế độ bảng để so sánh nhiều thẻ cạnh nhau';

  @override
  String get rateUpdate => 'Cập nhật tỷ giá';

  @override
  String get rateUpdateDesc => 'Tỷ giá hối đoái được cập nhật dựa trên cài đặt của bạn. Kiểm tra Cài đặt > Công cụ chuyển đổi để cấu hình tần suất cập nhật và hành vi thử lại.';

  @override
  String poweredBy(String service) {
    return 'Được hỗ trợ bởi $service';
  }

  @override
  String exchangeRatesBy(String service) {
    return 'Tỷ giá hối đoái từ $service';
  }

  @override
  String get dataAttribution => 'Nguồn dữ liệu';

  @override
  String get apiProviderAttribution => 'Dữ liệu tỷ giá hối đoái được cung cấp bởi ExchangeRate-API.com';

  @override
  String get rateLimitReached => 'Đã đạt giới hạn tần suất';

  @override
  String get rateLimitMessage => 'Bạn chỉ có thể tải tỷ giá tiền tệ 6 tiếng 1 lần. Vui lòng thử lại sau.';

  @override
  String nextFetchAllowedIn(String timeRemaining) {
    return 'Có thể tải tiếp theo sau: $timeRemaining';
  }

  @override
  String get rateLimitInfo => 'Giới hạn tần suất giúp ngăn ngừa lạm dụng API và đảm bảo dịch vụ luôn khả dụng cho mọi người.';

  @override
  String get understood => 'Đã hiểu';
}

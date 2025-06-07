// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get title => 'Nhiều Công Cụ';

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
  String get delete => 'Xóa';

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
  String get weightConverter => 'Chuyển đổi Khối lượng';

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
  String get currencyConverter => 'Chuyển đổi Tiền tệ';

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
  String get currencyConverterDesc => 'Chuyển đổi giữa các loại tiền tệ khác nhau';

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
}

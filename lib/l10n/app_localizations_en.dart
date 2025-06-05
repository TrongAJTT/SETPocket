// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'Multi Tools';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get cache => 'Cache';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get cacheDetails => 'Cache Details';

  @override
  String get viewCacheDetails => 'View Details';

  @override
  String get cacheSize => 'Cache Size';

  @override
  String get cacheItems => 'Items';

  @override
  String get clearAllCache => 'Clear All Cache';

  @override
  String confirmClearCache(Object cacheName) {
    return 'Are you sure you want to clear \"$cacheName\" cache?';
  }

  @override
  String get confirmClearAllCache => 'Are you sure you want to clear ALL cache data? This will remove all saved templates but preserve your settings.';

  @override
  String cacheCleared(Object cacheName) {
    return '$cacheName cache cleared successfully';
  }

  @override
  String get allCacheCleared => 'All cache cleared successfully';

  @override
  String errorClearingCache(Object error) {
    return 'Error clearing cache: $error';
  }

  @override
  String get close => 'Close';

  @override
  String get options => 'Options';

  @override
  String get about => 'About';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Copy';

  @override
  String get cancel => 'Cancel';

  @override
  String get total => 'Total';

  @override
  String get selectTool => 'Select a tool from the sidebar';

  @override
  String get settingsDesc => 'Personalize your experience';

  @override
  String get random => 'Random Generator';

  @override
  String get randomDesc => 'Generate random passwords, numbers, dates, and more';

  @override
  String get textTemplateGen => 'Text Template Generator';

  @override
  String get textTemplateGenDesc => 'Create documents from templates. You can create reusable templates with fields like text, number, date.';

  @override
  String get editTemplate => 'Edit Template';

  @override
  String get createTemplate => 'Create New Template';

  @override
  String get contentTab => 'Content';

  @override
  String get structureTab => 'Structure';

  @override
  String get templateTitleLabel => 'Template Title *';

  @override
  String get templateTitleHint => 'Enter title for this template';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get addDataField => 'Add Data Field';

  @override
  String get addDataLoop => 'Add Data Loop';

  @override
  String get fieldTypeText => 'Text';

  @override
  String get fieldTypeLargeText => 'Large Text';

  @override
  String get fieldTypeNumber => 'Number';

  @override
  String get fieldTypeDate => 'Date';

  @override
  String get fieldTypeTime => 'Time';

  @override
  String get fieldTypeDateTime => 'DateTime';

  @override
  String get fieldTitleLabel => 'Field title *';

  @override
  String get fieldTitleHint => 'E.g. Customer name';

  @override
  String get pleaseEnterFieldTitle => 'Please enter field title';

  @override
  String get copyAndClose => 'Copy and Close';

  @override
  String get insertAtCursor => 'Insert at Cursor';

  @override
  String get appendToEnd => 'Append to End';

  @override
  String get loopTitleLabel => 'Loop title *';

  @override
  String get loopTitleHint => 'E.g. Product list';

  @override
  String get pleaseFixDuplicateIds => 'Please fix inconsistent duplicate IDs before saving';

  @override
  String errorSavingTemplate(Object error) {
    return 'Error saving template: $error';
  }

  @override
  String get templateContentLabel => 'Template Content *';

  @override
  String get templateContentHint => 'Enter template content and add data fields...';

  @override
  String get pleaseEnterTemplateContent => 'Please enter template content';

  @override
  String get templateStructure => 'Template Structure';

  @override
  String get templateStructureOverview => 'View an overview of fields and loops in your template.';

  @override
  String get textTemplatesTitle => 'Templates';

  @override
  String get addNewTemplate => 'Add new template';

  @override
  String get noTemplatesYet => 'No templates yet';

  @override
  String get createTemplatesHint => 'Create your first template to get started.';

  @override
  String get createNewTemplate => 'Create new template';

  @override
  String get exportToJson => 'Export to JSON';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String confirmDeleteTemplateMsg(Object title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get templateDeleted => 'Template deleted.';

  @override
  String errorDeletingTemplate(Object error) {
    return 'Error deleting template: $error';
  }

  @override
  String get help => 'Help';

  @override
  String get usageGuide => 'Usage Guide';

  @override
  String get textTemplateToolIntro => 'This tool helps you manage and use text templates efficiently.';

  @override
  String get helpCreateNewTemplate => 'Create a new template using the + button.';

  @override
  String get helpTapToUseTemplate => 'Tap a template to use it.';

  @override
  String get helpTapMenuForActions => 'Tap the menu (⋮) for more actions.';

  @override
  String get textTemplateScreenHint => 'Templates are saved locally on your device.';

  @override
  String get gotIt => 'Got it';

  @override
  String get addTemplate => 'Add Template';

  @override
  String get addManually => 'Add manually';

  @override
  String get createTemplateFromScratch => 'Create a template from scratch';

  @override
  String get addFromFile => 'Add from file';

  @override
  String get importTemplateFromJson => 'Import multiple templates from JSON files';

  @override
  String get templateImported => 'Template imported successfully.';

  @override
  String templatesImported(Object count) {
    return 'Templates imported successfully.';
  }

  @override
  String get importResults => 'Import Results';

  @override
  String importSummary(Object failCount, Object successCount) {
    return '$successCount successful, $failCount failed';
  }

  @override
  String successfulImports(Object count) {
    return 'Successful imports ($count)';
  }

  @override
  String failedImports(Object count) {
    return 'Failed imports ($count)';
  }

  @override
  String get noImportsAttempted => 'No files were selected for import';

  @override
  String invalidTemplateFormat(Object error) {
    return 'Invalid template format: $error';
  }

  @override
  String errorImportingTemplate(Object error) {
    return 'Error importing template: $error';
  }

  @override
  String get copySuffix => 'copy';

  @override
  String get templateCopied => 'Template copied.';

  @override
  String errorCopyingTemplate(Object error) {
    return 'Error copying template: $error';
  }

  @override
  String get saveTemplateAsJson => 'Save template as JSON';

  @override
  String templateExported(Object path) {
    return 'Template exported to $path';
  }

  @override
  String errorExportingTemplate(Object error) {
    return 'Error exporting template: $error';
  }

  @override
  String generateDocumentTitle(Object title) {
    return 'Generate Document: $title';
  }

  @override
  String get fillDataTab => 'Fill Data';

  @override
  String get previewTab => 'Preview';

  @override
  String get showDocument => 'Show Document';

  @override
  String get fillInformation => 'Fill Information';

  @override
  String get dataLoops => 'Data Loops';

  @override
  String get generateDocument => 'Generate Document';

  @override
  String get preview => 'Preview';

  @override
  String get addNewRow => 'Add New Row';

  @override
  String rowNumber(Object number) {
    return 'Row $number';
  }

  @override
  String get deleteThisRow => 'Delete this row';

  @override
  String enterField(Object field) {
    return 'Enter $field';
  }

  @override
  String unsupportedFieldType(Object type) {
    return 'Field type $type not supported';
  }

  @override
  String get selectDate => 'Select date';

  @override
  String get selectTime => 'Select time';

  @override
  String get selectDateTime => 'Select date and time';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get completedDocument => 'Completed Document';

  @override
  String fieldCount(Object count) {
    return 'Fields: $count';
  }

  @override
  String get basicFieldCount => 'basic fields';

  @override
  String get loopFieldCount => 'fields in loops';

  @override
  String loopDataCount(Object count) {
    return 'Data loops: $count';
  }

  @override
  String duplicateIdWarning(Object count) {
    return 'Detected $count inconsistent duplicate IDs. Elements with the same ID must have the same type and title.';
  }

  @override
  String get normalFields => 'Normal fields:';

  @override
  String loopLabel(Object title) {
    return 'Loop: $title';
  }

  @override
  String get structureDetail => 'Structure details';

  @override
  String get basicFields => 'Basic fields';

  @override
  String get loopContent => 'Loop content';

  @override
  String fieldInLoop(Object field, Object loop) {
    return 'Field \"$field\" belongs to loop \"$loop\"';
  }

  @override
  String characterCount(Object count) {
    return '$count characters';
  }

  @override
  String fieldsAndLoops(Object fields, Object loops) {
    return '$fields fields, $loops loops';
  }

  @override
  String get longPressToSelect => 'Long press to select templates';

  @override
  String selectedTemplates(Object count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get batchExport => 'Export Selected';

  @override
  String get batchDelete => 'Delete Selected';

  @override
  String get exportTemplates => 'Export Templates';

  @override
  String get editFilenames => 'Edit file names before export:';

  @override
  String filenameFor(Object title) {
    return 'Filename for \"$title\":';
  }

  @override
  String get confirmBatchDelete => 'Confirm Batch Delete';

  @override
  String typeConfirmToDelete(Object count) {
    return 'Type \"confirm\" to delete $count selected templates:';
  }

  @override
  String get confirmText => 'confirm';

  @override
  String get confirmationRequired => 'Please type \"confirm\" to proceed';

  @override
  String batchExportCompleted(Object count) {
    return 'Exported $count templates successfully';
  }

  @override
  String batchDeleteCompleted(Object count) {
    return 'Deleted $count templates successfully';
  }

  @override
  String errorDuringBatchExport(Object errors) {
    return 'Error exporting some templates: $errors';
  }

  @override
  String get passwordGenerator => 'Password Generator';

  @override
  String get numCharacters => 'Number of characters';

  @override
  String get includeLowercase => 'Include lowercase letters';

  @override
  String get includeUppercase => 'Include uppercase letters';

  @override
  String get includeNumbers => 'Include numbers';

  @override
  String get includeSpecial => 'Include special characters';

  @override
  String get generate => 'Generate';

  @override
  String get generatedPassword => 'Generated Password';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get copied => 'Copied!';

  @override
  String get numberGenerator => 'Number Generator';

  @override
  String get integers => 'Integers';

  @override
  String get floatingPoint => 'Floating Point';

  @override
  String get minValue => 'Minimum Value';

  @override
  String get maxValue => 'Maximum Value';

  @override
  String get quantity => 'Quantity';

  @override
  String get allowDuplicates => 'Allow Duplicates';

  @override
  String get generatedNumbers => 'Generated Numbers';

  @override
  String get other => 'Other';

  @override
  String get yesNo => 'Yes or No?';

  @override
  String get flipCoin => 'Flip Coin';

  @override
  String get flipCoinInstruction => 'Flip the coin to see the result';

  @override
  String get rockPaperScissors => 'Rock Paper Scissors';

  @override
  String get rollDice => 'Roll Dice';

  @override
  String get diceCount => 'Number of dice';

  @override
  String get diceSides => 'Sides per die';

  @override
  String get colorGenerator => 'Color Generator';

  @override
  String get hex6 => 'HEX (6-digit)';

  @override
  String get hex8 => 'HEX (8-digit with alpha)';

  @override
  String get generatedColor => 'Generated Color';

  @override
  String get latinLetters => 'Latin Letters';

  @override
  String get letterCount => 'Number of letters';

  @override
  String get tens => 'Tens';

  @override
  String get units => 'Units';

  @override
  String get playingCards => 'Playing Cards';

  @override
  String get cardCount => 'Number of cards';

  @override
  String get dateGenerator => 'Date Generator';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get dateCount => 'Number of dates';

  @override
  String get timeGenerator => 'Time Generator';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get timeCount => 'Number of times';

  @override
  String get dateTimeGenerator => 'Date & Time Generator';

  @override
  String get heads => 'Heads';

  @override
  String get tails => 'Tails';

  @override
  String get rock => 'Rock';

  @override
  String get paper => 'Paper';

  @override
  String get scissors => 'Scissors';

  @override
  String get randomResult => 'Result';

  @override
  String get flipping => 'Flipping...';
}

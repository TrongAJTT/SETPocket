// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get title => 'SETPocket';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get userInterface => 'User Interface';

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
  String get logs => 'Application Logs';

  @override
  String get viewLogs => 'View Logs';

  @override
  String get clearLogs => 'Clear Logs';

  @override
  String get logRetention => 'Log Retention';

  @override
  String logRetentionDays(int days) {
    return '$days days';
  }

  @override
  String get logRetentionForever => 'Keep forever';

  @override
  String get logRetentionDesc => 'Set how long to keep application logs before automatic deletion';

  @override
  String get logRetentionDescDetail => 'Choose log retention period (5-30 days in 5-day intervals, or forever)';

  @override
  String get logRetentionAutoDelete => 'Auto-delete after a period of time';

  @override
  String get logManagement => 'App logs management and storage settings';

  @override
  String get logManagementDesc => 'Manage application logs and retention settings';

  @override
  String get logStatus => 'Log Status';

  @override
  String get logsDesc => 'Application log files and debug information';

  @override
  String get dataAndStorage => 'Data & Storage';

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
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Copy';

  @override
  String get cancel => 'Cancel';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search...';

  @override
  String get total => 'Total';

  @override
  String get selectTool => 'Select a tool from the sidebar';

  @override
  String get selectToolDesc => 'Choose a tool from the left sidebar to get started';

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
  String get templateEditSuccessMessage => 'Template saved successfully! You can now navigate back.';

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
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String confirmDeleteTemplateMsg(Object title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get holdToDeleteInstruction => 'Hold the delete button for 5 seconds to confirm';

  @override
  String get holdToDelete => 'Hold to delete...';

  @override
  String get deleting => 'Deleting...';

  @override
  String get holdToClearCache => 'Hold to clear...';

  @override
  String get clearingCache => 'Clearing cache...';

  @override
  String get holdToClearCacheInstruction => 'Hold the clear button for 10 seconds to confirm';

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
  String get restored => 'Restored!';

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
  String get includeSeconds => 'Include Seconds';

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
  String get includeJokers => 'Include Jokers';

  @override
  String get cardCount => 'Number of cards';

  @override
  String get currencyConverter => 'Currency Converter';

  @override
  String get updatingRates => 'Updating exchange rates...';

  @override
  String lastUpdatedAt(Object date, Object time) {
    return 'Last updated: $date at $time';
  }

  @override
  String get noRatesAvailable => 'No exchange rate information available, fetching rates...';

  @override
  String get liveRates => 'Live Exchange Rates';

  @override
  String get staticRates => 'Static';

  @override
  String get refreshRates => 'Refresh rates';

  @override
  String get resetLayout => 'Reset Layout';

  @override
  String get confirmResetLayout => 'Confirm Reset Layout';

  @override
  String get confirmResetLayoutMessage => 'Are you sure you want to reset the layout? This will remove all cards and restore default settings.';

  @override
  String get confirm => 'Confirm';

  @override
  String get customizeCurrencies => 'Customize Currencies';

  @override
  String get addCard => 'Add Card';

  @override
  String get addRow => 'Add Row';

  @override
  String get cardView => 'Card View';

  @override
  String get cards => 'Cards';

  @override
  String get rows => 'Rows';

  @override
  String get converter => 'Converter';

  @override
  String get amount => 'Amount';

  @override
  String get from => 'From';

  @override
  String get fromCurrency => 'From Currency';

  @override
  String get convertedTo => 'Converted to';

  @override
  String get removeCard => 'Remove card';

  @override
  String get removeRow => 'Remove row';

  @override
  String get liveRatesUpdated => 'Live rates updated successfully';

  @override
  String get staticRatesUsed => 'Using static rates (live data unavailable)';

  @override
  String get failedToUpdateRates => 'Failed to update rates';

  @override
  String get actions => 'Actions';

  @override
  String get customizeCurrenciesDialog => 'Customize Currencies';

  @override
  String get searchCurrencies => 'Search currencies...';

  @override
  String get noCurrenciesFound => 'No currencies found';

  @override
  String currenciesSelected(Object count) {
    return '$count currencies selected';
  }

  @override
  String get applyChanges => 'Apply Changes';

  @override
  String get currencyStatusSuccess => 'Live rate';

  @override
  String get currencyStatusFailed => 'Failed to fetch';

  @override
  String get currencyStatusTimeout => 'Timeout';

  @override
  String get currencyStatusNotSupported => 'Not supported';

  @override
  String get currencyStatusStatic => 'Static rate';

  @override
  String get currencyStatusFetchedRecently => 'Recently fetched';

  @override
  String get currencyStatusSuccessDesc => 'Successfully fetched live rate';

  @override
  String get currencyStatusFailedDesc => 'Failed to fetch live rate, using static fallback';

  @override
  String get currencyStatusTimeoutDesc => 'Request timed out, using static fallback';

  @override
  String get currencyStatusNotSupportedDesc => 'Currency not supported by API';

  @override
  String get currencyStatusStaticDesc => 'Using static exchange rate';

  @override
  String get currencyStatusFetchedRecentlyDesc => 'Successfully fetched within the last hour';

  @override
  String get currencyConverterInfo => 'Currency Converter Info';

  @override
  String get aboutThisFeature => 'About This Feature';

  @override
  String get aboutThisFeatureDesc => 'The Currency Converter allows you to convert between different currencies using live or static exchange rates. It supports over 80 currencies worldwide.';

  @override
  String get howToUse => 'How to Use';

  @override
  String get howToUseDesc => '• Add or remove cards/rows for multiple conversions\n• Customize visible currencies\n• Switch between card and table view\n• Rates update automatically based on your settings';

  @override
  String get staticRatesInfo => 'Static Exchange Rates';

  @override
  String get staticRatesInfoDesc => 'Static rates are fallback values used when live rates cannot be fetched. These rates are updated periodically and may not reflect real-time market prices.';

  @override
  String get viewStaticRates => 'View Static Rates';

  @override
  String get lastStaticUpdate => 'Last static rates update: May 2025';

  @override
  String get staticRatesList => 'Static Exchange Rates List';

  @override
  String get rateBasedOnUSD => 'All rates are based on 1 USD';

  @override
  String get maxCurrenciesSelected => 'Maximum 10 currencies can be selected';

  @override
  String get savePreset => 'Save Preset';

  @override
  String get loadPreset => 'Load Preset';

  @override
  String get presetName => 'Preset Name';

  @override
  String get enterPresetName => 'Enter preset name';

  @override
  String get presetNameRequired => 'Preset name is required';

  @override
  String get presetSaved => 'Preset saved successfully';

  @override
  String get presetLoaded => 'Preset loaded successfully';

  @override
  String get presetDeleted => 'Preset deleted successfully';

  @override
  String get deletePreset => 'Delete Preset';

  @override
  String get confirmDeletePreset => 'Are you sure you want to delete this preset?';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByDate => 'Date';

  @override
  String get noPresetsFound => 'No presets found';

  @override
  String get select => 'Select';

  @override
  String get delete => 'Delete';

  @override
  String createdOn(Object date) {
    return 'Created on $date';
  }

  @override
  String currencies(Object count) {
    return '$count currencies';
  }

  @override
  String currenciesCount(Object count) {
    return '$count currencies';
  }

  @override
  String createdDate(Object date) {
    return 'Created: $date';
  }

  @override
  String get sortByLabel => 'Sort by:';

  @override
  String get selectPreset => 'Select';

  @override
  String get deletePresetAction => 'Delete';

  @override
  String get deletePresetTitle => 'Delete Preset';

  @override
  String get deletePresetConfirm => 'Are you sure you want to delete this preset?';

  @override
  String get presetDeletedSuccess => 'Preset deleted';

  @override
  String get errorLabel => 'Error:';

  @override
  String get fetchTimeout => 'Fetch Timeout';

  @override
  String get fetchTimeoutDesc => 'Set timeout for currency rate fetching (5-20 seconds)';

  @override
  String fetchTimeoutSeconds(Object seconds) {
    return '${seconds}s';
  }

  @override
  String get fetchRetryIncomplete => 'Retry when incomplete';

  @override
  String get fetchRetryIncompleteDesc => 'Automatically retry failed/timeout currencies during fetch';

  @override
  String fetchRetryTimes(int times) {
    return '$times retries';
  }

  @override
  String get fetchingRates => 'Fetching Currency Rates';

  @override
  String fetchingProgress(Object completed, Object total) {
    return 'Fetching progress: $completed/$total';
  }

  @override
  String timeRemaining(Object seconds) {
    return 'Time remaining: ${seconds}s';
  }

  @override
  String get fetchingStatus => 'Status';

  @override
  String fetchingCurrency(Object currency) {
    return 'Fetching $currency...';
  }

  @override
  String get fetchComplete => 'Fetch Complete';

  @override
  String get fetchCancelled => 'Fetch Cancelled';

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

  @override
  String get skipAnimation => 'Skip Animation';

  @override
  String get skipAnimationDesc => 'Disable animation for faster results';

  @override
  String get cacheTypeTextTemplates => 'Text Templates';

  @override
  String get cacheTypeTextTemplatesDesc => 'Saved text templates and content';

  @override
  String get cacheTypeAppSettings => 'App Settings';

  @override
  String get cacheTypeAppSettingsDesc => 'Theme, language, and user preferences';

  @override
  String get cacheTypeRandomGenerators => 'Random Generators';

  @override
  String get cacheTypeRandomGeneratorsDesc => 'Generation history and settings';

  @override
  String get saveGenerationHistory => 'Save Generation History';

  @override
  String get saveGenerationHistoryDesc => 'Remember and display history of generated items';

  @override
  String get generationHistory => 'Generation History';

  @override
  String get generatedAt => 'Generated at';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get noHistoryMessage => 'Generate some random results to see them here';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get calculationHistory => 'Calculation History';

  @override
  String get noCalculationHistory => 'No calculation history yet';

  @override
  String get saveCalculationHistory => 'Save Calculation History';

  @override
  String get saveCalculationHistoryDesc => 'Remember and display history of calculations';

  @override
  String get typeConfirmToProceed => 'Type \"confirm\" to proceed:';

  @override
  String get toolsShortcuts => 'Tools & Shortcuts';

  @override
  String get displayArrangeTools => 'Display and arrange tools';

  @override
  String get displayArrangeToolsDesc => 'Control which tools are visible and their order';

  @override
  String get manageToolVisibility => 'Manage Tool Visibility and Order';

  @override
  String get dragToReorder => 'Drag to reorder tools';

  @override
  String get allToolsHidden => 'All tools are hidden';

  @override
  String get allToolsHiddenDesc => 'Please enable at least one tool to continue using the application';

  @override
  String get enableAtLeastOneTool => 'Please enable at least one tool';

  @override
  String get toolVisibilityChanged => 'Tool visibility has been updated';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get manageQuickActions => 'Manage Quick Actions';

  @override
  String get manageQuickActionsDesc => 'Configure shortcuts for quick access to tools';

  @override
  String get quickActionsDialogTitle => 'Quick Actions';

  @override
  String get quickActionsDialogDesc => 'Select up to 4 tools for quick access via app icon or taskbar';

  @override
  String get quickActionsLimit => 'Maximum 4 quick actions allowed';

  @override
  String get quickActionsLimitReached => 'You can only select up to 4 tools for quick actions';

  @override
  String get clearAllQuickActions => 'Clear All';

  @override
  String get quickActionsCleared => 'Quick actions cleared';

  @override
  String get quickActionsUpdated => 'Quick actions updated';

  @override
  String get quickActionsInfo => 'Quick Actions';

  @override
  String get selectUpTo4Tools => 'Select up to 4 tools for quick access.';

  @override
  String get quickActionsEnableDesc => 'Quick actions will appear when you long-press the app icon on Android or right-click the taskbar icon on Windows.';

  @override
  String get quickActionsEnableDescMobile => 'Quick actions will appear when you long-press the app icon (Android/iOS only).';

  @override
  String selectedCount(int current, int max) {
    return 'Selected: $current of $max';
  }

  @override
  String get maxQuickActionsReached => 'Maximum 4 quick actions reached';

  @override
  String get clearAll => 'Clear All';

  @override
  String get converterTools => 'Converter Tools';

  @override
  String get converterToolsDesc => 'Convert between different units and systems';

  @override
  String get calculatorTools => 'Calculator Tools';

  @override
  String get calculatorToolsDesc => 'Specialized calculators for health, finance, and more';

  @override
  String get lengthConverter => 'Length Converter';

  @override
  String get temperatureConverter => 'Temperature Converter';

  @override
  String get volumeConverter => 'Volume Converter';

  @override
  String get areaConverter => 'Area Converter';

  @override
  String get speedConverter => 'Speed Converter';

  @override
  String get timeConverter => 'Time Converter';

  @override
  String get dataConverter => 'Data Storage Converter';

  @override
  String get numberSystemConverter => 'Number System Converter';

  @override
  String get tables => 'Tables';

  @override
  String get tableView => 'Table View';

  @override
  String get listView => 'List View';

  @override
  String get customizeUnits => 'Customize Units';

  @override
  String get visibleUnits => 'Visible Units';

  @override
  String get selectUnitsToShow => 'Select units to display';

  @override
  String get enterValue => 'Enter value';

  @override
  String get conversionResults => 'Conversion Results';

  @override
  String get meters => 'Meters';

  @override
  String get kilometers => 'Kilometers';

  @override
  String get centimeters => 'Centimeters';

  @override
  String get millimeters => 'Millimeters';

  @override
  String get inches => 'Inches';

  @override
  String get feet => 'Feet';

  @override
  String get yards => 'Yards';

  @override
  String get miles => 'Miles';

  @override
  String get grams => 'Grams';

  @override
  String get kilograms => 'Kilograms';

  @override
  String get pounds => 'Pounds';

  @override
  String get ounces => 'Ounces';

  @override
  String get tons => 'Tons';

  @override
  String get celsius => 'Celsius';

  @override
  String get fahrenheit => 'Fahrenheit';

  @override
  String get kelvin => 'Kelvin';

  @override
  String get liters => 'Liters';

  @override
  String get milliliters => 'Milliliters';

  @override
  String get gallons => 'Gallons';

  @override
  String get quarts => 'Quarts';

  @override
  String get pints => 'Pints';

  @override
  String get cups => 'Cups';

  @override
  String get squareMeters => 'Square Meters';

  @override
  String get squareKilometers => 'Square Kilometers';

  @override
  String get squareFeet => 'Square Feet';

  @override
  String get squareInches => 'Square Inches';

  @override
  String get acres => 'Acres';

  @override
  String get hectares => 'Hectares';

  @override
  String get metersPerSecond => 'Meters per Second';

  @override
  String get kilometersPerHour => 'Kilometers per Hour';

  @override
  String get milesPerHour => 'Miles per Hour';

  @override
  String get knots => 'Knots';

  @override
  String get seconds => 'Seconds';

  @override
  String get minutes => 'Minutes';

  @override
  String get hours => 'Hours';

  @override
  String get days => 'Days';

  @override
  String get weeks => 'Weeks';

  @override
  String get months => 'Months';

  @override
  String get years => 'Years';

  @override
  String get bytes => 'Bytes';

  @override
  String get kilobytes => 'Kilobytes';

  @override
  String get megabytes => 'Megabytes';

  @override
  String get gigabytes => 'Gigabytes';

  @override
  String get terabytes => 'Terabytes';

  @override
  String get bits => 'Bits';

  @override
  String get decimal => 'Decimal (Base 10)';

  @override
  String get binary => 'Binary (Base 2)';

  @override
  String get octal => 'Octal (Base 8)';

  @override
  String get hexadecimal => 'Hexadecimal (Base 16)';

  @override
  String get usd => 'US Dollar';

  @override
  String get eur => 'Euro';

  @override
  String get gbp => 'British Pound';

  @override
  String get jpy => 'Japanese Yen';

  @override
  String get cad => 'Canadian Dollar';

  @override
  String get aud => 'Australian Dollar';

  @override
  String get vnd => 'Vietnamese Dong';

  @override
  String get currencyConverterDesc => 'Convert between different currencies with live exchange rates';

  @override
  String get lengthConverterDesc => 'Convert between different units of length';

  @override
  String get weightConverterDesc => 'Convert between force/weight units (N, kgf, lbf)';

  @override
  String get temperatureConverterDesc => 'Convert between different temperature scales';

  @override
  String get volumeConverterDesc => 'Convert between different units of volume';

  @override
  String get areaConverterDesc => 'Convert between area units (m², km², ha, acres, ft²)';

  @override
  String get speedConverterDesc => 'Convert between different units of speed';

  @override
  String get timeConverterDesc => 'Convert between different units of time';

  @override
  String get dataConverterDesc => 'Convert between different units of data storage';

  @override
  String get numberSystemConverterDesc => 'Convert between number systems (binary, decimal, hexadecimal, etc.)';

  @override
  String get fromUnit => 'From Unit';

  @override
  String get unit => 'Unit';

  @override
  String get value => 'Value';

  @override
  String get showAll => 'Show All';

  @override
  String get apply => 'Apply';

  @override
  String get bmiCalculator => 'BMI Calculator';

  @override
  String get bmiCalculatorDesc => 'Calculate Body Mass Index and health category';

  @override
  String get scientificCalculator => 'Scientific Calculator';

  @override
  String get scientificCalculatorDesc => 'Advanced calculator with trigonometric, logarithmic functions';

  @override
  String get graphingCalculator => 'Graphing Calculator';

  @override
  String get graphingCalculatorDesc => 'Plot and visualize mathematical functions';

  @override
  String get graphingCalculatorDetailedInfo => 'Graphing Calculator Information';

  @override
  String get graphingCalculatorOverview => 'Advanced mathematical function plotting and visualization tool';

  @override
  String get graphingKeyFeatures => 'Key Features';

  @override
  String get realTimePlotting => 'Real-time Plotting';

  @override
  String get realTimePlottingDesc => 'Instantly visualize functions as you type with smooth curve rendering';

  @override
  String get multipleFunction => 'Multiple Functions';

  @override
  String get multipleFunctionDesc => 'Plot and compare multiple functions simultaneously with color coding';

  @override
  String get interactiveControls => 'Interactive Controls';

  @override
  String get interactiveControlsDesc => 'Zoom, pan, and navigate the graph with intuitive touch and mouse controls';

  @override
  String get aspectRatioControl => 'Aspect Ratio Control';

  @override
  String get aspectRatioControlDesc => 'Customize X:Y axis scaling for optimal function visualization';

  @override
  String get functionHistory => 'Function History';

  @override
  String get functionHistoryDesc => 'Save and load function groups with automatic state preservation';

  @override
  String get mathExpressionSupport => 'Advanced Math Support';

  @override
  String get mathExpressionSupportDesc => 'Supports trigonometric, logarithmic, and polynomial functions';

  @override
  String get graphingHowToUse => 'How to Use';

  @override
  String get step1Graph => 'Step 1: Enter Function';

  @override
  String get step1GraphDesc => 'Type a mathematical function in the input field (e.g., x^2, sin(x), log(x))';

  @override
  String get step2Graph => 'Step 2: Plot Function';

  @override
  String get step2GraphDesc => 'Press Enter or tap the add button to plot the function on the graph';

  @override
  String get step3Graph => 'Step 3: Navigate Graph';

  @override
  String get step3GraphDesc => 'Use zoom controls, pan gestures, or adjust aspect ratio for better viewing';

  @override
  String get step4Graph => 'Step 4: Add More Functions';

  @override
  String get step4GraphDesc => 'Add multiple functions to compare and analyze their behaviors';

  @override
  String get graphingTips => 'Pro Tips';

  @override
  String get tip1Graph => 'Use parentheses for complex expressions: sin(x^2) instead of sin x^2';

  @override
  String get tip2Graph => 'Common functions: sin(x), cos(x), tan(x), log(x), sqrt(x), abs(x)';

  @override
  String get tip3Graph => 'Use π and e constants: sin(π*x), e^x';

  @override
  String get tip4Graph => 'Pan by dragging the graph area with mouse or touch';

  @override
  String get tip5Graph => 'Save function groups to history for quick access later';

  @override
  String get tip6Graph => 'Toggle function visibility using the eye icon without removing them';

  @override
  String get tip7Graph => 'Use aspect ratio controls for specialized viewing (1:1 for circles, 5:1 for oscillations)';

  @override
  String get supportedFunctions => 'Supported Functions';

  @override
  String get basicOperations => 'Basic Operations';

  @override
  String get basicOperationsDesc => 'Addition (+), Subtraction (-), Multiplication (*), Division (/), Power (^)';

  @override
  String get trigonometricFunctions => 'Trigonometric Functions';

  @override
  String get trigonometricFunctionsDesc => 'sin(x), cos(x), tan(x) and their inverse functions';

  @override
  String get logarithmicFunctions => 'Logarithmic Functions';

  @override
  String get logarithmicFunctionsDesc => 'Natural logarithm log(x), exponential e^x';

  @override
  String get otherFunctions => 'Other Functions';

  @override
  String get otherFunctionsDesc => 'Square root sqrt(x), absolute value abs(x), polynomial functions';

  @override
  String get navigationControls => 'Navigation Controls';

  @override
  String get zoomControls => 'Zoom Controls';

  @override
  String get zoomControlsDesc => 'Use + and - buttons or pinch gestures to zoom in and out';

  @override
  String get panControls => 'Pan Controls';

  @override
  String get panControlsDesc => 'Drag the graph to move around and explore different areas';

  @override
  String get resetControls => 'Reset Controls';

  @override
  String get resetControlsDesc => 'Return to center or reset the entire plot to default state';

  @override
  String get aspectRatioDialog => 'Aspect Ratio';

  @override
  String get aspectRatioDialogDesc => 'Adjust X:Y axis scaling from 0.1:1 to 10:1 for optimal viewing';

  @override
  String get graphingPracticalApplications => 'Practical Applications';

  @override
  String get graphingPracticalApplicationsDesc => 'Useful for students learning algebra and calculus, visualizing function behavior, and exploring mathematical concepts through interactive graphs.';

  @override
  String get scientificCalculatorDetailedInfo => 'Scientific Calculator Information';

  @override
  String get scientificCalculatorOverview => 'Advanced scientific calculator with comprehensive mathematical functions';

  @override
  String get scientificKeyFeatures => 'Key Features';

  @override
  String get realTimeCalculation => 'Real-time Calculation';

  @override
  String get realTimeCalculationDesc => 'See instant preview results as you type expressions';

  @override
  String get comprehensiveFunctions => 'Comprehensive Functions';

  @override
  String get comprehensiveFunctionsDesc => 'Complete set of trigonometric, logarithmic, and algebraic functions';

  @override
  String get dualAngleModes => 'Dual Angle Modes';

  @override
  String get dualAngleModesDesc => 'Switch between radians and degrees for trigonometric calculations';

  @override
  String get secondaryFunctions => 'Secondary Functions';

  @override
  String get secondaryFunctionsDesc => 'Access extended functions with the 2nd button toggle';

  @override
  String get calculationHistoryDesc => 'Automatic saving and browsing of previous calculations';

  @override
  String get memoryOperations => 'Memory Operations';

  @override
  String get memoryOperationsDesc => 'Store and recall values with memory management functions';

  @override
  String get scientificHowToUse => 'How to Use';

  @override
  String get step1Scientific => 'Step 1: Enter Expression';

  @override
  String get step1ScientificDesc => 'Type numbers and use function buttons to build mathematical expressions';

  @override
  String get step2Scientific => 'Step 2: Use Functions';

  @override
  String get step2ScientificDesc => 'Access trigonometric, logarithmic, and algebraic functions from the keypad';

  @override
  String get step3Scientific => 'Step 3: Toggle Modes';

  @override
  String get step3ScientificDesc => 'Switch between radians/degrees and primary/secondary functions as needed';

  @override
  String get step4Scientific => 'Step 4: Use History - View and reuse previous calculations';

  @override
  String get step4ScientificDesc => 'Press = to calculate or see real-time preview while typing';

  @override
  String get scientificTips => 'Pro Tips';

  @override
  String get tip1Scientific => 'Use parentheses to ensure correct order of operations: (2+3)×4 = 20';

  @override
  String get tip2Scientific => 'Switch to DEG mode for degree calculations, RAD for radians';

  @override
  String get tip3Scientific => 'Use the 2nd button to access inverse functions: sin⁻¹, cos⁻¹, log⁻¹';

  @override
  String get tip4Scientific => 'Use memory functions (MS, MR, M+, M-) to store intermediate results';

  @override
  String get tip5Scientific => 'Double-tap numbers to select and copy results';

  @override
  String get tip6Scientific => 'Use EXP for scientific notation: 1.23E+5 = 123,000';

  @override
  String get tip7Scientific => 'Clear individual entries with C, or clear all with AC';

  @override
  String get basicArithmetic => 'Basic Arithmetic';

  @override
  String get trigonometricFunctionsScientific => 'Trigonometric Functions';

  @override
  String get logarithmicFunctionsScientific => 'Logarithmic Functions';

  @override
  String get algebraicFunctions => 'Algebraic Functions';

  @override
  String get scientificFunctionCategories => 'Function Categories';

  @override
  String get basicArithmeticDesc => 'Addition (+), Subtraction (-), Multiplication (*), Division (/)';

  @override
  String get trigonometricFunctionsScientificDesc => 'sin, cos, tan and their inverse functions (asin, acos, atan)';

  @override
  String get logarithmicFunctionsScientificDesc => 'Natural log (ln), common log (log), exponential (exp, eˣ, 10ˣ)';

  @override
  String get algebraicFunctionsDesc => 'Powers (x², x³, xʸ), roots (√, ∛), factorial (n!), absolute value (|x|)';

  @override
  String get angleMode => 'Angle Mode';

  @override
  String get functionToggle => 'Function Toggle';

  @override
  String get memoryFunctions => 'Memory Functions';

  @override
  String get historyAccess => 'History Access';

  @override
  String get scientificCalculatorPracticalApplications => 'Practical Applications';

  @override
  String get scientificCalculatorPracticalApplicationsDesc => 'Helpful for students in mathematics and science courses, basic engineering calculations, and everyday problem-solving involving complex mathematical operations.';

  @override
  String cacheWithLogSize(String cacheSize, String logSize) {
    return 'Cache: $cacheSize (+$logSize log)';
  }

  @override
  String get scientificModeControls => 'Mode Controls';

  @override
  String get angleModeDesc => 'Toggle between Radians and Degrees for trigonometric calculations';

  @override
  String get functionToggleDesc => 'Press 2nd to switch between primary and secondary function sets';

  @override
  String get memoryFunctionsDesc => 'Store, recall, and manage values in calculator memory';

  @override
  String get historyAccessDesc => 'Browse previous calculations and reuse expressions';

  @override
  String get scientificPracticalApplications => 'Practical Applications';

  @override
  String get scientificPracticalApplicationsDesc => 'Helpful for students in mathematics and science courses, performing calculations that require trigonometric, logarithmic, and algebraic functions.';

  @override
  String get metric => 'Metric';

  @override
  String get imperial => 'Imperial';

  @override
  String get enterMeasurements => 'Enter your measurements';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get heightInches => 'Height (inches)';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get weightPounds => 'Weight (pounds)';

  @override
  String get yourBMI => 'Your BMI';

  @override
  String get bmiScale => 'BMI Scale';

  @override
  String get underweight => 'Underweight';

  @override
  String get normalWeight => 'Normal Weight';

  @override
  String get overweight => 'Overweight';

  @override
  String get obese => 'Obese';

  @override
  String get currencyFetchMode => 'Currency Rate Fetching';

  @override
  String get currencyFetchModeDesc => 'Choose how currency exchange rates are updated';

  @override
  String get fetchModeManual => 'Manual';

  @override
  String get fetchModeManualDesc => 'Only use cached rates, update manually by tapping refresh (limited to once every 6 hours)';

  @override
  String get fetchModeOnceADay => 'Once a day';

  @override
  String get fetchModeOnceADayDesc => 'Automatically fetch rates once per day';

  @override
  String get currencyFetchStatus => 'Currency Fetch Status';

  @override
  String get fetchStatusSummary => 'Fetch Status Summary';

  @override
  String get success => 'Success';

  @override
  String get failed => 'Failed';

  @override
  String get timeout => 'Timeout';

  @override
  String get static => 'Static';

  @override
  String get noCurrenciesInThisCategory => 'No currencies in this category';

  @override
  String get saveFeatureState => 'Save Feature State';

  @override
  String get saveFeatureStateDesc => 'Remember the state of features between app sessions';

  @override
  String get testCache => 'Test Cache';

  @override
  String get viewDataStatus => 'View Data Status';

  @override
  String retryAttempt(int current, int max) {
    return 'Retry $current/$max';
  }

  @override
  String ratesUpdatedWithErrors(int errorCount) {
    return 'Rates updated with $errorCount errors';
  }

  @override
  String get newRatesAvailable => 'New exchange rates are available. Would you like to fetch them now?';

  @override
  String get progressDialogInfo => 'This will show a progress dialog while fetching rates.';

  @override
  String get calculating => 'Calculating...';

  @override
  String get unknown => 'Unknown';

  @override
  String get logsManagement => 'App logs management and storage settings';

  @override
  String statusInfo(String info) {
    return 'Status: $info';
  }

  @override
  String get logsAvailable => 'Logs available';

  @override
  String get noTimeData => '--:--:--';

  @override
  String get fetchStatusTab => 'Fetch Status';

  @override
  String get currencyValueTab => 'Currency Value';

  @override
  String successfulCount(int count) {
    return 'Successful ($count)';
  }

  @override
  String failedCount(int count) {
    return 'Failed ($count)';
  }

  @override
  String timeoutCount(int count) {
    return 'Timeout ($count)';
  }

  @override
  String recentlyUpdatedCount(int count) {
    return 'Recently Updated ($count)';
  }

  @override
  String updatedCount(int count) {
    return 'Updated ($count)';
  }

  @override
  String staticCount(int count) {
    return 'Static ($count)';
  }

  @override
  String get noCurrenciesInCategory => 'No currencies in this category';

  @override
  String get updatedWithinLastHour => 'Updated within the last hour';

  @override
  String updatedDaysAgo(int days) {
    return 'Updated $days days ago';
  }

  @override
  String updatedHoursAgo(int hours) {
    return 'Updated $hours hours ago';
  }

  @override
  String get hasUpdateData => 'Has update data';

  @override
  String get usingStaticRates => 'Using static rates';

  @override
  String get scrollToTop => 'Scroll to Top';

  @override
  String get scrollToBottom => 'Scroll to Bottom';

  @override
  String get logActions => 'Log Actions';

  @override
  String get previousChunk => 'Previous Chunk';

  @override
  String get nextChunk => 'Next Chunk';

  @override
  String get loadAll => 'Load All';

  @override
  String get firstPart => 'First Part';

  @override
  String get lastPart => 'Last Part';

  @override
  String get largeFile => 'Large File';

  @override
  String get loadingLargeFile => 'Loading large file...';

  @override
  String get loadingLogContent => 'Loading log content...';

  @override
  String get largeFileDetected => 'Large file detected. Using optimized loading...';

  @override
  String get cacheTypeCalculatorTools => 'Calculator Tools';

  @override
  String get cacheTypeCalculatorToolsDesc => 'Calculation history, graphing calculator data, and settings';

  @override
  String get cacheTypeConverterTools => 'Converter Tools';

  @override
  String get cacheTypeConverterToolsDesc => 'Currency/length states, presets and exchange rates cache';

  @override
  String get cardName => 'Card Name';

  @override
  String get cardNameHint => 'Enter card name (max 20 characters)';

  @override
  String converterCardNameDefault(Object position) {
    return 'Card $position';
  }

  @override
  String unitSelectedStatus(Object count, Object max) {
    return 'Selected $count of $max';
  }

  @override
  String unitVisibleStatus(Object count) {
    return '$count units visible';
  }

  @override
  String get moveDown => 'Move Down';

  @override
  String get moveUp => 'Move Up';

  @override
  String get moveToFirst => 'Move to First';

  @override
  String get moveToLast => 'Move to Last';

  @override
  String get cardActions => 'Card Actions';

  @override
  String get lengthUnits => 'Length Units';

  @override
  String get angstroms => 'Angstroms';

  @override
  String get nanometers => 'Nanometers';

  @override
  String get microns => 'Microns';

  @override
  String get nauticalMiles => 'Nautical Miles';

  @override
  String get customizeLengthUnits => 'Customize Length Units';

  @override
  String get selectLengthUnits => 'Select length units to display';

  @override
  String get lengthConverterInfo => 'Length Converter Information';

  @override
  String get weightConverter => 'Weight Converter';

  @override
  String get weightConverterInfo => 'Weight Converter Info';

  @override
  String get customizeWeightUnits => 'Customize Weight Units';

  @override
  String get massConverter => 'Mass Converter';

  @override
  String get massConverterInfo => 'Mass Converter Info';

  @override
  String get massConverterDesc => 'Convert between mass units (kg, lb, oz)';

  @override
  String get customizeMassUnits => 'Customize Mass Units';

  @override
  String get availableUnits => 'Available Units';

  @override
  String get scientificNotation => 'Scientific notation supported for extreme values';

  @override
  String get dragging => 'Dragging...';

  @override
  String get editName => 'Edit name';

  @override
  String get editCurrencies => 'Edit currencies';

  @override
  String tableWith(int count) {
    return 'Table $count cards';
  }

  @override
  String get noUnitsSelected => 'No units selected';

  @override
  String get maximumSelectionExceeded => 'Maximum selection exceeded';

  @override
  String errorSavingPreset(String error) {
    return 'Error saving preset: $error';
  }

  @override
  String errorLoadingPresets(String error) {
    return 'Error loading presets: $error';
  }

  @override
  String get maximumSelectionReached => 'Maximum selection reached';

  @override
  String minimumSelectionRequired(int count) {
    return 'Minimum $count selection(s) required';
  }

  @override
  String get renamePreset => 'Rename Preset';

  @override
  String get rename => 'Rename';

  @override
  String get presetRenamedSuccessfully => 'Preset renamed successfully';

  @override
  String get chooseFromSavedPresets => 'Choose from your saved presets';

  @override
  String get currencyConverterDetailedInfo => 'Currency Converter - Detailed Information';

  @override
  String get currencyConverterOverview => 'This powerful currency converter allows you to convert between different currencies with live exchange rates.';

  @override
  String get keyFeatures => 'Key Features';

  @override
  String get multipleCards => 'Multiple Cards';

  @override
  String get multipleCardsDesc => 'Create multiple converter cards, each with its own set of currencies and amounts.';

  @override
  String get liveRatesDesc => 'Get real-time exchange rates from reliable financial sources.';

  @override
  String get customizeCurrenciesDesc => 'Choose which currencies to display and save custom presets.';

  @override
  String get dragAndDrop => 'Drag & Drop';

  @override
  String get dragAndDropDesc => 'Reorder your converter cards by dragging them.';

  @override
  String get cardAndTableView => 'Card & Table View';

  @override
  String get cardAndTableViewDesc => 'Switch between card view for easy use or table view for comparison.';

  @override
  String get stateManagement => 'State Management';

  @override
  String get stateManagementDesc => 'Your converter state is automatically saved and restored.';

  @override
  String get step1 => '1. Add Cards';

  @override
  String get step1Desc => 'Tap \'Add Card\' to create new converter cards.';

  @override
  String get step2 => '2. Enter Amount';

  @override
  String get step2Desc => 'Enter an amount in any currency field.';

  @override
  String get step3 => '3. Select Base Currency';

  @override
  String get step3Desc => 'Use the dropdown to select which currency you\'re converting from.';

  @override
  String get step4 => '4. View Results';

  @override
  String get step4Desc => 'See instant conversions to all other currencies in the card.';

  @override
  String get tips => 'Tips';

  @override
  String get tip1 => '• Tap the edit icon next to card names to rename them';

  @override
  String get tip2 => '• Use the currency icon to customize which currencies appear';

  @override
  String get tip3 => '• Save currency presets for quick access';

  @override
  String get tip4 => '• Check the status indicator for exchange rate freshness';

  @override
  String get tip5 => '• Use table view to compare multiple cards side by side';

  @override
  String get rateUpdate => 'Rate Updates';

  @override
  String get rateUpdateDesc => 'Exchange rates are updated based on your settings. Check Settings > Converter Tools to configure update frequency and retry behavior.';

  @override
  String poweredBy(String service) {
    return 'Powered by $service';
  }

  @override
  String exchangeRatesBy(String service) {
    return 'Exchange rates by $service';
  }

  @override
  String get dataAttribution => 'Data Attribution';

  @override
  String get apiProviderAttribution => 'Exchange rate data provided by ExchangeRate-API';

  @override
  String get rateLimitReached => 'Rate limit reached';

  @override
  String get rateLimitMessage => 'You can only fetch currency rates once every 6 hours. Please try again later.';

  @override
  String nextFetchAllowedIn(String timeRemaining) {
    return 'Next fetch allowed in: $timeRemaining';
  }

  @override
  String get rateLimitInfo => 'Rate limiting helps prevent API abuse and ensures service availability for everyone.';

  @override
  String get understood => 'Understood';

  @override
  String get focusMode => 'Focus Mode';

  @override
  String get focusModeEnabled => 'Focus mode enabled';

  @override
  String get focusModeDisabled => 'Focus mode disabled';

  @override
  String get enableFocusMode => 'Enable Focus Mode';

  @override
  String get disableFocusMode => 'Disable Focus Mode';

  @override
  String get focusModeDescription => 'Hide interface elements to focus on your conversions';

  @override
  String focusModeEnabledMessage(String exitInstruction) {
    return 'Focus mode activated. $exitInstruction';
  }

  @override
  String get focusModeDisabledMessage => 'Focus mode deactivated. All interface elements are now visible.';

  @override
  String get exitFocusModeDesktop => 'Tap the focus icon in the app bar to exit';

  @override
  String get exitFocusModeMobile => 'Zoom out or tap the focus icon to exit';

  @override
  String get zoomToEnterFocusMode => 'Zoom in to enter focus mode';

  @override
  String get zoomToExitFocusMode => 'Zoom out to exit focus mode';

  @override
  String get focusModeGesture => 'Use zoom gestures to toggle focus mode';

  @override
  String get focusModeButton => 'Use the focus button to toggle focus mode';

  @override
  String get focusModeHidesElements => 'Focus mode hides status widgets, add buttons, view mode buttons, and statistics';

  @override
  String get focusModeHelp => 'Focus Mode Help';

  @override
  String get focusModeHelpTitle => 'Focus Mode';

  @override
  String get focusModeHelpDescription => 'Focus mode helps you concentrate on your conversions by hiding non-essential interface elements.';

  @override
  String get focusModeHelpHidden => 'Hidden in Focus Mode:';

  @override
  String get focusModeHelpHiddenStatus => '• Status indicators and widgets';

  @override
  String get focusModeHelpHiddenButtons => '• Add card/row buttons';

  @override
  String get focusModeHelpHiddenViewMode => '• View mode toggle buttons (Card/Table)';

  @override
  String get focusModeHelpHiddenStats => '• Statistics and count information';

  @override
  String get focusModeHelpActivation => 'Activation:';

  @override
  String get focusModeHelpActivationDesktop => '• Desktop: Click the focus icon in the app bar';

  @override
  String get focusModeHelpActivationMobile => '• Mobile: Use zoom in gesture or tap focus icon';

  @override
  String get focusModeHelpDeactivation => 'Deactivation:';

  @override
  String get focusModeHelpDeactivationDesktop => '• Desktop: Click the focus icon again';

  @override
  String get focusModeHelpDeactivationMobile => '• Mobile: Use zoom out gesture or tap focus icon again';

  @override
  String get moreActions => 'More actions';

  @override
  String get moreOptions => 'More Options';

  @override
  String get lengthConverterDetailedInfo => 'Length Converter - Detailed Information';

  @override
  String get lengthConverterOverview => 'This precision length converter supports multiple units with high accuracy calculations for professional and scientific use.';

  @override
  String get precisionCalculations => 'Precision Calculations';

  @override
  String get precisionCalculationsDesc => 'High-precision arithmetic with up to 15 decimal places for scientific accuracy.';

  @override
  String get multipleUnits => 'Multiple Length Units';

  @override
  String get multipleUnitsDesc => 'Support for metric, imperial, and scientific units including nanometers to kilometers.';

  @override
  String get instantConversion => 'Instant Conversion';

  @override
  String get instantConversionDesc => 'Real-time conversion across all visible units as you type values.';

  @override
  String get customizableInterface => 'Customizable Interface';

  @override
  String get customizableInterfaceDesc => 'Hide or show specific units, arrange cards, and switch between views.';

  @override
  String get statePersistence => 'State Persistence:';

  @override
  String get statePersistenceDesc => 'Your settings and card configurations are saved automatically.';

  @override
  String get scientificNotationSupport => 'Scientific Notation';

  @override
  String get scientificNotationSupportDesc => 'Support for very large and very small values using scientific notation.';

  @override
  String get step1Length => 'Step 1: Add Cards';

  @override
  String get step1LengthDesc => 'Add multiple converter cards to work with different length values simultaneously.';

  @override
  String get step2Length => 'Step 2: Select Units';

  @override
  String get step2LengthDesc => 'Choose which length units to display by customizing each card\'s visible units.';

  @override
  String get step3Length => 'Step 3: Enter Values';

  @override
  String get step3LengthDesc => 'Type any length value and see instant conversions to all other units.';

  @override
  String get step4Length => 'Step 4: Organize Layout';

  @override
  String get step4LengthDesc => 'Drag cards to reorder, switch to table view, or use focus mode for distraction-free work.';

  @override
  String get tip1Length => '• Use scientific notation (1.5e6) for very large or small measurements';

  @override
  String get tip2Length => '• Double-tap a unit field to select all text for quick editing';

  @override
  String get tip3Length => '• Cards remember their individual unit selections and names';

  @override
  String get tip4Length => '• Table view is ideal for comparing multiple measurements at once';

  @override
  String get tip5Length => '• Focus mode hides distractions for concentrated conversion work';

  @override
  String get tip6Length => '• Use the search function to quickly find specific units in customization';

  @override
  String get lengthUnitRange => 'Supported Units Range';

  @override
  String get lengthUnitRangeDesc => 'From subatomic (angstroms) to astronomical (light years) measurements with precision maintained throughout.';

  @override
  String get weightConverterDetailedInfo => 'Weight Converter - Detailed Information';

  @override
  String get weightConverterOverview => 'This precision weight/force converter supports multiple unit systems with high accuracy calculations for engineering, physics, and scientific applications.';

  @override
  String get step1Weight => 'Step 1: Add Cards';

  @override
  String get step1WeightDesc => 'Add multiple converter cards to work with different force/weight values simultaneously.';

  @override
  String get step2Weight => 'Step 2: Select Units';

  @override
  String get step2WeightDesc => 'Choose which force/weight units to display by customizing each card\'s visible units.';

  @override
  String get step3Weight => 'Step 3: Enter Values';

  @override
  String get step3WeightDesc => 'Type any force/weight value and see instant conversions to all other units.';

  @override
  String get step4Weight => 'Step 4: Organize Layout';

  @override
  String get step4WeightDesc => 'Drag cards to reorder, switch to table view, or use focus mode for distraction-free work.';

  @override
  String get tip1Weight => '• Newton (N) is the base SI unit for force with highest precision';

  @override
  String get tip2Weight => '• Kilogram-force (kgf) represents gravitational force on 1 kg mass';

  @override
  String get tip3Weight => '• Use scientific notation for very large or small force values';

  @override
  String get tip4Weight => '• Dyne is useful for small forces in CGS system calculations';

  @override
  String get tip5Weight => '• Troy units are specialized for precious metals and jewelry';

  @override
  String get tip6Weight => '• Focus mode helps concentrate on complex force calculations';

  @override
  String get weightUnitCategories => 'Unit Categories';

  @override
  String get commonUnits => 'Common Units';

  @override
  String get commonUnitsWeightDesc => 'Newton (N), Kilogram-force (kgf), Pound-force (lbf) - most frequently used in engineering and physics.';

  @override
  String get lessCommonUnits => 'Less Common Units';

  @override
  String get lessCommonUnitsWeightDesc => 'Dyne (dyn), Kilopond (kp) - specialized scientific and technical applications.';

  @override
  String get uncommonUnits => 'Uncommon Units';

  @override
  String get uncommonUnitsWeightDesc => 'Ton-force (tf) - for very large force measurements in heavy industry.';

  @override
  String get specialUnits => 'Special Units';

  @override
  String get specialUnitsWeightDesc => 'Gram-force (gf), Troy pound-force - for precision measurements and precious metals.';

  @override
  String get practicalApplicationsWeightDesc => 'Useful for engineering calculations, physics experiments, and applications requiring force measurements.';

  @override
  String get practicalApplications => 'Practical Applications';

  @override
  String get practicalApplicationsDesc => 'Helpful for everyday measurements and unit conversions in various contexts.';

  @override
  String get massConverterDetailedInfo => 'Mass Converter - Detailed Information';

  @override
  String get massConverterOverview => 'This precise mass converter supports multiple unit systems with high accuracy calculations for scientific, medical, and commercial applications.';

  @override
  String get step1Mass => 'Step 1: Add Cards';

  @override
  String get step1MassDesc => 'Add multiple converter cards to work with different mass values simultaneously.';

  @override
  String get step2Mass => 'Step 2: Select Units';

  @override
  String get step2MassDesc => 'Choose which mass units to display from metric, imperial, troy, and apothecaries systems.';

  @override
  String get step3Mass => 'Step 3: Enter Values';

  @override
  String get step3MassDesc => 'Type any mass value and see instant conversions to all other units.';

  @override
  String get step4Mass => 'Step 4: Organize Layout';

  @override
  String get step4MassDesc => 'Drag cards to reorder, switch to table view, or use focus mode for distraction-free work.';

  @override
  String get tip1Mass => '• Use scientific notation (1.5e-12) for very small masses like atomic units';

  @override
  String get tip2Mass => '• Troy system is ideal for precious metals calculations';

  @override
  String get tip3Mass => '• Apothecaries system is used in pharmacy and medicine';

  @override
  String get tip4Mass => '• Table view is perfect for comparing multiple measurements';

  @override
  String get tip5Mass => '• Focus mode hides distractions for concentrated conversion work';

  @override
  String get tip6Mass => '• Use presets to save your favorite unit combinations';

  @override
  String get massUnitSystems => 'Supported Unit Systems';

  @override
  String get massUnitSystemsDesc => 'Metric (ng to tonnes), Imperial (grains to tons), Troy (precious metals), Apothecaries (pharmacy), and special units (carats, slugs, atomic mass units).';

  @override
  String get practicalApplicationsMassDesc => 'Useful for cooking measurements, basic scientific calculations, and everyday mass conversions.';

  @override
  String get areaConverterInfo => 'Area Converter Info';

  @override
  String get customizeAreaUnits => 'Customize Area Units';

  @override
  String get areaConverterDetailedInfo => 'Area Converter - Detailed Information';

  @override
  String get areaConverterOverview => 'This precision area converter supports multiple unit systems with high accuracy calculations for real estate, agriculture, engineering, and scientific applications.';

  @override
  String get step1Area => 'Step 1: Add Cards';

  @override
  String get step1AreaDesc => 'Add multiple converter cards to work with different area values simultaneously.';

  @override
  String get step2Area => 'Step 2: Select Units';

  @override
  String get step2AreaDesc => 'Choose which area units to display by customizing each card\'s visible units.';

  @override
  String get step3Area => 'Step 3: Enter Values';

  @override
  String get step3AreaDesc => 'Type any area value and see instant conversions to all other units.';

  @override
  String get step4Area => 'Step 4: Organize Layout';

  @override
  String get step4AreaDesc => 'Drag cards to reorder, switch to table view, or use focus mode for distraction-free work.';

  @override
  String get tip1Area => '• Square meter (m²) is the base SI unit for area with highest precision';

  @override
  String get tip2Area => '• Hectare is commonly used for large land areas and agriculture';

  @override
  String get tip3Area => '• Acre is standard in real estate and land measurement in the US';

  @override
  String get tip4Area => '• Use scientific notation for very large or small area values';

  @override
  String get tip5Area => '• Square feet and square inches are common in construction and design';

  @override
  String get tip6Area => '• Focus mode helps concentrate on complex area calculations';

  @override
  String get areaUnitCategories => 'Unit Categories';

  @override
  String get commonUnitsAreaDesc => 'Square meter (m²), Square kilometer (km²), Square centimeter (cm²) - most frequently used metric units.';

  @override
  String get lessCommonUnitsAreaDesc => 'Hectare (ha), Acre (ac), Square foot (ft²), Square inch (in²) - specialized applications in agriculture and construction.';

  @override
  String get uncommonUnitsAreaDesc => 'Square yard (yd²), Square mile (mi²), Rood - for specific regional or historical measurements.';

  @override
  String get practicalApplicationsAreaDesc => 'Helpful for home improvement projects, gardening, and basic area calculations.';

  @override
  String get timeConverterDetailedInfo => 'Time Converter - Detailed Information';

  @override
  String get timeConverterOverview => 'Comprehensive time unit conversion with precision calculations and multiple unit support.';

  @override
  String get step1Time => 'Step 1: Select Time Units';

  @override
  String get step1TimeDesc => 'Choose from seconds, minutes, hours, days, weeks, months, years, and specialized units like milliseconds and nanoseconds.';

  @override
  String get step2Time => 'Step 2: Enter Time Value';

  @override
  String get step2TimeDesc => 'Input the time duration you want to convert. Supports decimal values and scientific notation for precise calculations.';

  @override
  String get step3Time => 'Step 3: View Conversions';

  @override
  String get step3TimeDesc => 'See instant conversions across all selected time units with high precision calculations.';

  @override
  String get step4Time => 'Step 4: Customize & Save';

  @override
  String get step4TimeDesc => 'Add multiple cards, customize visible units, and save your preferred layout for future use.';

  @override
  String get tip1Time => '• Use scientific notation for very small or large time values';

  @override
  String get tip2Time => '• Milliseconds and nanoseconds are perfect for technical calculations';

  @override
  String get tip3Time => '• Years and months use average values for consistency';

  @override
  String get tip4Time => '• Add multiple cards to compare different time scales';

  @override
  String get tip5Time => '• Customize visible units to show only what you need';

  @override
  String get tip6Time => '• Focus mode helps concentrate on complex time calculations';

  @override
  String get timeUnitSystems => 'Time Unit Systems';

  @override
  String get timeUnitSystemsDesc => 'Supports standard time units (s, min, h, d, wk, mo, yr), precision units (ms, μs, ns), and extended units (decades, centuries, millennia) for comprehensive time measurement across all scales.';

  @override
  String get practicalApplicationsTimeDesc => 'Useful for scheduling, time zone conversions, and everyday time calculations.';

  @override
  String get volumeConverterDetailedInfo => 'Volume Converter - Detailed Information';

  @override
  String get volumeConverterOverview => 'This precision volume converter supports multiple unit systems with high accuracy calculations for cooking, chemistry, engineering, and scientific applications.';

  @override
  String get step1Volume => 'Step 1: Add Cards';

  @override
  String get step1VolumeDesc => 'Add multiple converter cards to work with different volume values simultaneously.';

  @override
  String get step2Volume => 'Step 2: Select Units';

  @override
  String get step2VolumeDesc => 'Choose which volume units to display from metric, imperial, and US systems.';

  @override
  String get step3Volume => 'Step 3: Enter Values';

  @override
  String get step3VolumeDesc => 'Type any volume value and see instant conversions to all other units.';

  @override
  String get step4Volume => 'Step 4: Organize Layout';

  @override
  String get step4VolumeDesc => 'Drag cards to reorder, switch to table view, or use focus mode for distraction-free work.';

  @override
  String get tip1Volume => '• Cubic meter (m³) is the base SI unit for volume with highest precision';

  @override
  String get tip2Volume => '• Liter is commonly used for liquid measurements in everyday applications';

  @override
  String get tip3Volume => '• Milliliter and cubic centimeter are equivalent and interchangeable';

  @override
  String get tip4Volume => '• US and UK gallons are different units, choose carefully';

  @override
  String get tip5Volume => '• Use scientific notation for very large or small volume values';

  @override
  String get tip6Volume => '• Focus mode helps concentrate on complex volume calculations';

  @override
  String get volumeUnitCategories => 'Unit Categories';

  @override
  String get commonUnitsVolumeDesc => 'Cubic meter (m³), Liter (L), Milliliter (mL) - most frequently used metric units.';

  @override
  String get lessCommonUnitsVolumeDesc => 'Gallon (US/UK), Cubic foot (ft³), Quart, Pint - imperial and US customary units.';

  @override
  String get uncommonUnitsVolumeDesc => 'Hectoliter (hL), Barrel (bbl), Cup, Fluid ounce - specialized applications.';

  @override
  String get specialUnitsVolumeDesc => 'Cubic centimeter (cm³), Cubic inch (in³), Cubic yard (yd³) - engineering and construction units.';

  @override
  String get practicalApplicationsVolumeDesc => 'Helpful for cooking, baking, and basic volume measurements.';

  @override
  String get volumeConverterInfo => 'Volume Converter Information';

  @override
  String get customizeVolumeUnits => 'Customize Volume Units';

  @override
  String get selectVolumeUnits => 'Select volume units to display';

  @override
  String get volumeUnits => 'Volume Units';

  @override
  String get cubicMeter => 'Cubic Meter';

  @override
  String get liter => 'Liter';

  @override
  String get milliliter => 'Milliliter';

  @override
  String get cubicCentimeter => 'Cubic Centimeter';

  @override
  String get hectoliter => 'Hectoliter';

  @override
  String get gallonUS => 'Gallon (US)';

  @override
  String get gallonUK => 'Gallon (UK)';

  @override
  String get quartUS => 'Quart (US)';

  @override
  String get pintUS => 'Pint (US)';

  @override
  String get cup => 'Cup';

  @override
  String get fluidOunceUS => 'Fluid Ounce (US)';

  @override
  String get cubicInch => 'Cubic Inch';

  @override
  String get cubicFoot => 'Cubic Foot';

  @override
  String get cubicYard => 'Cubic Yard';

  @override
  String get barrel => 'Barrel (Oil)';

  @override
  String get numberSystemConverterDetailedInfo => 'Number System Converter - Detailed Information';

  @override
  String get numberSystemConverterOverview => 'This precision number system converter supports multiple base systems with high accuracy calculations for programming, computer science, and mathematical applications.';

  @override
  String get step1NumberSystem => 'Step 1: Add Cards';

  @override
  String get step1NumberSystemDesc => 'Add multiple converter cards to work with different number base values simultaneously.';

  @override
  String get step2NumberSystem => 'Step 2: Select Bases';

  @override
  String get step2NumberSystemDesc => 'Choose which number bases to display from binary, decimal, hexadecimal, and other systems.';

  @override
  String get step3NumberSystem => 'Step 3: Enter Values';

  @override
  String get step3NumberSystemDesc => 'Type any number value and see instant conversions to all other base systems.';

  @override
  String get step4NumberSystem => 'Step 4: Organize Layout';

  @override
  String get step4NumberSystemDesc => 'Drag cards to reorder, switch to table view, or use focus mode for distraction-free work.';

  @override
  String get tip1NumberSystem => '• Decimal (Base 10) is the standard counting system with highest precision';

  @override
  String get tip2NumberSystem => '• Binary (Base 2) is fundamental for computer science and digital electronics';

  @override
  String get tip3NumberSystem => '• Hexadecimal (Base 16) is commonly used in programming and memory addressing';

  @override
  String get tip4NumberSystem => '• Octal (Base 8) was historically important in computing systems';

  @override
  String get tip5NumberSystem => '• Base 32 and Base 64 are used for data encoding and transmission';

  @override
  String get tip6NumberSystem => '• Focus mode helps concentrate on complex base calculations';

  @override
  String get numberSystemUnitCategories => 'Base Systems';

  @override
  String get commonBasesDesc => 'Binary (Base 2), Decimal (Base 10), Hexadecimal (Base 16) - most frequently used in computing and mathematics.';

  @override
  String get lessCommonBasesDesc => 'Octal (Base 8), Base 32, Base 64 - specialized applications in programming and data encoding.';

  @override
  String get uncommonBasesDesc => 'Base 128, Base 256 - for advanced data representation and specialized algorithms.';

  @override
  String get practicalApplicationsNumberSystemDesc => 'Useful for basic programming, learning number systems, and simple base conversions.';

  @override
  String get numberSystemConverterInfo => 'Number System Converter Information';

  @override
  String get customizeNumberSystemBases => 'Customize Number System Bases';

  @override
  String get selectNumberSystemBases => 'Select number bases to display';

  @override
  String get numberSystemBases => 'Number Bases';

  @override
  String get base32 => 'Base 32';

  @override
  String get base64 => 'Base 64';

  @override
  String get base128 => 'Base 128';

  @override
  String get base256 => 'Base 256';

  @override
  String get speedConverterDetailedInfo => 'Speed Converter - Detailed Information';

  @override
  String get speedConverterOverview => 'This precision speed converter supports multiple unit systems with high accuracy calculations for automotive, aviation, maritime, and scientific applications.';

  @override
  String get step1Speed => 'Step 1: Add Cards';

  @override
  String get step1SpeedDesc => 'Add multiple converter cards to work with different speed values simultaneously.';

  @override
  String get step2Speed => 'Step 2: Select Units';

  @override
  String get step2SpeedDesc => 'Choose which speed units to display from metric, imperial, maritime, and aviation systems.';

  @override
  String get step3Speed => 'Step 3: Enter Values';

  @override
  String get step3SpeedDesc => 'Type any speed value and see instant conversions to all other units.';

  @override
  String get step4Speed => 'Step 4: Organize Layout';

  @override
  String get step4SpeedDesc => 'Drag cards to reorder, switch to table view, or use focus mode for distraction-free work.';

  @override
  String get tip1Speed => '• Meters per second (m/s) is the base SI unit for speed with highest precision';

  @override
  String get tip2Speed => '• Kilometers per hour (km/h) is commonly used for vehicle speeds';

  @override
  String get tip3Speed => '• Miles per hour (mph) is standard in the US for road speeds';

  @override
  String get tip4Speed => '• Knots are standard for maritime and aviation navigation';

  @override
  String get tip5Speed => '• Mach number represents speed relative to sound (343 m/s at sea level)';

  @override
  String get tip6Speed => '• Focus mode helps concentrate on complex speed calculations';

  @override
  String get speedUnitCategories => 'Unit Categories';

  @override
  String get multipleSpeedUnits => 'Multiple Speed Units';

  @override
  String get multipleSpeedUnitsDesc => 'Support for metric, imperial, maritime, and aviation units including m/s to Mach numbers.';

  @override
  String get speedUnitRange => 'Supported Speed Range';

  @override
  String get speedUnitRangeDesc => 'From millimeters per second to supersonic speeds (Mach numbers) with precision maintained throughout the range.';

  @override
  String get commonUnitsSpeedDesc => 'Kilometers per hour (km/h), Meters per second (m/s), Miles per hour (mph) - most frequently used for ground transportation.';

  @override
  String get lessCommonUnitsSpeedDesc => 'Knots (kn), Feet per second (ft/s) - specialized for maritime, aviation, and ballistics applications.';

  @override
  String get uncommonUnitsSpeedDesc => 'Mach (M) - for supersonic and hypersonic speeds in aerospace applications.';

  @override
  String get practicalApplicationsSpeedDesc => 'Helpful for travel planning, sports activities, and basic speed conversions.';

  @override
  String get speedConverterInfo => 'Speed Converter Information';

  @override
  String get customizeSpeedUnits => 'Customize Speed Units';

  @override
  String get selectSpeedUnits => 'Select speed units to display';

  @override
  String get speedUnits => 'Speed Units';

  @override
  String get temperatureConverterDetailedInfo => 'Temperature Converter - Detailed Information';

  @override
  String get temperatureConverterOverview => 'This precision temperature converter supports multiple temperature scales with high accuracy calculations for scientific, engineering, cooking, and everyday applications.';

  @override
  String get step1Temperature => 'Step 1: Add Cards';

  @override
  String get step1TemperatureDesc => 'Add multiple converter cards to work with different temperature values simultaneously.';

  @override
  String get step2Temperature => 'Step 2: Select Scales';

  @override
  String get step2TemperatureDesc => 'Choose which temperature scales to display from Celsius, Fahrenheit, Kelvin, and other systems.';

  @override
  String get step3Temperature => 'Step 3: Enter Values';

  @override
  String get step3TemperatureDesc => 'Type any temperature value and see instant conversions to all other scales.';

  @override
  String get step4Temperature => 'Step 4: Organize Layout';

  @override
  String get step4TemperatureDesc => 'Drag cards to reorder, switch to table view, or use focus mode for distraction-free work.';

  @override
  String get tip1Temperature => '• Celsius (°C) is the most widely used temperature scale globally';

  @override
  String get tip2Temperature => '• Fahrenheit (°F) is commonly used in the United States';

  @override
  String get tip3Temperature => '• Kelvin (K) is the absolute temperature scale used in science';

  @override
  String get tip4Temperature => '• Rankine (°R) is the absolute Fahrenheit scale';

  @override
  String get tip5Temperature => '• Réaumur (°Ré) is historically used in some European countries';

  @override
  String get tip6Temperature => '• Focus mode helps concentrate on complex temperature calculations';

  @override
  String get temperatureUnitCategories => 'Temperature Scale Categories';

  @override
  String get temperatureCommonUnits => 'Common Scales';

  @override
  String get temperatureCommonUnitsDesc => 'Celsius (°C), Fahrenheit (°F) - most frequently used for weather, cooking, and everyday temperature measurements.';

  @override
  String get temperatureLessCommonUnits => 'Scientific Scale';

  @override
  String get temperatureLessCommonUnitsDesc => 'Kelvin (K) - absolute temperature scale used in scientific and engineering applications.';

  @override
  String get temperatureRareUnits => 'Specialized Scales';

  @override
  String get temperatureRareUnitsDesc => 'Rankine (°R), Réaumur (°Ré), Delisle (°De) - historical and specialized temperature scales for specific applications.';

  @override
  String get temperaturePracticalApplicationsDesc => 'Useful for cooking, weather understanding, and basic temperature conversions.';

  @override
  String get temperatureConverterInfo => 'Temperature Converter Information';

  @override
  String get customizeTemperatureUnits => 'Customize Temperature Scales';

  @override
  String get selectTemperatureUnits => 'Select temperature scales to display';

  @override
  String get temperatureUnits => 'Temperature Scales';

  @override
  String get dataConverterDetailedInfo => 'Data Storage Converter - Detailed Information';

  @override
  String get dataConverterOverview => 'This precision data storage converter supports multiple data units with high accuracy calculations for computer science, IT management, file handling, and digital storage applications.';

  @override
  String get step1Data => 'Step 1: Add Cards';

  @override
  String get step1DataDesc => 'Add multiple converter cards to work with different data storage values simultaneously.';

  @override
  String get step2Data => 'Step 2: Select Units';

  @override
  String get step2DataDesc => 'Choose which data storage units to display from bytes, kilobytes, gigabytes, and other systems.';

  @override
  String get step3Data => 'Step 3: Enter Values';

  @override
  String get step3DataDesc => 'Type any data storage value and see instant conversions to all other units.';

  @override
  String get step4Data => 'Step 4: Organize Layout';

  @override
  String get step4DataDesc => 'Drag cards to reorder, switch to table view, or use focus mode for distraction-free work.';

  @override
  String get tip1Data => '• Byte (B) is the fundamental unit of digital information storage';

  @override
  String get tip2Data => '• Kilobyte (KB), Megabyte (MB), Gigabyte (GB) are standard for file sizes';

  @override
  String get tip3Data => '• Terabyte (TB) and Petabyte (PB) are used for large-scale storage systems';

  @override
  String get tip4Data => '• Bit units (Kbit, Mbit, Gbit) are commonly used for network speeds';

  @override
  String get tip5Data => '• Binary prefixes (1024-based) provide more accurate computer calculations';

  @override
  String get tip6Data => '• Focus mode helps concentrate on complex data storage calculations';

  @override
  String get dataUnitCategories => 'Data Storage Unit Categories';

  @override
  String get dataCommonUnits => 'Common Units';

  @override
  String get dataCommonUnitsDesc => 'Kilobyte (KB), Megabyte (MB), Gigabyte (GB) - most frequently used storage units for everyday file sizes and device capacities.';

  @override
  String get dataLessCommonUnits => 'Large Storage Units';

  @override
  String get dataLessCommonUnitsDesc => 'Terabyte (TB), Petabyte (PB), and basic Byte (B) units for specialized storage applications and very large or very small data measurements.';

  @override
  String get dataRareUnits => 'Network Units';

  @override
  String get dataRareUnitsDesc => 'Bit, Kilobit (Kbit), Megabit (Mbit), Gigabit (Gbit) are primarily used for network speeds and data transmission rates.';

  @override
  String get dataPracticalApplicationsDesc => 'Helpful for understanding file sizes, storage needs, and basic data unit conversions.';

  @override
  String get dataConverterInfo => 'Data Storage Converter Information';

  @override
  String get customizeDataUnits => 'Customize Data Storage Units';

  @override
  String get selectDataUnits => 'Select data storage units to display';

  @override
  String get dataUnits => 'Data Storage Units';

  @override
  String get drafts => 'Drafts';

  @override
  String get noDraftsYet => 'No drafts yet';

  @override
  String get createDraftsHint => 'Drafts are temporary saves of your work. They\'re automatically created when you exit editing without saving.';

  @override
  String get draftSaved => 'Draft saved';

  @override
  String get draftDeleted => 'Draft deleted';

  @override
  String get saveDraft => 'Save Draft';

  @override
  String get stayHere => 'Stay Here';

  @override
  String get exitWithoutSaving => 'Exit Without Saving';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage => 'You have unsaved changes. What would you like to do?';

  @override
  String get continueDraft => 'Continue Draft';

  @override
  String get publishDraft => 'Publish Draft';

  @override
  String get deleteDraft => 'Delete Draft';

  @override
  String get confirmDeleteDraft => 'Delete Draft?';

  @override
  String get confirmDeleteDraftMessage => 'Are you sure you want to delete this draft? This action cannot be undone.';

  @override
  String get draftPublished => 'Draft published as template';

  @override
  String get newDraft => 'New Draft';

  @override
  String get editDraft => 'Edit Draft';

  @override
  String draftCreatedOn(Object date) {
    return 'Created on $date';
  }

  @override
  String draftUpdatedOn(Object date) {
    return 'Updated on $date';
  }

  @override
  String get autoSaved => 'Auto-saved';

  @override
  String get viewDrafts => 'View Drafts';

  @override
  String get manageDrafts => 'Manage Drafts';

  @override
  String get draftsExpireAfter => 'Drafts expire after 7 days';

  @override
  String get expiredDraft => 'Expired';

  @override
  String draftCount(Object count) {
    return '$count drafts';
  }

  @override
  String get graphingFunction => 'f(x) = ';

  @override
  String get enterFunction => 'Enter function (e.g., x^2, sin(x), etc.)';

  @override
  String get plot => 'Plot';

  @override
  String get aspectRatio => 'Aspect Ratio';

  @override
  String get aspectRatioXY => 'Aspect Ratio (X:Y)';

  @override
  String currentRatio(String ratio) {
    return 'Current ratio: $ratio:1';
  }

  @override
  String get resetPlot => 'Reset Plot';

  @override
  String get resetZoom => 'Reset Zoom';

  @override
  String get zoomIn => 'Zoom In';

  @override
  String get zoomOut => 'Zoom Out';

  @override
  String get returnToCenter => 'Return to Center';

  @override
  String get panning => 'Panning';

  @override
  String get equalXYRatio => 'Equal X:Y ratio';

  @override
  String yAxisWiderThanX(String ratio) {
    return 'Y-axis will be $ratio× wider than X-axis';
  }

  @override
  String xAxisWiderThanY(String ratio) {
    return 'X-axis will be $ratio× wider than Y-axis';
  }

  @override
  String invalidFunction(String error) {
    return 'Invalid function: $error';
  }

  @override
  String get enterFunctionToPlot => 'Enter a function to plot';

  @override
  String functionLabel(int number) {
    return 'Function $number';
  }

  @override
  String get reset => 'Reset';

  @override
  String get graphPanel => 'Graph';

  @override
  String get functionsPanel => 'Functions';

  @override
  String get historyPanel => 'History';

  @override
  String get activeFunctions => 'Active Functions';

  @override
  String get noActiveFunctions => 'No active functions';

  @override
  String get addFunction => 'Add Function';

  @override
  String get removeFunction => 'Remove Function';

  @override
  String get toggleFunction => 'Toggle Function';

  @override
  String get functionVisible => 'Function visible';

  @override
  String get functionHidden => 'Function hidden';

  @override
  String get functionInputHelp => 'Function Input Help';

  @override
  String get functionInputHelpDesc => 'Get help with mathematical function syntax';

  @override
  String get commonFunctions => 'Common Functions';

  @override
  String get polynomialFunctions => 'Polynomial Functions';

  @override
  String get insertFunction => 'Insert';

  @override
  String get functionSyntaxError => 'Invalid function syntax';

  @override
  String get functionSyntaxErrorDesc => 'Please check your function syntax and try again';

  @override
  String get advancedFunctions => 'Advanced Functions';

  @override
  String get askBeforeLoadingHistory => 'Ask before loading history';

  @override
  String get askBeforeLoadingHistoryDesc => 'Show confirmation dialog when loading function groups from history';

  @override
  String get rememberCalculationHistory => 'Remember calculation history';

  @override
  String get rememberCalculationHistoryDesc => 'Save function groups to history for later use';

  @override
  String get saveCurrentToHistory => 'Save current group to history';

  @override
  String get loadHistoryGroup => 'Load History Group';

  @override
  String get saveCurrentGroupQuestion => 'Do you want to save the current function group to history?';

  @override
  String get dontAskAgain => 'Don\'t ask again';

  @override
  String get rememberChoice => 'Remember choice';

  @override
  String get info => 'Info';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get functionGroup => 'Function Group';

  @override
  String savedOn(String date) {
    return 'Saved on $date';
  }

  @override
  String functionsCount(int count) {
    return '$count functions';
  }

  @override
  String get editFunctionColor => 'Edit function color';

  @override
  String get selectColor => 'Select Color';

  @override
  String get noHistoryAvailable => 'No history available';

  @override
  String get removeFromHistory => 'Remove from history';

  @override
  String get selectedColor => 'Selected Color';

  @override
  String get predefinedColors => 'Predefined Colors';

  @override
  String get customColor => 'Custom Color';

  @override
  String get hue => 'Hue';

  @override
  String get saturation => 'Saturation';

  @override
  String get lightness => 'Lightness';

  @override
  String get debugCache => 'Debug Cache';

  @override
  String get deletingOldLogs => 'Deleting old logs...';

  @override
  String deletedOldLogFiles(int count) {
    return 'Deleted $count old log files';
  }

  @override
  String get noOldLogFilesToDelete => 'No old log files to delete';

  @override
  String errorDeletingLogs(String error) {
    return 'Error deleting logs: $error';
  }

  @override
  String get mobileCacheDebug => 'Mobile Cache Debug';

  @override
  String get runningCacheDiagnostics => 'Running cache diagnostics...';

  @override
  String get cacheDiagnosticsResults => 'Cache Diagnostics Results';

  @override
  String get cacheStatus => 'Cache Status:';

  @override
  String get reliability => 'Reliability';

  @override
  String get reliable => 'Reliable';

  @override
  String get unreliable => 'Unreliable';

  @override
  String get hasCache => 'Has Cache';

  @override
  String get currencyState => 'Currency State';

  @override
  String get lengthState => 'Length State';

  @override
  String get timeState => 'Time State';

  @override
  String get saved => 'Saved';

  @override
  String get defaultState => 'Default';

  @override
  String errorWithDetails(String details) {
    return 'Error: $details';
  }

  @override
  String get stateLoadingIssuesDetected => '⚠️ State Loading Issues Detected';

  @override
  String get stateLoadingIssuesDesc => 'This usually happens after app updates that change data structure.';

  @override
  String get clearAllStateData => 'Clear All State Data';

  @override
  String get clearingStateData => 'Clearing all converter state data...';

  @override
  String get clearingAllConverterStateData => 'Clearing all converter state data...';

  @override
  String get allStateDataCleared => 'All state data has been cleared. The app will restart to complete the process.';

  @override
  String failedToRunDiagnostics(String error) {
    return 'Failed to run diagnostics: $error';
  }

  @override
  String failedToClearStateData(String error) {
    return 'Failed to clear state data: $error';
  }

  @override
  String get stateDataClearedSuccess => 'All state data has been cleared. The app will restart to complete the process.';

  @override
  String get ok => 'OK';
}

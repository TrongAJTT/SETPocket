import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'SETPocket'**
  String get title;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @userInterface.
  ///
  /// In en, this message translates to:
  /// **'User Interface'**
  String get userInterface;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @cache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get cache;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @cacheDetails.
  ///
  /// In en, this message translates to:
  /// **'Cache Details'**
  String get cacheDetails;

  /// No description provided for @viewCacheDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewCacheDetails;

  /// No description provided for @cacheSize.
  ///
  /// In en, this message translates to:
  /// **'Cache Size'**
  String get cacheSize;

  /// No description provided for @cacheItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get cacheItems;

  /// No description provided for @clearAllCache.
  ///
  /// In en, this message translates to:
  /// **'Clear All Cache'**
  String get clearAllCache;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Application Logs'**
  String get logs;

  /// No description provided for @viewLogs.
  ///
  /// In en, this message translates to:
  /// **'View Logs'**
  String get viewLogs;

  /// No description provided for @clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// No description provided for @logRetention.
  ///
  /// In en, this message translates to:
  /// **'Log Retention'**
  String get logRetention;

  /// No description provided for @logRetentionDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String logRetentionDays(int days);

  /// No description provided for @logRetentionForever.
  ///
  /// In en, this message translates to:
  /// **'Keep forever'**
  String get logRetentionForever;

  /// No description provided for @logRetentionDesc.
  ///
  /// In en, this message translates to:
  /// **'Set how long to keep application logs before automatic deletion'**
  String get logRetentionDesc;

  /// No description provided for @logRetentionDescDetail.
  ///
  /// In en, this message translates to:
  /// **'Choose log retention period (5-30 days in 5-day intervals, or forever)'**
  String get logRetentionDescDetail;

  /// No description provided for @logRetentionAutoDelete.
  ///
  /// In en, this message translates to:
  /// **'Auto-delete after a period of time'**
  String get logRetentionAutoDelete;

  /// No description provided for @logManagement.
  ///
  /// In en, this message translates to:
  /// **'Log Management'**
  String get logManagement;

  /// No description provided for @logManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage application logs and retention settings'**
  String get logManagementDesc;

  /// No description provided for @logStatus.
  ///
  /// In en, this message translates to:
  /// **'Log Status'**
  String get logStatus;

  /// No description provided for @logsDesc.
  ///
  /// In en, this message translates to:
  /// **'Application log files and debug information'**
  String get logsDesc;

  /// No description provided for @dataAndStorage.
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get dataAndStorage;

  /// No description provided for @confirmClearCache.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear \"{cacheName}\" cache?'**
  String confirmClearCache(Object cacheName);

  /// No description provided for @confirmClearAllCache.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear ALL cache data? This will remove all saved templates but preserve your settings.'**
  String get confirmClearAllCache;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'{cacheName} cache cleared successfully'**
  String cacheCleared(Object cacheName);

  /// No description provided for @allCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'All cache cleared successfully'**
  String get allCacheCleared;

  /// No description provided for @errorClearingCache.
  ///
  /// In en, this message translates to:
  /// **'Error clearing cache: {error}'**
  String errorClearingCache(Object error);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @selectTool.
  ///
  /// In en, this message translates to:
  /// **'Select a tool from the sidebar'**
  String get selectTool;

  /// No description provided for @selectToolDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose a tool from the left sidebar to get started'**
  String get selectToolDesc;

  /// No description provided for @settingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Personalize your experience'**
  String get settingsDesc;

  /// No description provided for @random.
  ///
  /// In en, this message translates to:
  /// **'Random Generator'**
  String get random;

  /// No description provided for @randomDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate random passwords, numbers, dates, and more'**
  String get randomDesc;

  /// No description provided for @textTemplateGen.
  ///
  /// In en, this message translates to:
  /// **'Text Template Generator'**
  String get textTemplateGen;

  /// No description provided for @textTemplateGenDesc.
  ///
  /// In en, this message translates to:
  /// **'Create documents from templates. You can create reusable templates with fields like text, number, date.'**
  String get textTemplateGenDesc;

  /// No description provided for @editTemplate.
  ///
  /// In en, this message translates to:
  /// **'Edit Template'**
  String get editTemplate;

  /// No description provided for @createTemplate.
  ///
  /// In en, this message translates to:
  /// **'Create New Template'**
  String get createTemplate;

  /// No description provided for @contentTab.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get contentTab;

  /// No description provided for @structureTab.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get structureTab;

  /// No description provided for @templateTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Template Title *'**
  String get templateTitleLabel;

  /// No description provided for @templateTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter title for this template'**
  String get templateTitleHint;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @addDataField.
  ///
  /// In en, this message translates to:
  /// **'Add Data Field'**
  String get addDataField;

  /// No description provided for @addDataLoop.
  ///
  /// In en, this message translates to:
  /// **'Add Data Loop'**
  String get addDataLoop;

  /// No description provided for @fieldTypeText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get fieldTypeText;

  /// No description provided for @fieldTypeLargeText.
  ///
  /// In en, this message translates to:
  /// **'Large Text'**
  String get fieldTypeLargeText;

  /// No description provided for @fieldTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get fieldTypeNumber;

  /// No description provided for @fieldTypeDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get fieldTypeDate;

  /// No description provided for @fieldTypeTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get fieldTypeTime;

  /// No description provided for @fieldTypeDateTime.
  ///
  /// In en, this message translates to:
  /// **'DateTime'**
  String get fieldTypeDateTime;

  /// No description provided for @fieldTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Field title *'**
  String get fieldTitleLabel;

  /// No description provided for @fieldTitleHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Customer name'**
  String get fieldTitleHint;

  /// No description provided for @pleaseEnterFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter field title'**
  String get pleaseEnterFieldTitle;

  /// No description provided for @copyAndClose.
  ///
  /// In en, this message translates to:
  /// **'Copy and Close'**
  String get copyAndClose;

  /// No description provided for @insertAtCursor.
  ///
  /// In en, this message translates to:
  /// **'Insert at Cursor'**
  String get insertAtCursor;

  /// No description provided for @appendToEnd.
  ///
  /// In en, this message translates to:
  /// **'Append to End'**
  String get appendToEnd;

  /// No description provided for @loopTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Loop title *'**
  String get loopTitleLabel;

  /// No description provided for @loopTitleHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Product list'**
  String get loopTitleHint;

  /// No description provided for @pleaseFixDuplicateIds.
  ///
  /// In en, this message translates to:
  /// **'Please fix inconsistent duplicate IDs before saving'**
  String get pleaseFixDuplicateIds;

  /// No description provided for @errorSavingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Error saving template: {error}'**
  String errorSavingTemplate(Object error);

  /// No description provided for @templateContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Template Content *'**
  String get templateContentLabel;

  /// No description provided for @templateContentHint.
  ///
  /// In en, this message translates to:
  /// **'Enter template content and add data fields...'**
  String get templateContentHint;

  /// No description provided for @pleaseEnterTemplateContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter template content'**
  String get pleaseEnterTemplateContent;

  /// No description provided for @templateStructure.
  ///
  /// In en, this message translates to:
  /// **'Template Structure'**
  String get templateStructure;

  /// No description provided for @templateStructureOverview.
  ///
  /// In en, this message translates to:
  /// **'View an overview of fields and loops in your template.'**
  String get templateStructureOverview;

  /// No description provided for @textTemplatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get textTemplatesTitle;

  /// No description provided for @addNewTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add new template'**
  String get addNewTemplate;

  /// No description provided for @noTemplatesYet.
  ///
  /// In en, this message translates to:
  /// **'No templates yet'**
  String get noTemplatesYet;

  /// No description provided for @createTemplatesHint.
  ///
  /// In en, this message translates to:
  /// **'Create your first template to get started.'**
  String get createTemplatesHint;

  /// No description provided for @createNewTemplate.
  ///
  /// In en, this message translates to:
  /// **'Create new template'**
  String get createNewTemplate;

  /// No description provided for @exportToJson.
  ///
  /// In en, this message translates to:
  /// **'Export to JSON'**
  String get exportToJson;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeleteTemplateMsg.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String confirmDeleteTemplateMsg(Object title);

  /// No description provided for @templateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Template deleted.'**
  String get templateDeleted;

  /// No description provided for @errorDeletingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Error deleting template: {error}'**
  String errorDeletingTemplate(Object error);

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @usageGuide.
  ///
  /// In en, this message translates to:
  /// **'Usage Guide'**
  String get usageGuide;

  /// No description provided for @textTemplateToolIntro.
  ///
  /// In en, this message translates to:
  /// **'This tool helps you manage and use text templates efficiently.'**
  String get textTemplateToolIntro;

  /// No description provided for @helpCreateNewTemplate.
  ///
  /// In en, this message translates to:
  /// **'Create a new template using the + button.'**
  String get helpCreateNewTemplate;

  /// No description provided for @helpTapToUseTemplate.
  ///
  /// In en, this message translates to:
  /// **'Tap a template to use it.'**
  String get helpTapToUseTemplate;

  /// No description provided for @helpTapMenuForActions.
  ///
  /// In en, this message translates to:
  /// **'Tap the menu (⋮) for more actions.'**
  String get helpTapMenuForActions;

  /// No description provided for @textTemplateScreenHint.
  ///
  /// In en, this message translates to:
  /// **'Templates are saved locally on your device.'**
  String get textTemplateScreenHint;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @addTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add Template'**
  String get addTemplate;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManually;

  /// No description provided for @createTemplateFromScratch.
  ///
  /// In en, this message translates to:
  /// **'Create a template from scratch'**
  String get createTemplateFromScratch;

  /// No description provided for @addFromFile.
  ///
  /// In en, this message translates to:
  /// **'Add from file'**
  String get addFromFile;

  /// No description provided for @importTemplateFromJson.
  ///
  /// In en, this message translates to:
  /// **'Import multiple templates from JSON files'**
  String get importTemplateFromJson;

  /// No description provided for @templateImported.
  ///
  /// In en, this message translates to:
  /// **'Template imported successfully.'**
  String get templateImported;

  /// No description provided for @templatesImported.
  ///
  /// In en, this message translates to:
  /// **'Templates imported successfully.'**
  String templatesImported(Object count);

  /// No description provided for @importResults.
  ///
  /// In en, this message translates to:
  /// **'Import Results'**
  String get importResults;

  /// No description provided for @importSummary.
  ///
  /// In en, this message translates to:
  /// **'{successCount} successful, {failCount} failed'**
  String importSummary(Object failCount, Object successCount);

  /// No description provided for @successfulImports.
  ///
  /// In en, this message translates to:
  /// **'Successful imports ({count})'**
  String successfulImports(Object count);

  /// No description provided for @failedImports.
  ///
  /// In en, this message translates to:
  /// **'Failed imports ({count})'**
  String failedImports(Object count);

  /// No description provided for @noImportsAttempted.
  ///
  /// In en, this message translates to:
  /// **'No files were selected for import'**
  String get noImportsAttempted;

  /// No description provided for @invalidTemplateFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid template format: {error}'**
  String invalidTemplateFormat(Object error);

  /// No description provided for @errorImportingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Error importing template: {error}'**
  String errorImportingTemplate(Object error);

  /// No description provided for @copySuffix.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get copySuffix;

  /// No description provided for @templateCopied.
  ///
  /// In en, this message translates to:
  /// **'Template copied.'**
  String get templateCopied;

  /// No description provided for @errorCopyingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Error copying template: {error}'**
  String errorCopyingTemplate(Object error);

  /// No description provided for @saveTemplateAsJson.
  ///
  /// In en, this message translates to:
  /// **'Save template as JSON'**
  String get saveTemplateAsJson;

  /// No description provided for @templateExported.
  ///
  /// In en, this message translates to:
  /// **'Template exported to {path}'**
  String templateExported(Object path);

  /// No description provided for @errorExportingTemplate.
  ///
  /// In en, this message translates to:
  /// **'Error exporting template: {error}'**
  String errorExportingTemplate(Object error);

  /// No description provided for @generateDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate Document: {title}'**
  String generateDocumentTitle(Object title);

  /// No description provided for @fillDataTab.
  ///
  /// In en, this message translates to:
  /// **'Fill Data'**
  String get fillDataTab;

  /// No description provided for @previewTab.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewTab;

  /// No description provided for @showDocument.
  ///
  /// In en, this message translates to:
  /// **'Show Document'**
  String get showDocument;

  /// No description provided for @fillInformation.
  ///
  /// In en, this message translates to:
  /// **'Fill Information'**
  String get fillInformation;

  /// No description provided for @dataLoops.
  ///
  /// In en, this message translates to:
  /// **'Data Loops'**
  String get dataLoops;

  /// No description provided for @generateDocument.
  ///
  /// In en, this message translates to:
  /// **'Generate Document'**
  String get generateDocument;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @addNewRow.
  ///
  /// In en, this message translates to:
  /// **'Add New Row'**
  String get addNewRow;

  /// No description provided for @rowNumber.
  ///
  /// In en, this message translates to:
  /// **'Row {number}'**
  String rowNumber(Object number);

  /// No description provided for @deleteThisRow.
  ///
  /// In en, this message translates to:
  /// **'Delete this row'**
  String get deleteThisRow;

  /// No description provided for @enterField.
  ///
  /// In en, this message translates to:
  /// **'Enter {field}'**
  String enterField(Object field);

  /// No description provided for @unsupportedFieldType.
  ///
  /// In en, this message translates to:
  /// **'Field type {type} not supported'**
  String unsupportedFieldType(Object type);

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @selectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select date and time'**
  String get selectDateTime;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @completedDocument.
  ///
  /// In en, this message translates to:
  /// **'Completed Document'**
  String get completedDocument;

  /// No description provided for @fieldCount.
  ///
  /// In en, this message translates to:
  /// **'Fields: {count}'**
  String fieldCount(Object count);

  /// No description provided for @basicFieldCount.
  ///
  /// In en, this message translates to:
  /// **'basic fields'**
  String get basicFieldCount;

  /// No description provided for @loopFieldCount.
  ///
  /// In en, this message translates to:
  /// **'fields in loops'**
  String get loopFieldCount;

  /// No description provided for @loopDataCount.
  ///
  /// In en, this message translates to:
  /// **'Data loops: {count}'**
  String loopDataCount(Object count);

  /// No description provided for @duplicateIdWarning.
  ///
  /// In en, this message translates to:
  /// **'Detected {count} inconsistent duplicate IDs. Elements with the same ID must have the same type and title.'**
  String duplicateIdWarning(Object count);

  /// No description provided for @normalFields.
  ///
  /// In en, this message translates to:
  /// **'Normal fields:'**
  String get normalFields;

  /// No description provided for @loopLabel.
  ///
  /// In en, this message translates to:
  /// **'Loop: {title}'**
  String loopLabel(Object title);

  /// No description provided for @structureDetail.
  ///
  /// In en, this message translates to:
  /// **'Structure details'**
  String get structureDetail;

  /// No description provided for @basicFields.
  ///
  /// In en, this message translates to:
  /// **'Basic fields'**
  String get basicFields;

  /// No description provided for @loopContent.
  ///
  /// In en, this message translates to:
  /// **'Loop content'**
  String get loopContent;

  /// No description provided for @fieldInLoop.
  ///
  /// In en, this message translates to:
  /// **'Field \"{field}\" belongs to loop \"{loop}\"'**
  String fieldInLoop(Object field, Object loop);

  /// No description provided for @characterCount.
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String characterCount(Object count);

  /// No description provided for @fieldsAndLoops.
  ///
  /// In en, this message translates to:
  /// **'{fields} fields, {loops} loops'**
  String fieldsAndLoops(Object fields, Object loops);

  /// No description provided for @longPressToSelect.
  ///
  /// In en, this message translates to:
  /// **'Long press to select templates'**
  String get longPressToSelect;

  /// No description provided for @selectedTemplates.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedTemplates(Object count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @batchExport.
  ///
  /// In en, this message translates to:
  /// **'Export Selected'**
  String get batchExport;

  /// No description provided for @batchDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get batchDelete;

  /// No description provided for @exportTemplates.
  ///
  /// In en, this message translates to:
  /// **'Export Templates'**
  String get exportTemplates;

  /// No description provided for @editFilenames.
  ///
  /// In en, this message translates to:
  /// **'Edit file names before export:'**
  String get editFilenames;

  /// No description provided for @filenameFor.
  ///
  /// In en, this message translates to:
  /// **'Filename for \"{title}\":'**
  String filenameFor(Object title);

  /// No description provided for @confirmBatchDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Batch Delete'**
  String get confirmBatchDelete;

  /// No description provided for @typeConfirmToDelete.
  ///
  /// In en, this message translates to:
  /// **'Type \"confirm\" to delete {count} selected templates:'**
  String typeConfirmToDelete(Object count);

  /// No description provided for @confirmText.
  ///
  /// In en, this message translates to:
  /// **'confirm'**
  String get confirmText;

  /// No description provided for @confirmationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please type \"confirm\" to proceed'**
  String get confirmationRequired;

  /// No description provided for @batchExportCompleted.
  ///
  /// In en, this message translates to:
  /// **'Exported {count} templates successfully'**
  String batchExportCompleted(Object count);

  /// No description provided for @batchDeleteCompleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} templates successfully'**
  String batchDeleteCompleted(Object count);

  /// No description provided for @errorDuringBatchExport.
  ///
  /// In en, this message translates to:
  /// **'Error exporting some templates: {errors}'**
  String errorDuringBatchExport(Object errors);

  /// No description provided for @passwordGenerator.
  ///
  /// In en, this message translates to:
  /// **'Password Generator'**
  String get passwordGenerator;

  /// No description provided for @numCharacters.
  ///
  /// In en, this message translates to:
  /// **'Number of characters'**
  String get numCharacters;

  /// No description provided for @includeLowercase.
  ///
  /// In en, this message translates to:
  /// **'Include lowercase letters'**
  String get includeLowercase;

  /// No description provided for @includeUppercase.
  ///
  /// In en, this message translates to:
  /// **'Include uppercase letters'**
  String get includeUppercase;

  /// No description provided for @includeNumbers.
  ///
  /// In en, this message translates to:
  /// **'Include numbers'**
  String get includeNumbers;

  /// No description provided for @includeSpecial.
  ///
  /// In en, this message translates to:
  /// **'Include special characters'**
  String get includeSpecial;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @generatedPassword.
  ///
  /// In en, this message translates to:
  /// **'Generated Password'**
  String get generatedPassword;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// No description provided for @numberGenerator.
  ///
  /// In en, this message translates to:
  /// **'Number Generator'**
  String get numberGenerator;

  /// No description provided for @integers.
  ///
  /// In en, this message translates to:
  /// **'Integers'**
  String get integers;

  /// No description provided for @floatingPoint.
  ///
  /// In en, this message translates to:
  /// **'Floating Point'**
  String get floatingPoint;

  /// No description provided for @minValue.
  ///
  /// In en, this message translates to:
  /// **'Minimum Value'**
  String get minValue;

  /// No description provided for @maxValue.
  ///
  /// In en, this message translates to:
  /// **'Maximum Value'**
  String get maxValue;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @allowDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Allow Duplicates'**
  String get allowDuplicates;

  /// No description provided for @generatedNumbers.
  ///
  /// In en, this message translates to:
  /// **'Generated Numbers'**
  String get generatedNumbers;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @yesNo.
  ///
  /// In en, this message translates to:
  /// **'Yes or No?'**
  String get yesNo;

  /// No description provided for @flipCoin.
  ///
  /// In en, this message translates to:
  /// **'Flip Coin'**
  String get flipCoin;

  /// No description provided for @flipCoinInstruction.
  ///
  /// In en, this message translates to:
  /// **'Flip the coin to see the result'**
  String get flipCoinInstruction;

  /// No description provided for @rockPaperScissors.
  ///
  /// In en, this message translates to:
  /// **'Rock Paper Scissors'**
  String get rockPaperScissors;

  /// No description provided for @rollDice.
  ///
  /// In en, this message translates to:
  /// **'Roll Dice'**
  String get rollDice;

  /// No description provided for @diceCount.
  ///
  /// In en, this message translates to:
  /// **'Number of dice'**
  String get diceCount;

  /// No description provided for @diceSides.
  ///
  /// In en, this message translates to:
  /// **'Sides per die'**
  String get diceSides;

  /// No description provided for @colorGenerator.
  ///
  /// In en, this message translates to:
  /// **'Color Generator'**
  String get colorGenerator;

  /// No description provided for @hex6.
  ///
  /// In en, this message translates to:
  /// **'HEX (6-digit)'**
  String get hex6;

  /// No description provided for @hex8.
  ///
  /// In en, this message translates to:
  /// **'HEX (8-digit with alpha)'**
  String get hex8;

  /// No description provided for @generatedColor.
  ///
  /// In en, this message translates to:
  /// **'Generated Color'**
  String get generatedColor;

  /// No description provided for @latinLetters.
  ///
  /// In en, this message translates to:
  /// **'Latin Letters'**
  String get latinLetters;

  /// No description provided for @letterCount.
  ///
  /// In en, this message translates to:
  /// **'Number of letters'**
  String get letterCount;

  /// No description provided for @tens.
  ///
  /// In en, this message translates to:
  /// **'Tens'**
  String get tens;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @playingCards.
  ///
  /// In en, this message translates to:
  /// **'Playing Cards'**
  String get playingCards;

  /// No description provided for @includeJokers.
  ///
  /// In en, this message translates to:
  /// **'Include Jokers'**
  String get includeJokers;

  /// No description provided for @cardCount.
  ///
  /// In en, this message translates to:
  /// **'Number of cards'**
  String get cardCount;

  /// No description provided for @currencyConverter.
  ///
  /// In en, this message translates to:
  /// **'Currency Converter'**
  String get currencyConverter;

  /// No description provided for @updatingRates.
  ///
  /// In en, this message translates to:
  /// **'Updating exchange rates...'**
  String get updatingRates;

  /// No description provided for @lastUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date} at {time}'**
  String lastUpdatedAt(Object date, Object time);

  /// No description provided for @noRatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No exchange rate information available, fetching rates...'**
  String get noRatesAvailable;

  /// No description provided for @liveRates.
  ///
  /// In en, this message translates to:
  /// **'Live Exchange Rates'**
  String get liveRates;

  /// No description provided for @staticRates.
  ///
  /// In en, this message translates to:
  /// **'Static'**
  String get staticRates;

  /// No description provided for @refreshRates.
  ///
  /// In en, this message translates to:
  /// **'Refresh rates'**
  String get refreshRates;

  /// No description provided for @resetLayout.
  ///
  /// In en, this message translates to:
  /// **'Reset Layout'**
  String get resetLayout;

  /// No description provided for @customizeCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Customize Currencies'**
  String get customizeCurrencies;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @addRow.
  ///
  /// In en, this message translates to:
  /// **'Add Row'**
  String get addRow;

  /// No description provided for @cardView.
  ///
  /// In en, this message translates to:
  /// **'Card View'**
  String get cardView;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @rows.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get rows;

  /// No description provided for @converter.
  ///
  /// In en, this message translates to:
  /// **'Converter'**
  String get converter;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @fromCurrency.
  ///
  /// In en, this message translates to:
  /// **'From Currency'**
  String get fromCurrency;

  /// No description provided for @convertedTo.
  ///
  /// In en, this message translates to:
  /// **'Converted to'**
  String get convertedTo;

  /// No description provided for @removeCard.
  ///
  /// In en, this message translates to:
  /// **'Remove card'**
  String get removeCard;

  /// No description provided for @removeRow.
  ///
  /// In en, this message translates to:
  /// **'Remove row'**
  String get removeRow;

  /// No description provided for @liveRatesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Live rates updated successfully'**
  String get liveRatesUpdated;

  /// No description provided for @staticRatesUsed.
  ///
  /// In en, this message translates to:
  /// **'Using static rates (live data unavailable)'**
  String get staticRatesUsed;

  /// No description provided for @failedToUpdateRates.
  ///
  /// In en, this message translates to:
  /// **'Failed to update rates'**
  String get failedToUpdateRates;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @customizeCurrenciesDialog.
  ///
  /// In en, this message translates to:
  /// **'Customize Currencies'**
  String get customizeCurrenciesDialog;

  /// No description provided for @searchCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Search currencies...'**
  String get searchCurrencies;

  /// No description provided for @noCurrenciesFound.
  ///
  /// In en, this message translates to:
  /// **'No currencies found'**
  String get noCurrenciesFound;

  /// No description provided for @currenciesSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} currencies selected'**
  String currenciesSelected(Object count);

  /// No description provided for @applyChanges.
  ///
  /// In en, this message translates to:
  /// **'Apply Changes'**
  String get applyChanges;

  /// No description provided for @currencyStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Live rate'**
  String get currencyStatusSuccess;

  /// No description provided for @currencyStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch'**
  String get currencyStatusFailed;

  /// No description provided for @currencyStatusTimeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get currencyStatusTimeout;

  /// No description provided for @currencyStatusNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Not supported'**
  String get currencyStatusNotSupported;

  /// No description provided for @currencyStatusStatic.
  ///
  /// In en, this message translates to:
  /// **'Static rate'**
  String get currencyStatusStatic;

  /// No description provided for @currencyStatusFetchedRecently.
  ///
  /// In en, this message translates to:
  /// **'Recently fetched'**
  String get currencyStatusFetchedRecently;

  /// No description provided for @currencyStatusSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Successfully fetched live rate'**
  String get currencyStatusSuccessDesc;

  /// No description provided for @currencyStatusFailedDesc.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch live rate, using static fallback'**
  String get currencyStatusFailedDesc;

  /// No description provided for @currencyStatusTimeoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Request timed out, using static fallback'**
  String get currencyStatusTimeoutDesc;

  /// No description provided for @currencyStatusNotSupportedDesc.
  ///
  /// In en, this message translates to:
  /// **'Currency not supported by API'**
  String get currencyStatusNotSupportedDesc;

  /// No description provided for @currencyStatusStaticDesc.
  ///
  /// In en, this message translates to:
  /// **'Using static exchange rate'**
  String get currencyStatusStaticDesc;

  /// No description provided for @currencyStatusFetchedRecentlyDesc.
  ///
  /// In en, this message translates to:
  /// **'Successfully fetched within the last hour'**
  String get currencyStatusFetchedRecentlyDesc;

  /// No description provided for @currencyConverterInfo.
  ///
  /// In en, this message translates to:
  /// **'Currency Converter Info'**
  String get currencyConverterInfo;

  /// No description provided for @aboutThisFeature.
  ///
  /// In en, this message translates to:
  /// **'About This Feature'**
  String get aboutThisFeature;

  /// No description provided for @aboutThisFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'The Currency Converter allows you to convert between different currencies using live or static exchange rates. It supports over 80 currencies worldwide.'**
  String get aboutThisFeatureDesc;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get howToUse;

  /// No description provided for @howToUseDesc.
  ///
  /// In en, this message translates to:
  /// **'• Add or remove cards/rows for multiple conversions\n• Customize visible currencies\n• Switch between card and table view\n• Rates update automatically based on your settings'**
  String get howToUseDesc;

  /// No description provided for @staticRatesInfo.
  ///
  /// In en, this message translates to:
  /// **'Static Exchange Rates'**
  String get staticRatesInfo;

  /// No description provided for @staticRatesInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Static rates are fallback values used when live rates cannot be fetched. These rates are updated periodically and may not reflect real-time market prices.'**
  String get staticRatesInfoDesc;

  /// No description provided for @viewStaticRates.
  ///
  /// In en, this message translates to:
  /// **'View Static Rates'**
  String get viewStaticRates;

  /// No description provided for @lastStaticUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last static rates update: May 2025'**
  String get lastStaticUpdate;

  /// No description provided for @staticRatesList.
  ///
  /// In en, this message translates to:
  /// **'Static Exchange Rates List'**
  String get staticRatesList;

  /// No description provided for @rateBasedOnUSD.
  ///
  /// In en, this message translates to:
  /// **'All rates are based on 1 USD'**
  String get rateBasedOnUSD;

  /// No description provided for @maxCurrenciesSelected.
  ///
  /// In en, this message translates to:
  /// **'Maximum 10 currencies can be selected'**
  String get maxCurrenciesSelected;

  /// No description provided for @savePreset.
  ///
  /// In en, this message translates to:
  /// **'Save Preset'**
  String get savePreset;

  /// No description provided for @loadPreset.
  ///
  /// In en, this message translates to:
  /// **'Load Preset'**
  String get loadPreset;

  /// No description provided for @presetName.
  ///
  /// In en, this message translates to:
  /// **'Preset Name'**
  String get presetName;

  /// No description provided for @enterPresetName.
  ///
  /// In en, this message translates to:
  /// **'Enter preset name'**
  String get enterPresetName;

  /// No description provided for @presetNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Preset name is required'**
  String get presetNameRequired;

  /// No description provided for @presetSaved.
  ///
  /// In en, this message translates to:
  /// **'Preset saved: {name}'**
  String presetSaved(String name);

  /// No description provided for @presetLoaded.
  ///
  /// In en, this message translates to:
  /// **'Preset loaded successfully'**
  String get presetLoaded;

  /// No description provided for @presetDeleted.
  ///
  /// In en, this message translates to:
  /// **'Preset deleted successfully'**
  String get presetDeleted;

  /// No description provided for @deletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get deletePreset;

  /// No description provided for @confirmDeletePreset.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this preset?'**
  String get confirmDeletePreset;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @sortByDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sortByDate;

  /// No description provided for @noPresetsFound.
  ///
  /// In en, this message translates to:
  /// **'No presets found'**
  String get noPresetsFound;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String createdOn(Object date);

  /// No description provided for @currencies.
  ///
  /// In en, this message translates to:
  /// **'{count} currencies'**
  String currencies(Object count);

  /// No description provided for @currenciesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} currencies'**
  String currenciesCount(Object count);

  /// No description provided for @createdDate.
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdDate(Object date);

  /// No description provided for @sortByLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get sortByLabel;

  /// No description provided for @selectPreset.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectPreset;

  /// No description provided for @deletePresetAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletePresetAction;

  /// No description provided for @deletePresetTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Preset'**
  String get deletePresetTitle;

  /// No description provided for @deletePresetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this preset?'**
  String get deletePresetConfirm;

  /// No description provided for @presetDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Preset deleted'**
  String get presetDeletedSuccess;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get errorLabel;

  /// No description provided for @fetchTimeout.
  ///
  /// In en, this message translates to:
  /// **'Fetch Timeout'**
  String get fetchTimeout;

  /// No description provided for @fetchTimeoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Set timeout for currency rate fetching (5-20 seconds)'**
  String get fetchTimeoutDesc;

  /// No description provided for @fetchTimeoutSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String fetchTimeoutSeconds(Object seconds);

  /// No description provided for @fetchRetryIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Retry when incomplete'**
  String get fetchRetryIncomplete;

  /// No description provided for @fetchRetryIncompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically retry failed/timeout currencies during fetch'**
  String get fetchRetryIncompleteDesc;

  /// No description provided for @fetchRetryTimes.
  ///
  /// In en, this message translates to:
  /// **'{times} retries'**
  String fetchRetryTimes(int times);

  /// No description provided for @fetchingRates.
  ///
  /// In en, this message translates to:
  /// **'Fetching Currency Rates'**
  String get fetchingRates;

  /// No description provided for @fetchingProgress.
  ///
  /// In en, this message translates to:
  /// **'Fetching progress: {completed}/{total}'**
  String fetchingProgress(Object completed, Object total);

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Time remaining: {seconds}s'**
  String timeRemaining(Object seconds);

  /// No description provided for @fetchingStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get fetchingStatus;

  /// No description provided for @fetchingCurrency.
  ///
  /// In en, this message translates to:
  /// **'Fetching {currency}...'**
  String fetchingCurrency(Object currency);

  /// No description provided for @fetchComplete.
  ///
  /// In en, this message translates to:
  /// **'Fetch Complete'**
  String get fetchComplete;

  /// No description provided for @fetchCancelled.
  ///
  /// In en, this message translates to:
  /// **'Fetch Cancelled'**
  String get fetchCancelled;

  /// No description provided for @dateGenerator.
  ///
  /// In en, this message translates to:
  /// **'Date Generator'**
  String get dateGenerator;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @dateCount.
  ///
  /// In en, this message translates to:
  /// **'Number of dates'**
  String get dateCount;

  /// No description provided for @timeGenerator.
  ///
  /// In en, this message translates to:
  /// **'Time Generator'**
  String get timeGenerator;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @timeCount.
  ///
  /// In en, this message translates to:
  /// **'Number of times'**
  String get timeCount;

  /// No description provided for @dateTimeGenerator.
  ///
  /// In en, this message translates to:
  /// **'Date & Time Generator'**
  String get dateTimeGenerator;

  /// No description provided for @heads.
  ///
  /// In en, this message translates to:
  /// **'Heads'**
  String get heads;

  /// No description provided for @tails.
  ///
  /// In en, this message translates to:
  /// **'Tails'**
  String get tails;

  /// No description provided for @rock.
  ///
  /// In en, this message translates to:
  /// **'Rock'**
  String get rock;

  /// No description provided for @paper.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get paper;

  /// No description provided for @scissors.
  ///
  /// In en, this message translates to:
  /// **'Scissors'**
  String get scissors;

  /// No description provided for @randomResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get randomResult;

  /// No description provided for @flipping.
  ///
  /// In en, this message translates to:
  /// **'Flipping...'**
  String get flipping;

  /// No description provided for @cacheTypeTextTemplates.
  ///
  /// In en, this message translates to:
  /// **'Text Templates'**
  String get cacheTypeTextTemplates;

  /// No description provided for @cacheTypeTextTemplatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Saved text templates and content'**
  String get cacheTypeTextTemplatesDesc;

  /// No description provided for @cacheTypeAppSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get cacheTypeAppSettings;

  /// No description provided for @cacheTypeAppSettingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Theme, language, and user preferences'**
  String get cacheTypeAppSettingsDesc;

  /// No description provided for @cacheTypeRandomGenerators.
  ///
  /// In en, this message translates to:
  /// **'Random Generators'**
  String get cacheTypeRandomGenerators;

  /// No description provided for @cacheTypeRandomGeneratorsDesc.
  ///
  /// In en, this message translates to:
  /// **'Generation history and settings'**
  String get cacheTypeRandomGeneratorsDesc;

  /// No description provided for @saveGenerationHistory.
  ///
  /// In en, this message translates to:
  /// **'Save Generation History'**
  String get saveGenerationHistory;

  /// No description provided for @saveGenerationHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Remember and display history of generated items'**
  String get saveGenerationHistoryDesc;

  /// No description provided for @generationHistory.
  ///
  /// In en, this message translates to:
  /// **'Generation History'**
  String get generationHistory;

  /// No description provided for @generatedAt.
  ///
  /// In en, this message translates to:
  /// **'Generated at'**
  String get generatedAt;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @typeConfirmToProceed.
  ///
  /// In en, this message translates to:
  /// **'Type \"confirm\" to proceed:'**
  String get typeConfirmToProceed;

  /// No description provided for @toolsShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Tools & Shortcuts'**
  String get toolsShortcuts;

  /// No description provided for @displayArrangeTools.
  ///
  /// In en, this message translates to:
  /// **'Display and arrange tools'**
  String get displayArrangeTools;

  /// No description provided for @displayArrangeToolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Control which tools are visible and their order'**
  String get displayArrangeToolsDesc;

  /// No description provided for @manageToolVisibility.
  ///
  /// In en, this message translates to:
  /// **'Manage Tool Visibility and Order'**
  String get manageToolVisibility;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder tools'**
  String get dragToReorder;

  /// No description provided for @allToolsHidden.
  ///
  /// In en, this message translates to:
  /// **'All tools are hidden'**
  String get allToolsHidden;

  /// No description provided for @allToolsHiddenDesc.
  ///
  /// In en, this message translates to:
  /// **'Please enable at least one tool to continue using the application'**
  String get allToolsHiddenDesc;

  /// No description provided for @enableAtLeastOneTool.
  ///
  /// In en, this message translates to:
  /// **'Please enable at least one tool'**
  String get enableAtLeastOneTool;

  /// No description provided for @toolVisibilityChanged.
  ///
  /// In en, this message translates to:
  /// **'Tool visibility has been updated'**
  String get toolVisibilityChanged;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @manageQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Manage Quick Actions'**
  String get manageQuickActions;

  /// No description provided for @manageQuickActionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure shortcuts for quick access to tools'**
  String get manageQuickActionsDesc;

  /// No description provided for @quickActionsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsDialogTitle;

  /// No description provided for @quickActionsDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'Select up to 4 tools for quick access via app icon or taskbar'**
  String get quickActionsDialogDesc;

  /// No description provided for @quickActionsLimit.
  ///
  /// In en, this message translates to:
  /// **'Maximum 4 quick actions allowed'**
  String get quickActionsLimit;

  /// No description provided for @quickActionsLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can only select up to 4 tools for quick actions'**
  String get quickActionsLimitReached;

  /// No description provided for @clearAllQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllQuickActions;

  /// No description provided for @quickActionsCleared.
  ///
  /// In en, this message translates to:
  /// **'Quick actions cleared'**
  String get quickActionsCleared;

  /// No description provided for @quickActionsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Quick actions updated'**
  String get quickActionsUpdated;

  /// No description provided for @quickActionsInfo.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActionsInfo;

  /// No description provided for @selectUpTo4Tools.
  ///
  /// In en, this message translates to:
  /// **'Select up to 4 tools for quick access.'**
  String get selectUpTo4Tools;

  /// No description provided for @quickActionsEnableDesc.
  ///
  /// In en, this message translates to:
  /// **'Quick actions will appear when you long-press the app icon on Android or right-click the taskbar icon on Windows.'**
  String get quickActionsEnableDesc;

  /// No description provided for @quickActionsEnableDescMobile.
  ///
  /// In en, this message translates to:
  /// **'Quick actions will appear when you long-press the app icon (Android/iOS only).'**
  String get quickActionsEnableDescMobile;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected: {current} of {max}'**
  String selectedCount(int current, int max);

  /// No description provided for @maxQuickActionsReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 4 quick actions reached'**
  String get maxQuickActionsReached;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @converterTools.
  ///
  /// In en, this message translates to:
  /// **'Converter Tools'**
  String get converterTools;

  /// No description provided for @converterToolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between different units and systems'**
  String get converterToolsDesc;

  /// No description provided for @calculatorTools.
  ///
  /// In en, this message translates to:
  /// **'Calculator Tools'**
  String get calculatorTools;

  /// No description provided for @calculatorToolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Specialized calculators for health, finance, and more'**
  String get calculatorToolsDesc;

  /// No description provided for @lengthConverter.
  ///
  /// In en, this message translates to:
  /// **'Length Converter'**
  String get lengthConverter;

  /// No description provided for @temperatureConverter.
  ///
  /// In en, this message translates to:
  /// **'Temperature Converter'**
  String get temperatureConverter;

  /// No description provided for @volumeConverter.
  ///
  /// In en, this message translates to:
  /// **'Volume Converter'**
  String get volumeConverter;

  /// No description provided for @areaConverter.
  ///
  /// In en, this message translates to:
  /// **'Area Converter'**
  String get areaConverter;

  /// No description provided for @speedConverter.
  ///
  /// In en, this message translates to:
  /// **'Speed Converter'**
  String get speedConverter;

  /// No description provided for @timeConverter.
  ///
  /// In en, this message translates to:
  /// **'Time Converter'**
  String get timeConverter;

  /// No description provided for @dataConverter.
  ///
  /// In en, this message translates to:
  /// **'Data Storage Converter'**
  String get dataConverter;

  /// No description provided for @numberSystemConverter.
  ///
  /// In en, this message translates to:
  /// **'Number System Converter'**
  String get numberSystemConverter;

  /// No description provided for @tables.
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get tables;

  /// No description provided for @tableView.
  ///
  /// In en, this message translates to:
  /// **'Table View'**
  String get tableView;

  /// No description provided for @listView.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get listView;

  /// No description provided for @customizeUnits.
  ///
  /// In en, this message translates to:
  /// **'Customize Units'**
  String get customizeUnits;

  /// No description provided for @visibleUnits.
  ///
  /// In en, this message translates to:
  /// **'Visible Units'**
  String get visibleUnits;

  /// No description provided for @selectUnitsToShow.
  ///
  /// In en, this message translates to:
  /// **'Select units to display'**
  String get selectUnitsToShow;

  /// No description provided for @enterValue.
  ///
  /// In en, this message translates to:
  /// **'Enter value'**
  String get enterValue;

  /// No description provided for @conversionResults.
  ///
  /// In en, this message translates to:
  /// **'Conversion Results'**
  String get conversionResults;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'Meters'**
  String get meters;

  /// No description provided for @kilometers.
  ///
  /// In en, this message translates to:
  /// **'Kilometers'**
  String get kilometers;

  /// No description provided for @centimeters.
  ///
  /// In en, this message translates to:
  /// **'Centimeters'**
  String get centimeters;

  /// No description provided for @millimeters.
  ///
  /// In en, this message translates to:
  /// **'Millimeters'**
  String get millimeters;

  /// No description provided for @inches.
  ///
  /// In en, this message translates to:
  /// **'Inches'**
  String get inches;

  /// No description provided for @feet.
  ///
  /// In en, this message translates to:
  /// **'Feet'**
  String get feet;

  /// No description provided for @yards.
  ///
  /// In en, this message translates to:
  /// **'Yards'**
  String get yards;

  /// No description provided for @miles.
  ///
  /// In en, this message translates to:
  /// **'Miles'**
  String get miles;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'Grams'**
  String get grams;

  /// No description provided for @kilograms.
  ///
  /// In en, this message translates to:
  /// **'Kilograms'**
  String get kilograms;

  /// No description provided for @pounds.
  ///
  /// In en, this message translates to:
  /// **'Pounds'**
  String get pounds;

  /// No description provided for @ounces.
  ///
  /// In en, this message translates to:
  /// **'Ounces'**
  String get ounces;

  /// No description provided for @tons.
  ///
  /// In en, this message translates to:
  /// **'Tons'**
  String get tons;

  /// No description provided for @celsius.
  ///
  /// In en, this message translates to:
  /// **'Celsius'**
  String get celsius;

  /// No description provided for @fahrenheit.
  ///
  /// In en, this message translates to:
  /// **'Fahrenheit'**
  String get fahrenheit;

  /// No description provided for @kelvin.
  ///
  /// In en, this message translates to:
  /// **'Kelvin'**
  String get kelvin;

  /// No description provided for @liters.
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get liters;

  /// No description provided for @milliliters.
  ///
  /// In en, this message translates to:
  /// **'Milliliters'**
  String get milliliters;

  /// No description provided for @gallons.
  ///
  /// In en, this message translates to:
  /// **'Gallons'**
  String get gallons;

  /// No description provided for @quarts.
  ///
  /// In en, this message translates to:
  /// **'Quarts'**
  String get quarts;

  /// No description provided for @pints.
  ///
  /// In en, this message translates to:
  /// **'Pints'**
  String get pints;

  /// No description provided for @cups.
  ///
  /// In en, this message translates to:
  /// **'Cups'**
  String get cups;

  /// No description provided for @squareMeters.
  ///
  /// In en, this message translates to:
  /// **'Square Meters'**
  String get squareMeters;

  /// No description provided for @squareKilometers.
  ///
  /// In en, this message translates to:
  /// **'Square Kilometers'**
  String get squareKilometers;

  /// No description provided for @squareFeet.
  ///
  /// In en, this message translates to:
  /// **'Square Feet'**
  String get squareFeet;

  /// No description provided for @squareInches.
  ///
  /// In en, this message translates to:
  /// **'Square Inches'**
  String get squareInches;

  /// No description provided for @acres.
  ///
  /// In en, this message translates to:
  /// **'Acres'**
  String get acres;

  /// No description provided for @hectares.
  ///
  /// In en, this message translates to:
  /// **'Hectares'**
  String get hectares;

  /// No description provided for @metersPerSecond.
  ///
  /// In en, this message translates to:
  /// **'Meters per Second'**
  String get metersPerSecond;

  /// No description provided for @kilometersPerHour.
  ///
  /// In en, this message translates to:
  /// **'Kilometers per Hour'**
  String get kilometersPerHour;

  /// No description provided for @milesPerHour.
  ///
  /// In en, this message translates to:
  /// **'Miles per Hour'**
  String get milesPerHour;

  /// No description provided for @knots.
  ///
  /// In en, this message translates to:
  /// **'Knots'**
  String get knots;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeks;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @bytes.
  ///
  /// In en, this message translates to:
  /// **'Bytes'**
  String get bytes;

  /// No description provided for @kilobytes.
  ///
  /// In en, this message translates to:
  /// **'Kilobytes'**
  String get kilobytes;

  /// No description provided for @megabytes.
  ///
  /// In en, this message translates to:
  /// **'Megabytes'**
  String get megabytes;

  /// No description provided for @gigabytes.
  ///
  /// In en, this message translates to:
  /// **'Gigabytes'**
  String get gigabytes;

  /// No description provided for @terabytes.
  ///
  /// In en, this message translates to:
  /// **'Terabytes'**
  String get terabytes;

  /// No description provided for @bits.
  ///
  /// In en, this message translates to:
  /// **'Bits'**
  String get bits;

  /// No description provided for @decimal.
  ///
  /// In en, this message translates to:
  /// **'Decimal'**
  String get decimal;

  /// No description provided for @binary.
  ///
  /// In en, this message translates to:
  /// **'Binary'**
  String get binary;

  /// No description provided for @octal.
  ///
  /// In en, this message translates to:
  /// **'Octal'**
  String get octal;

  /// No description provided for @hexadecimal.
  ///
  /// In en, this message translates to:
  /// **'Hexadecimal'**
  String get hexadecimal;

  /// No description provided for @usd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get usd;

  /// No description provided for @eur.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get eur;

  /// No description provided for @gbp.
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get gbp;

  /// No description provided for @jpy.
  ///
  /// In en, this message translates to:
  /// **'Japanese Yen'**
  String get jpy;

  /// No description provided for @cad.
  ///
  /// In en, this message translates to:
  /// **'Canadian Dollar'**
  String get cad;

  /// No description provided for @aud.
  ///
  /// In en, this message translates to:
  /// **'Australian Dollar'**
  String get aud;

  /// No description provided for @vnd.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese Dong'**
  String get vnd;

  /// No description provided for @currencyConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between different currencies with live exchange rates'**
  String get currencyConverterDesc;

  /// No description provided for @lengthConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between different units of length'**
  String get lengthConverterDesc;

  /// No description provided for @weightConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between different units of weight'**
  String get weightConverterDesc;

  /// No description provided for @temperatureConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between different temperature scales'**
  String get temperatureConverterDesc;

  /// No description provided for @volumeConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between different units of volume'**
  String get volumeConverterDesc;

  /// No description provided for @areaConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between different units of area'**
  String get areaConverterDesc;

  /// No description provided for @speedConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between different units of speed'**
  String get speedConverterDesc;

  /// No description provided for @timeConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between different units of time'**
  String get timeConverterDesc;

  /// No description provided for @dataConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between different units of data storage'**
  String get dataConverterDesc;

  /// No description provided for @numberSystemConverterDesc.
  ///
  /// In en, this message translates to:
  /// **'Convert between different number systems'**
  String get numberSystemConverterDesc;

  /// No description provided for @fromUnit.
  ///
  /// In en, this message translates to:
  /// **'From Unit'**
  String get fromUnit;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @bmiCalculator.
  ///
  /// In en, this message translates to:
  /// **'BMI Calculator'**
  String get bmiCalculator;

  /// No description provided for @bmiCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Calculate Body Mass Index and health category'**
  String get bmiCalculatorDesc;

  /// No description provided for @scientificCalculator.
  ///
  /// In en, this message translates to:
  /// **'Scientific Calculator'**
  String get scientificCalculator;

  /// No description provided for @scientificCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Advanced calculator with trigonometric, logarithmic functions'**
  String get scientificCalculatorDesc;

  /// No description provided for @graphingCalculator.
  ///
  /// In en, this message translates to:
  /// **'Graphing Calculator'**
  String get graphingCalculator;

  /// No description provided for @graphingCalculatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Plot and visualize mathematical functions'**
  String get graphingCalculatorDesc;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperial;

  /// No description provided for @enterMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Enter your measurements'**
  String get enterMeasurements;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @heightInches.
  ///
  /// In en, this message translates to:
  /// **'Height (inches)'**
  String get heightInches;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @weightPounds.
  ///
  /// In en, this message translates to:
  /// **'Weight (pounds)'**
  String get weightPounds;

  /// No description provided for @yourBMI.
  ///
  /// In en, this message translates to:
  /// **'Your BMI'**
  String get yourBMI;

  /// No description provided for @bmiScale.
  ///
  /// In en, this message translates to:
  /// **'BMI Scale'**
  String get bmiScale;

  /// No description provided for @underweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get underweight;

  /// No description provided for @normalWeight.
  ///
  /// In en, this message translates to:
  /// **'Normal Weight'**
  String get normalWeight;

  /// No description provided for @overweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get overweight;

  /// No description provided for @obese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get obese;

  /// No description provided for @currencyFetchMode.
  ///
  /// In en, this message translates to:
  /// **'Currency Rate Fetching'**
  String get currencyFetchMode;

  /// No description provided for @currencyFetchModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose how currency exchange rates are updated'**
  String get currencyFetchModeDesc;

  /// No description provided for @fetchModeManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get fetchModeManual;

  /// No description provided for @fetchModeManualDesc.
  ///
  /// In en, this message translates to:
  /// **'Only use cached rates, update manually by tapping refresh'**
  String get fetchModeManualDesc;

  /// No description provided for @fetchModeOnceADay.
  ///
  /// In en, this message translates to:
  /// **'Once a day'**
  String get fetchModeOnceADay;

  /// No description provided for @fetchModeOnceADayDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically fetch rates once per day'**
  String get fetchModeOnceADayDesc;

  /// No description provided for @fetchModeEverytime.
  ///
  /// In en, this message translates to:
  /// **'Every time'**
  String get fetchModeEverytime;

  /// No description provided for @fetchModeEverytimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Fetch fresh rates every time the converter is opened'**
  String get fetchModeEverytimeDesc;

  /// No description provided for @currencyFetchStatus.
  ///
  /// In en, this message translates to:
  /// **'Currency Fetch Status'**
  String get currencyFetchStatus;

  /// No description provided for @fetchStatusSummary.
  ///
  /// In en, this message translates to:
  /// **'Fetch Status Summary'**
  String get fetchStatusSummary;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @timeout.
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get timeout;

  /// No description provided for @static.
  ///
  /// In en, this message translates to:
  /// **'Static'**
  String get static;

  /// No description provided for @noCurrenciesInThisCategory.
  ///
  /// In en, this message translates to:
  /// **'No currencies in this category'**
  String get noCurrenciesInThisCategory;

  /// No description provided for @saveFeatureState.
  ///
  /// In en, this message translates to:
  /// **'Save Feature State'**
  String get saveFeatureState;

  /// No description provided for @saveFeatureStateDesc.
  ///
  /// In en, this message translates to:
  /// **'Remember the state of features between app sessions'**
  String get saveFeatureStateDesc;

  /// No description provided for @testCache.
  ///
  /// In en, this message translates to:
  /// **'Test Cache'**
  String get testCache;

  /// No description provided for @viewDataStatus.
  ///
  /// In en, this message translates to:
  /// **'View Data Status'**
  String get viewDataStatus;

  /// No description provided for @retryAttempt.
  ///
  /// In en, this message translates to:
  /// **'Retry {current}/{max}'**
  String retryAttempt(int current, int max);

  /// No description provided for @ratesUpdatedWithErrors.
  ///
  /// In en, this message translates to:
  /// **'Rates updated with {errorCount} errors'**
  String ratesUpdatedWithErrors(int errorCount);

  /// No description provided for @newRatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'New exchange rates are available. Would you like to fetch them now?'**
  String get newRatesAvailable;

  /// No description provided for @progressDialogInfo.
  ///
  /// In en, this message translates to:
  /// **'This will show a progress dialog while fetching rates.'**
  String get progressDialogInfo;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @logsManagement.
  ///
  /// In en, this message translates to:
  /// **'App logs management and storage settings'**
  String get logsManagement;

  /// No description provided for @statusInfo.
  ///
  /// In en, this message translates to:
  /// **'Status: {info}'**
  String statusInfo(String info);

  /// No description provided for @logsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Logs available'**
  String get logsAvailable;

  /// No description provided for @noTimeData.
  ///
  /// In en, this message translates to:
  /// **'--:--:--'**
  String get noTimeData;

  /// No description provided for @fetchStatusTab.
  ///
  /// In en, this message translates to:
  /// **'Fetch Status'**
  String get fetchStatusTab;

  /// No description provided for @currencyValueTab.
  ///
  /// In en, this message translates to:
  /// **'Currency Value'**
  String get currencyValueTab;

  /// No description provided for @successfulCount.
  ///
  /// In en, this message translates to:
  /// **'Successful ({count})'**
  String successfulCount(int count);

  /// No description provided for @failedCount.
  ///
  /// In en, this message translates to:
  /// **'Failed ({count})'**
  String failedCount(int count);

  /// No description provided for @timeoutCount.
  ///
  /// In en, this message translates to:
  /// **'Timeout ({count})'**
  String timeoutCount(int count);

  /// No description provided for @recentlyUpdatedCount.
  ///
  /// In en, this message translates to:
  /// **'Recently Updated ({count})'**
  String recentlyUpdatedCount(int count);

  /// No description provided for @updatedCount.
  ///
  /// In en, this message translates to:
  /// **'Updated ({count})'**
  String updatedCount(int count);

  /// No description provided for @staticCount.
  ///
  /// In en, this message translates to:
  /// **'Static ({count})'**
  String staticCount(int count);

  /// No description provided for @noCurrenciesInCategory.
  ///
  /// In en, this message translates to:
  /// **'No currencies in this category'**
  String get noCurrenciesInCategory;

  /// No description provided for @updatedWithinLastHour.
  ///
  /// In en, this message translates to:
  /// **'Updated within the last hour'**
  String get updatedWithinLastHour;

  /// No description provided for @updatedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {days} days ago'**
  String updatedDaysAgo(int days);

  /// No description provided for @updatedHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {hours} hours ago'**
  String updatedHoursAgo(int hours);

  /// No description provided for @hasUpdateData.
  ///
  /// In en, this message translates to:
  /// **'Has update data'**
  String get hasUpdateData;

  /// No description provided for @usingStaticRates.
  ///
  /// In en, this message translates to:
  /// **'Using static rates'**
  String get usingStaticRates;

  /// No description provided for @scrollToTop.
  ///
  /// In en, this message translates to:
  /// **'Scroll to Top'**
  String get scrollToTop;

  /// No description provided for @scrollToBottom.
  ///
  /// In en, this message translates to:
  /// **'Scroll to Bottom'**
  String get scrollToBottom;

  /// No description provided for @logActions.
  ///
  /// In en, this message translates to:
  /// **'Log Actions'**
  String get logActions;

  /// No description provided for @previousChunk.
  ///
  /// In en, this message translates to:
  /// **'Previous Chunk'**
  String get previousChunk;

  /// No description provided for @nextChunk.
  ///
  /// In en, this message translates to:
  /// **'Next Chunk'**
  String get nextChunk;

  /// No description provided for @loadAll.
  ///
  /// In en, this message translates to:
  /// **'Load All'**
  String get loadAll;

  /// No description provided for @firstPart.
  ///
  /// In en, this message translates to:
  /// **'First Part'**
  String get firstPart;

  /// No description provided for @lastPart.
  ///
  /// In en, this message translates to:
  /// **'Last Part'**
  String get lastPart;

  /// No description provided for @largeFile.
  ///
  /// In en, this message translates to:
  /// **'Large File'**
  String get largeFile;

  /// No description provided for @loadingLargeFile.
  ///
  /// In en, this message translates to:
  /// **'Loading large file...'**
  String get loadingLargeFile;

  /// No description provided for @loadingLogContent.
  ///
  /// In en, this message translates to:
  /// **'Loading log content...'**
  String get loadingLogContent;

  /// No description provided for @largeFileDetected.
  ///
  /// In en, this message translates to:
  /// **'Large file detected. Using optimized loading...'**
  String get largeFileDetected;

  /// No description provided for @cacheTypeConverterTools.
  ///
  /// In en, this message translates to:
  /// **'Converter Tools'**
  String get cacheTypeConverterTools;

  /// No description provided for @cacheTypeConverterToolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Currency/length states, presets and exchange rates cache'**
  String get cacheTypeConverterToolsDesc;

  /// No description provided for @cardName.
  ///
  /// In en, this message translates to:
  /// **'Card Name'**
  String get cardName;

  /// No description provided for @cardNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter card name (max 20 characters)'**
  String get cardNameHint;

  /// No description provided for @converterCardNameDefault.
  ///
  /// In en, this message translates to:
  /// **'Card {position}'**
  String converterCardNameDefault(Object position);

  /// No description provided for @unitSelectedStatus.
  ///
  /// In en, this message translates to:
  /// **'Selected {count} of {max}'**
  String unitSelectedStatus(Object count, Object max);

  /// No description provided for @unitVisibleStatus.
  ///
  /// In en, this message translates to:
  /// **'{count} units visible'**
  String unitVisibleStatus(Object count);

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move Down'**
  String get moveDown;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move Up'**
  String get moveUp;

  /// No description provided for @lengthUnits.
  ///
  /// In en, this message translates to:
  /// **'Length Units'**
  String get lengthUnits;

  /// No description provided for @angstroms.
  ///
  /// In en, this message translates to:
  /// **'Angstroms'**
  String get angstroms;

  /// No description provided for @nanometers.
  ///
  /// In en, this message translates to:
  /// **'Nanometers'**
  String get nanometers;

  /// No description provided for @microns.
  ///
  /// In en, this message translates to:
  /// **'Microns'**
  String get microns;

  /// No description provided for @nauticalMiles.
  ///
  /// In en, this message translates to:
  /// **'Nautical Miles'**
  String get nauticalMiles;

  /// No description provided for @customizeLengthUnits.
  ///
  /// In en, this message translates to:
  /// **'Customize Length Units'**
  String get customizeLengthUnits;

  /// No description provided for @selectLengthUnits.
  ///
  /// In en, this message translates to:
  /// **'Select length units to display'**
  String get selectLengthUnits;

  /// No description provided for @lengthConverterInfo.
  ///
  /// In en, this message translates to:
  /// **'Length Converter Information'**
  String get lengthConverterInfo;

  /// Title for weight converter tool
  ///
  /// In en, this message translates to:
  /// **'Weight Converter'**
  String get weightConverter;

  /// Title for weight converter info dialog
  ///
  /// In en, this message translates to:
  /// **'Weight Converter Info'**
  String get weightConverterInfo;

  /// Title for weight unit customization dialog
  ///
  /// In en, this message translates to:
  /// **'Customize Weight Units'**
  String get customizeWeightUnits;

  /// Title for mass converter tool
  ///
  /// In en, this message translates to:
  /// **'Mass Converter'**
  String get massConverter;

  /// Title for mass converter info dialog
  ///
  /// In en, this message translates to:
  /// **'Mass Converter Info'**
  String get massConverterInfo;

  /// Description for mass converter tool
  ///
  /// In en, this message translates to:
  /// **'Convert between mass units (kg, lb, oz)'**
  String get massConverterDesc;

  /// Title for mass unit customization dialog
  ///
  /// In en, this message translates to:
  /// **'Customize Mass Units'**
  String get customizeMassUnits;

  /// No description provided for @availableUnits.
  ///
  /// In en, this message translates to:
  /// **'Available Units'**
  String get availableUnits;

  /// No description provided for @scientificNotation.
  ///
  /// In en, this message translates to:
  /// **'Scientific notation supported for extreme values'**
  String get scientificNotation;

  /// No description provided for @dragging.
  ///
  /// In en, this message translates to:
  /// **'Dragging...'**
  String get dragging;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @editCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Edit currencies'**
  String get editCurrencies;

  /// No description provided for @tableWith.
  ///
  /// In en, this message translates to:
  /// **'Table {count} cards'**
  String tableWith(int count);

  /// No description provided for @noUnitsSelected.
  ///
  /// In en, this message translates to:
  /// **'No units selected'**
  String get noUnitsSelected;

  /// No description provided for @maximumSelectionExceeded.
  ///
  /// In en, this message translates to:
  /// **'Maximum selection exceeded'**
  String get maximumSelectionExceeded;

  /// No description provided for @errorSavingPreset.
  ///
  /// In en, this message translates to:
  /// **'Error saving preset: {error}'**
  String errorSavingPreset(String error);

  /// No description provided for @errorLoadingPresets.
  ///
  /// In en, this message translates to:
  /// **'Error loading presets: {error}'**
  String errorLoadingPresets(String error);

  /// No description provided for @maximumSelectionReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum selection reached'**
  String get maximumSelectionReached;

  /// No description provided for @minimumSelectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Minimum {count} selection(s) required'**
  String minimumSelectionRequired(int count);

  /// No description provided for @renamePreset.
  ///
  /// In en, this message translates to:
  /// **'Rename Preset'**
  String get renamePreset;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @presetRenamedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Preset renamed successfully'**
  String get presetRenamedSuccessfully;

  /// No description provided for @chooseFromSavedPresets.
  ///
  /// In en, this message translates to:
  /// **'Choose from your saved presets'**
  String get chooseFromSavedPresets;

  /// No description provided for @currencyConverterDetailedInfo.
  ///
  /// In en, this message translates to:
  /// **'Currency Converter - Detailed Information'**
  String get currencyConverterDetailedInfo;

  /// No description provided for @currencyConverterOverview.
  ///
  /// In en, this message translates to:
  /// **'This powerful currency converter allows you to convert between different currencies with live exchange rates.'**
  String get currencyConverterOverview;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get keyFeatures;

  /// No description provided for @multipleCards.
  ///
  /// In en, this message translates to:
  /// **'Multiple Cards'**
  String get multipleCards;

  /// No description provided for @multipleCardsDesc.
  ///
  /// In en, this message translates to:
  /// **'Create multiple converter cards, each with its own set of currencies and amounts.'**
  String get multipleCardsDesc;

  /// No description provided for @liveRatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Get real-time exchange rates from reliable financial sources.'**
  String get liveRatesDesc;

  /// No description provided for @customizeCurrenciesDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose which currencies to display and save custom presets.'**
  String get customizeCurrenciesDesc;

  /// No description provided for @dragAndDrop.
  ///
  /// In en, this message translates to:
  /// **'Drag & Drop'**
  String get dragAndDrop;

  /// No description provided for @dragAndDropDesc.
  ///
  /// In en, this message translates to:
  /// **'Reorder your converter cards by dragging them.'**
  String get dragAndDropDesc;

  /// No description provided for @cardAndTableView.
  ///
  /// In en, this message translates to:
  /// **'Card & Table View'**
  String get cardAndTableView;

  /// No description provided for @cardAndTableViewDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch between card view for easy use or table view for comparison.'**
  String get cardAndTableViewDesc;

  /// No description provided for @stateManagement.
  ///
  /// In en, this message translates to:
  /// **'State Management'**
  String get stateManagement;

  /// No description provided for @stateManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Your converter state is automatically saved and restored.'**
  String get stateManagementDesc;

  /// No description provided for @step1.
  ///
  /// In en, this message translates to:
  /// **'1. Add Cards'**
  String get step1;

  /// No description provided for @step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Add Card\' to create new converter cards.'**
  String get step1Desc;

  /// No description provided for @step2.
  ///
  /// In en, this message translates to:
  /// **'2. Enter Amount'**
  String get step2;

  /// No description provided for @step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount in any currency field.'**
  String get step2Desc;

  /// No description provided for @step3.
  ///
  /// In en, this message translates to:
  /// **'3. Select Base Currency'**
  String get step3;

  /// No description provided for @step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Use the dropdown to select which currency you\'re converting from.'**
  String get step3Desc;

  /// No description provided for @step4.
  ///
  /// In en, this message translates to:
  /// **'4. View Results'**
  String get step4;

  /// No description provided for @step4Desc.
  ///
  /// In en, this message translates to:
  /// **'See instant conversions to all other currencies in the card.'**
  String get step4Desc;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @tip1.
  ///
  /// In en, this message translates to:
  /// **'• Tap the edit icon next to card names to rename them'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In en, this message translates to:
  /// **'• Use the currency icon to customize which currencies appear'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In en, this message translates to:
  /// **'• Save currency presets for quick access'**
  String get tip3;

  /// No description provided for @tip4.
  ///
  /// In en, this message translates to:
  /// **'• Check the status indicator for exchange rate freshness'**
  String get tip4;

  /// No description provided for @tip5.
  ///
  /// In en, this message translates to:
  /// **'• Use table view to compare multiple cards side by side'**
  String get tip5;

  /// No description provided for @rateUpdate.
  ///
  /// In en, this message translates to:
  /// **'Rate Updates'**
  String get rateUpdate;

  /// No description provided for @rateUpdateDesc.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates are updated based on your settings. Check Settings > Converter Tools to configure update frequency and retry behavior.'**
  String get rateUpdateDesc;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

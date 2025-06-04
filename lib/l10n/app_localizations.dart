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
  /// **'Multi Tools'**
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

  /// No description provided for @batchVideoDetailViewer.
  ///
  /// In en, this message translates to:
  /// **'Batch Video Detail Viewer'**
  String get batchVideoDetailViewer;

  /// No description provided for @batchVideoDetailViewerDesc.
  ///
  /// In en, this message translates to:
  /// **'View details of multiple videos at once. You can see size, duration, bitrate, resolution, frame rate, and audio info.'**
  String get batchVideoDetailViewerDesc;

  /// No description provided for @addVideos.
  ///
  /// In en, this message translates to:
  /// **'Add Videos'**
  String get addVideos;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String error(Object message);

  /// No description provided for @dataTab.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataTab;

  /// No description provided for @statsTab.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTab;

  /// No description provided for @dropFilesToAdd.
  ///
  /// In en, this message translates to:
  /// **'Drop files to add them'**
  String get dropFilesToAdd;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @ext.
  ///
  /// In en, this message translates to:
  /// **'Ext'**
  String get ext;

  /// No description provided for @createdDate.
  ///
  /// In en, this message translates to:
  /// **'Created Date'**
  String get createdDate;

  /// No description provided for @sizeMB.
  ///
  /// In en, this message translates to:
  /// **'Size (MB)'**
  String get sizeMB;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @totalBitrate.
  ///
  /// In en, this message translates to:
  /// **'Total Bitrate'**
  String get totalBitrate;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @framerate.
  ///
  /// In en, this message translates to:
  /// **'Framerate'**
  String get framerate;

  /// No description provided for @audioBitrate.
  ///
  /// In en, this message translates to:
  /// **'Audio Bitrate'**
  String get audioBitrate;

  /// No description provided for @audioChannels.
  ///
  /// In en, this message translates to:
  /// **'Audio Channels'**
  String get audioChannels;

  /// No description provided for @noStatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No statistics available'**
  String get noStatsAvailable;

  /// No description provided for @videoStatsSummary.
  ///
  /// In en, this message translates to:
  /// **'Video Statistics Summary'**
  String get videoStatsSummary;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @bitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get bitrate;

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// No description provided for @commonResolution.
  ///
  /// In en, this message translates to:
  /// **'Common Resolution'**
  String get commonResolution;

  /// No description provided for @maxResolution.
  ///
  /// In en, this message translates to:
  /// **'Max Resolution'**
  String get maxResolution;

  /// No description provided for @minResolution.
  ///
  /// In en, this message translates to:
  /// **'Min Resolution'**
  String get minResolution;

  /// No description provided for @averageVideoBitrate.
  ///
  /// In en, this message translates to:
  /// **'Average Video Bitrate'**
  String get averageVideoBitrate;

  /// No description provided for @maxVideoBitrate.
  ///
  /// In en, this message translates to:
  /// **'Max Video Bitrate'**
  String get maxVideoBitrate;

  /// No description provided for @averageAudioBitrate.
  ///
  /// In en, this message translates to:
  /// **'Average Audio Bitrate'**
  String get averageAudioBitrate;

  /// No description provided for @commonAudioChannels.
  ///
  /// In en, this message translates to:
  /// **'Common Audio Channels'**
  String get commonAudioChannels;

  /// No description provided for @averageSize.
  ///
  /// In en, this message translates to:
  /// **'Average Size'**
  String get averageSize;

  /// No description provided for @largest.
  ///
  /// In en, this message translates to:
  /// **'Largest'**
  String get largest;

  /// No description provided for @smallest.
  ///
  /// In en, this message translates to:
  /// **'Smallest'**
  String get smallest;

  /// No description provided for @commonFramerate.
  ///
  /// In en, this message translates to:
  /// **'Common Framerate'**
  String get commonFramerate;

  /// No description provided for @averageFramerate.
  ///
  /// In en, this message translates to:
  /// **'Average Framerate'**
  String get averageFramerate;

  /// No description provided for @dropVideosHere.
  ///
  /// In en, this message translates to:
  /// **'Drop videos here'**
  String get dropVideosHere;

  /// No description provided for @noVideosSelected.
  ///
  /// In en, this message translates to:
  /// **'No videos selected'**
  String get noVideosSelected;

  /// No description provided for @tapAddVideos.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add videos'**
  String get tapAddVideos;

  /// No description provided for @dragDropOrAdd.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop video files here or click the + button'**
  String get dragDropOrAdd;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features:'**
  String get features;

  /// No description provided for @featureViewMultiple.
  ///
  /// In en, this message translates to:
  /// **'View multiple video files at once'**
  String get featureViewMultiple;

  /// No description provided for @featureSeeTechnical.
  ///
  /// In en, this message translates to:
  /// **'See technical details like bitrate, resolution, etc'**
  String get featureSeeTechnical;

  /// No description provided for @featureCompareStats.
  ///
  /// In en, this message translates to:
  /// **'Compare stats across videos'**
  String get featureCompareStats;

  /// No description provided for @addVideosBy.
  ///
  /// In en, this message translates to:
  /// **'You can add videos by:'**
  String get addVideosBy;

  /// No description provided for @clickAddButton.
  ///
  /// In en, this message translates to:
  /// **'Clicking the + button'**
  String get clickAddButton;

  /// No description provided for @dragDropFiles.
  ///
  /// In en, this message translates to:
  /// **'Dragging and dropping files'**
  String get dragDropFiles;

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

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

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

  /// No description provided for @cardCount.
  ///
  /// In en, this message translates to:
  /// **'Number of cards'**
  String get cardCount;

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

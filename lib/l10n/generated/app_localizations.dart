import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appName.
  ///
  /// In ko, this message translates to:
  /// **'씬스틸러'**
  String get appName;

  /// No description provided for @homeTitle.
  ///
  /// In ko, this message translates to:
  /// **'동영상에서 최고의 순간을 추출하세요'**
  String get homeTitle;

  /// No description provided for @pickVideoButtonLabel.
  ///
  /// In ko, this message translates to:
  /// **'동영상 선택'**
  String get pickVideoButtonLabel;

  /// No description provided for @version.
  ///
  /// In ko, this message translates to:
  /// **'버전'**
  String get version;

  /// No description provided for @videoLoadError.
  ///
  /// In ko, this message translates to:
  /// **'동영상을 로드할 수 없습니다.'**
  String get videoLoadError;

  /// No description provided for @videoPickError.
  ///
  /// In ko, this message translates to:
  /// **'동영상이 선택되지 않았거나, 불러오는 데 실패했습니다.\n(iCloud 동영상은 다운로드 후 시도해주세요)'**
  String get videoPickError;

  /// No description provided for @frameExtractionError.
  ///
  /// In ko, this message translates to:
  /// **'프레임 추출 실패'**
  String get frameExtractionError;

  /// No description provided for @saveSuccess.
  ///
  /// In ko, this message translates to:
  /// **'저장되었습니다.'**
  String get saveSuccess;

  /// No description provided for @saveFail.
  ///
  /// In ko, this message translates to:
  /// **'저장 실패'**
  String get saveFail;

  /// No description provided for @galleryAccess.
  ///
  /// In ko, this message translates to:
  /// **'동영상 선택을 위해 갤러리 접근 권한이 필요합니다.'**
  String get galleryAccess;

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'장면 선택'**
  String get appTitle;

  /// No description provided for @extractButtonLabel.
  ///
  /// In ko, this message translates to:
  /// **'추출하기'**
  String get extractButtonLabel;

  /// No description provided for @previewTitle.
  ///
  /// In ko, this message translates to:
  /// **'결과 확인'**
  String get previewTitle;

  /// No description provided for @shareButtonLabel.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get shareButtonLabel;

  /// No description provided for @saveButtonLabel.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get saveButtonLabel;

  /// No description provided for @saveButtonSaving.
  ///
  /// In ko, this message translates to:
  /// **'저장 중...'**
  String get saveButtonSaving;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @quality.
  ///
  /// In ko, this message translates to:
  /// **'화질'**
  String get quality;

  /// No description provided for @format.
  ///
  /// In ko, this message translates to:
  /// **'포맷'**
  String get format;

  /// No description provided for @quickSave.
  ///
  /// In ko, this message translates to:
  /// **'바로 저장'**
  String get quickSave;

  /// No description provided for @original.
  ///
  /// In ko, this message translates to:
  /// **'원본'**
  String get original;

  /// No description provided for @imageSavedToGallery.
  ///
  /// In ko, this message translates to:
  /// **'이미지가 갤러리에 저장되었습니다.'**
  String get imageSavedToGallery;

  /// No description provided for @imageDownloaded.
  ///
  /// In ko, this message translates to:
  /// **'이미지가 다운로드 되었습니다.'**
  String get imageDownloaded;

  /// No description provided for @imageSaved.
  ///
  /// In ko, this message translates to:
  /// **'이미지가 저장되었습니다.'**
  String get imageSaved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

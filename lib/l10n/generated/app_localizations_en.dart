// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Framy';

  @override
  String get homeTitle => 'Extract the best moments from your video';

  @override
  String get pickVideoButtonLabel => 'Pick Video';

  @override
  String get version => 'Version';

  @override
  String get videoLoadError => 'Could not load video.';

  @override
  String get videoPickError =>
      'No video selected or failed to load.\n(Please download iCloud videos first)';

  @override
  String get frameExtractionError => 'Failed to extract frame';

  @override
  String get saveSuccess => 'Saved successfully.';

  @override
  String get saveFail => 'Failed to save.';

  @override
  String get galleryAccess => 'Gallery access is required to pick videos.';

  @override
  String get appTitle => 'Select Scene';

  @override
  String get extractButtonLabel => 'Extract';

  @override
  String get previewTitle => 'Preview';

  @override
  String get shareButtonLabel => 'Share';

  @override
  String get saveButtonLabel => 'Save';

  @override
  String get saveButtonSaving => 'Saving...';

  @override
  String get settings => 'Settings';

  @override
  String get quality => 'Quality';

  @override
  String get format => 'Format';

  @override
  String get quickSave => 'Quick Save';

  @override
  String get original => 'Original';

  @override
  String get imageSavedToGallery => 'Image saved to gallery.';

  @override
  String get imageDownloaded => 'Image downloaded.';

  @override
  String get imageSaved => 'Image saved.';
}

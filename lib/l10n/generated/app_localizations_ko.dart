// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '프레이미';

  @override
  String get homeTitle => '동영상에서 최고의 순간을 추출하세요';

  @override
  String get pickVideoButtonLabel => '동영상 선택';

  @override
  String get version => '버전';

  @override
  String get videoLoadError => '동영상을 로드할 수 없습니다.';

  @override
  String get videoPickError =>
      '동영상이 선택되지 않았거나, 불러오는 데 실패했습니다.\n(iCloud 동영상은 다운로드 후 시도해주세요)';

  @override
  String get frameExtractionError => '프레임 추출 실패';

  @override
  String get saveSuccess => '저장되었습니다.';

  @override
  String get saveFail => '저장 실패';

  @override
  String get galleryAccess => '동영상 선택을 위해 갤러리 접근 권한이 필요합니다.';

  @override
  String get appTitle => '장면 선택';

  @override
  String get extractButtonLabel => '추출하기';

  @override
  String get previewTitle => '결과 확인';

  @override
  String get shareButtonLabel => '공유';

  @override
  String get saveButtonLabel => '저장';

  @override
  String get saveButtonSaving => '저장 중...';

  @override
  String get settings => '설정';

  @override
  String get quality => '화질';

  @override
  String get format => '포맷';

  @override
  String get quickSave => '바로 저장';

  @override
  String get original => '원본';

  @override
  String get imageSavedToGallery => '이미지가 갤러리에 저장되었습니다.';

  @override
  String get imageDownloaded => '이미지가 다운로드 되었습니다.';

  @override
  String get imageSaved => '이미지가 저장되었습니다.';
}

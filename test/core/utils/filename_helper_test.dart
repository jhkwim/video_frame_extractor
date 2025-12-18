import 'package:flutter_test/flutter_test.dart';
import 'package:video_frame_extractor/core/utils/filename_helper.dart';

void main() {
  group('파일명 생성 도우미 테스트 (FilenameHelper)', () {
    test('일반 파일에 대해 올바른 파일명을 생성해야 한다', () {
      final result = FilenameHelper.generateFilename(
        originalName: 'my_video.mp4',
        positionMs: 1500,
        extension: 'jpg',
      );
      expect(result, 'my_video_1500.jpg');
    });

    test('원본 이름에서 확장자를 제거해야 한다', () {
      final result = FilenameHelper.generateFilename(
        originalName: 'movie.mov',
        positionMs: 0,
        extension: 'png',
      );
      expect(result, 'movie_0.png');
    });

    test('확장자가 없는 원본 이름도 처리해야 한다', () {
      final result = FilenameHelper.generateFilename(
        originalName: 'raw_video',
        positionMs: 333,
        extension: 'webp',
      );
      expect(result, 'raw_video_333.webp');
    });

    test('image_picker 접두사와 임의의 문자를 제거해야 한다', () {
      // Assuming pattern image_picker_HEX...
      final result = FilenameHelper.generateFilename(
        originalName: 'image_picker_8A2F1C.mp4',
        positionMs: 500,
        extension: 'jpg',
      );
      // The logic removes 'image_picker_' and leading hex. 
      // result might be empty string -> 'Video'
      expect(result, 'Video_500.jpg');
    });
    
    test('image_picker 접두사는 제거하되 의미 있는 이름은 유지해야 한다', () {
      // If the User picks a file via picker, often it is just random UUID.
      // But if we had 'image_picker_123_MyVideo.mp4', does logic handle it?
      // Logic: replaceFirst hexPattern.
      final result = FilenameHelper.generateFilename(
        originalName: 'image_picker_123AB_MyVideo.mp4',
        positionMs: 1000,
        extension: 'jpg',
      );
      expect(result, '_MyVideo_1000.jpg');
    });

    test('이름이 비어있으면 Video를 기본값으로 사용해야 한다', () {
      final result = FilenameHelper.generateFilename(
        originalName: '.mp4', // edge case
        positionMs: 100,
        extension: 'png',
      );
      expect(result, 'Video_100.png');
    });
    
    test('원본 이름에 경로 구분자가 포함된 경우 처리해야 한다', () {
       final result = FilenameHelper.generateFilename(
        originalName: '/path/to/video.mp4',
        positionMs: 10,
        extension: 'jpg',
      );
      expect(result, 'video_10.jpg');
    });
  });
}

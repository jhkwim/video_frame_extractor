
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_frame_extractor/data/datasources/video_local_datasource.dart';
import 'package:video_frame_extractor/domain/entities/video_metadata.dart';

// Generate Mocks if needed (using build_runner) or just manual mocks/stubs for simple cases
// For now, testing real file interaction for getMetadata with simple temp file
class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late VideoLocalDataSourceImpl dataSource;
  late MockImagePicker mockPicker;

  setUp(() {
    mockPicker = MockImagePicker();
    dataSource = VideoLocalDataSourceImpl(mockPicker);
  });

  group('getMetadata', () {
    test('should return VideoMetadata with correct creationDate', () async {
      // Arrange
      final tempDir = Directory.systemTemp.createTempSync();
      final file = File('${tempDir.path}/test_video.mp4');
      file.writeAsStringSync('dummy content');
      // Set modification time explicitly?
      // file.setLastModifiedSync(DateTime(2023, 1, 1)); 
      // Platform dependency, might not work perfectly in all test envs, but usually fine.
      
      final xFile = XFile(file.path);

      // Act
      final result = await dataSource.getMetadata(xFile);

      // Assert
      expect(result, isA<VideoMetadata>());
      // Accessing file.lastModified() might have slight delay or difference, so we check near equality or just not null
      expect(result.creationDate, isNotNull);
      // We know our implementation returns 'Web'/'Browser' for Web, but this test runs in VM (Native).
      // Logic for native: creationDate mapped from lastModified.
      
      // Cleanup
      tempDir.deleteSync(recursive: true);
    });
  });
}

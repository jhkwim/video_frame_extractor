import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TestVideoHelper {
  static Future<File> createTestVideoFile() async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/test_video.mp4');
    
    // Minimal valid MP4 (base64)
    const String validMp4Base64 = 
      "AAAAIGZ0eXBpc29tAAACAGlzb21pc28yYXZjMQAAAAhmcmVlAAAAG21kYXQAAAGzBgAAAAAA"
      "HicehE7QAAAABB1tZWF0AAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAO7vwAAAAA5tZWhkAAAA"
      "AAAAAAEAAAAAAhRyZXjxwAAAAAMAAAAAAB50cmV4AAAAAAAAAAEAAAAAAAAAAAAAAACAAAAA"
      "AAB1c3RzAAAAAAAAAAEAAAABAAAAAQAAABxzdHNjAAAAAAAAAAEAAAABAAAAAQAAAAEAAAAk"
      "c3RzegAAAAAAAAAAAAAAAQAAAGYAAAAUc3RjbwAAAAAAAAABAAAAMAAAADE1YXZjQwAAAAA"
      "AABgAvYQIAAAAC2F2Y0MxMDAuMAgAAB10cmF1AAAAXHRraGQAAAADAAAAAAAAAAAAAAABAAA"
      "AAAAAAQAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAA"
      "AAAAAAAABAAAAAQAAAAAAAABudWR0YQAAADZtZXRhAAAAAAAAACFoZGxyAAAAAAAAAAGkJ8"
      "AAAB0aWxyAAAAAAAybmluZnQAAABkdnZ1AAABAAAAAAA=";
      
    final bytes = base64Decode(validMp4Base64);
    await file.writeAsBytes(bytes); 
    return file;
  }
}

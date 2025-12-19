import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TestVideoHelper {
  static Future<File> createTestVideoFile() async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/test_video.mp4');
    
    // Generic Base64 content (Mock platform does not parse actual video)
    const String validMp4Base64 = "AAAAGGZ0eXBtcDQyAAAAAG1wNDJpc29t";
      
    final bytes = base64Decode(validMp4Base64);
    await file.writeAsBytes(bytes); 
    return file;
  }
}

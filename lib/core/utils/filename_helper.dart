
abstract class FilenameHelper {
  static String generateFilename({
    required String originalName,
    required double positionMs,
    required String extension,
  }) {
    String nameWithoutExt = originalName.lastIndexOf('.') != -1 
        ? originalName.substring(0, originalName.lastIndexOf('.')) 
        : originalName;
        
    // Remove path if present (just in case raw path is passed)
    if (nameWithoutExt.contains('/')) {
      nameWithoutExt = nameWithoutExt.substring(nameWithoutExt.lastIndexOf('/') + 1);
    }
    if (nameWithoutExt.contains('\\')) {
      nameWithoutExt = nameWithoutExt.substring(nameWithoutExt.lastIndexOf('\\') + 1);
    }

    if (nameWithoutExt.startsWith('image_picker_')) {
      nameWithoutExt = nameWithoutExt.replaceFirst('image_picker_', '');
      final hexPattern = RegExp(r'^[0-9A-F-]+', caseSensitive: false);
      nameWithoutExt = nameWithoutExt.replaceFirst(hexPattern, '');
    }

    if (nameWithoutExt.trim().isEmpty) {
      nameWithoutExt = 'Video';
    }
    
    // Clean invalid characters if any (optional but good practice)
    // nameWithoutExt = nameWithoutExt.replaceAll(RegExp(r'[<>:"/\\|?*]'), '');

    return '${nameWithoutExt}_${positionMs.toInt()}.$extension';
  }
}

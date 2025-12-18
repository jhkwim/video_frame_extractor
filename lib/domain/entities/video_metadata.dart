
class VideoMetadata {
  final DateTime? creationDate;
  final String? make;
  final String? model;
  final double? latitude;
  final double? longitude;

  const VideoMetadata({
    this.creationDate,
    this.make,
    this.model,
    this.latitude,
    this.longitude,
  });

  @override
  String toString() {
    return 'VideoMetadata(creationDate: $creationDate, make: $make, model: $model, latitude: $latitude, longitude: $longitude)';
  }
}

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class UserCanceledFailure extends Failure {
  const UserCanceledFailure() : super('Operation canceled');
}

class VideoPickFailure extends Failure {
  const VideoPickFailure(String originalMessage) : super(originalMessage);
}

class FrameExtractionFailure extends Failure {
  const FrameExtractionFailure(String originalMessage) : super(originalMessage);
}

class SaveFailure extends Failure {
  const SaveFailure(String originalMessage) : super(originalMessage);
}

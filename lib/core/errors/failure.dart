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
  const UserCanceledFailure() : super('작업이 취소되었습니다.');
}

class ProcessFailure extends Failure {
  const ProcessFailure(super.message);
}

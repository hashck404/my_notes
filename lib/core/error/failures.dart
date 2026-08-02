class Failure {
  String message;
  String? details;
  FailureType type;
  Failure({required this.message, required this.type, this.details});
}

enum FailureType {
  authFailure,
  serverFailure,
  networkFailure,
  cacheFailure,
  validationFailure,
  unknownFailure,
}

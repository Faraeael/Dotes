enum AppFailureType {
  validation,
  notFound,
  network,
  timeout,
  rateLimited,
  server,
  parsing,
  unknown,
}

class AppFailure {
  const AppFailure({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final AppFailureType type;
  final String message;
  final int? statusCode;
}

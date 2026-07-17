enum FailureType {
  network,
  server,
  auth,
  cache,
  validation,
  premiumRequired,
  rateLimit,
}

/// Domain-level failure (flat type — no inheritance tree).
class Failure {
  const Failure(
    this.message, {
    this.type = FailureType.server,
  });

  final String message;
  final FailureType type;

  factory Failure.network([String message = 'No internet connection']) =>
      Failure(message, type: FailureType.network);

  factory Failure.server([
    String message = 'Server error. Please try again.',
  ]) =>
      Failure(message, type: FailureType.server);

  factory Failure.auth([String message = 'Authentication failed']) =>
      Failure(message, type: FailureType.auth);

  factory Failure.cache([String message = 'Local storage error']) =>
      Failure(message, type: FailureType.cache);

  factory Failure.validation(String message) =>
      Failure(message, type: FailureType.validation);

  factory Failure.premiumRequired([
    String message = 'Premium subscription required',
  ]) =>
      Failure(message, type: FailureType.premiumRequired);

  factory Failure.rateLimit([
    String message = 'Too many requests. Please wait a moment.',
  ]) =>
      Failure(message, type: FailureType.rateLimit);
}

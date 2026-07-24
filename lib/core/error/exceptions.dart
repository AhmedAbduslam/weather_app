/// Data-layer exceptions thrown by data sources and mapped to [Failure]s
/// by the repository. Keeping them separate from failures keeps the domain
/// layer free of transport-level concerns.
class ServerException implements Exception {
  const ServerException([this.message = 'Server error']);
  final String message;
}

/// Thrown when the API reports an unknown location (error code 1006).
class CityNotFoundException implements Exception {
  const CityNotFoundException();
}

/// Thrown when the request could not reach the server (offline / timeout).
class NetworkException implements Exception {
  const NetworkException();
}

/// Thrown when no cached data exists.
class CacheException implements Exception {
  const CacheException();
}

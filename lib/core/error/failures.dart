import 'package:equatable/equatable.dart';

/// Base class for all domain-level failures.
///
/// The data layer catches raw exceptions (HTTP errors, socket errors, ...)
/// and maps them into one of these types, so the presentation layer only
/// ever deals with meaningful, displayable failures (Open/Closed: new
/// failure kinds can be added without touching existing handling).
sealed class Failure extends Equatable {
  const Failure(this.message);

  /// Human-readable message, safe to show in the UI.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// The API responded, but with an error (5xx, unexpected body, ...).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong. Please try again.']);
}

/// The city entered by the user does not exist (API error code 1006).
class CityNotFoundFailure extends Failure {
  const CityNotFoundFailure([super.message = 'City not found. Check the spelling and try again.']);
}

/// The device is offline or the request timed out.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

/// Nothing useful in the local cache.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached weather available.']);
}

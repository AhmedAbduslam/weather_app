import 'package:equatable/equatable.dart';

/// Pure domain entity — what the app means by "weather", independent of
/// any API shape or storage format.
class Weather extends Equatable {
  const Weather({
    required this.cityName,
    required this.country,
    required this.temperatureC,
    required this.description,
    required this.iconUrl,
    required this.conditionCode,
    required this.lastUpdated,
  });

  final String cityName;
  final String country;
  final double temperatureC;

  /// e.g. "Sunny", "Partly cloudy".
  final String description;

  /// Full https URL of the condition icon provided by the API.
  final String iconUrl;

  /// weatherapi.com condition code, used for an offline icon fallback.
  final int conditionCode;

  /// When the API last refreshed this reading.
  final DateTime lastUpdated;

  @override
  List<Object?> get props =>
      [cityName, country, temperatureC, description, iconUrl, conditionCode, lastUpdated];
}

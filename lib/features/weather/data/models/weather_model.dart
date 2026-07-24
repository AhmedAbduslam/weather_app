import '../../domain/entities/weather.dart';

/// Data-layer representation of [Weather].
///
/// Knows the weatherapi.com JSON shape (and the cache JSON shape) so the
/// domain entity stays completely API-agnostic.
class WeatherModel extends Weather {
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.temperatureC,
    required super.description,
    required super.iconUrl,
    required super.conditionCode,
    required super.lastUpdated,
  });

  /// Parses the weatherapi.com `current.json` response.
  factory WeatherModel.fromApiJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final condition = current['condition'] as Map<String, dynamic>;

    return WeatherModel(
      cityName: location['name'] as String,
      country: location['country'] as String,
      temperatureC: (current['temp_c'] as num).toDouble(),
      description: condition['text'] as String,
      // The API returns a protocol-relative URL ("//cdn.weatherapi.com/...").
      iconUrl: 'https:${condition['icon'] as String}',
      conditionCode: condition['code'] as int,
      lastUpdated: DateTime.parse(current['last_updated'] as String),
    );
  }

  /// Restores a model previously stored with [toJson] (Hive cache).
  factory WeatherModel.fromJson(Map<String, dynamic> json) => WeatherModel(
        cityName: json['cityName'] as String,
        country: json['country'] as String,
        temperatureC: (json['temperatureC'] as num).toDouble(),
        description: json['description'] as String,
        iconUrl: json['iconUrl'] as String,
        conditionCode: json['conditionCode'] as int,
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      );

  /// Flat map used for the Hive cache (no generated adapters needed).
  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'country': country,
        'temperatureC': temperatureC,
        'description': description,
        'iconUrl': iconUrl,
        'conditionCode': conditionCode,
        'lastUpdated': lastUpdated.toIso8601String(),
      };
}

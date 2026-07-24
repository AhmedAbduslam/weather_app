import '../entities/weather.dart';

/// Result of a weather lookup: the entity plus whether it came from the
/// local cache (so the UI can show an "offline" banner).
typedef WeatherResult = ({Weather weather, bool isFromCache});

/// Abstract contract the domain depends on (Dependency Inversion):
/// the presentation/domain layers never know *how* weather is fetched
/// or cached — only that this capability exists.
abstract interface class WeatherRepository {
  /// Fetches current weather for [city].
  ///
  /// On network failure, implementations may fall back to cached data.
  /// Throws a [Failure] (via the use case contract) when nothing can be shown.
  Future<WeatherResult> getCurrentWeather(String city);
}

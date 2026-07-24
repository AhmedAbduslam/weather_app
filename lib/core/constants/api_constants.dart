/// Centralised API configuration so no other layer hard-codes URLs or keys.
///
/// Values are injected at build time via `--dart-define-from-file`:
///   flutter run --dart-define-from-file=env/dev.json
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment('WEATHER_BASE_URL');
  static const String apiKey = String.fromEnvironment('WEATHER_API_KEY');

  /// Builds the `current.json` endpoint for a given city query.
  static Uri currentWeather(String city) =>
      Uri.parse('$baseUrl/current.json').replace(
        queryParameters: {'key': apiKey, 'q': city},
      );
}

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/weather_model.dart';

/// Contract for the remote source (abstracted so the repository can be
/// tested with a mock, and the API could be swapped without touching it).
abstract interface class WeatherRemoteDataSource {
  /// Throws the typed exceptions from [ApiClient] on failure.
  Future<WeatherModel> getCurrentWeather(String city);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  const WeatherRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<WeatherModel> getCurrentWeather(String city) async {
    final json = await _client.getJson(ApiConstants.currentWeather(city));
    return WeatherModel.fromApiJson(json);
  }
}

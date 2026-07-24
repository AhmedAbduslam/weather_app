import '../../../../core/error/failures.dart';
import '../repositories/weather_repository.dart';

/// Single-responsibility use case: "get the current weather for a city".
///
/// Also owns the domain-level input validation (an empty query is a domain
/// rule, not a UI detail). Throws a [Failure] on any error; the cubit
/// catches it and turns it into an error state.
class GetCurrentWeather {
  const GetCurrentWeather(this._repository);

  final WeatherRepository _repository;

  Future<WeatherResult> call(String city) {
    final query = city.trim();
    if (query.isEmpty) {
      throw const CityNotFoundFailure('Please enter a city name.');
    }
    return _repository.getCurrentWeather(query);
  }
}

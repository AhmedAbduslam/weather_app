import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_local_data_source.dart';
import '../datasources/weather_remote_data_source.dart';

/// Concrete repository: orchestrates remote + local sources and maps
/// data-layer exceptions into domain [Failure]s.
///
/// Policy:
/// - success  → cache the result, return it (isFromCache: false)
/// - offline  → fall back to the last cached weather (isFromCache: true),
///              or [NetworkFailure] if the cache is empty
/// - bad city → [CityNotFoundFailure] (no cache fallback — the input is wrong)
class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl({
    required WeatherRemoteDataSource remote,
    required WeatherLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  final WeatherRemoteDataSource _remote;
  final WeatherLocalDataSource _local;

  @override
  Future<WeatherResult> getCurrentWeather(String city) async {
    try {
      final weather = await _remote.getCurrentWeather(city);
      await _local.cacheWeather(weather);
      return (weather: weather, isFromCache: false);
    } on CityNotFoundException {
      throw const CityNotFoundFailure();
    } on NetworkException {
      // Offline: show the last thing we successfully fetched, if any.
      try {
        final cached = await _local.getLastWeather();
        return (weather: cached, isFromCache: true);
      } on CacheException {
        throw const NetworkFailure();
      }
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on FormatException {
      throw const ServerFailure('Could not read weather data.');
    } on TypeError {
      throw const ServerFailure('Could not read weather data.');
    }
  }
}

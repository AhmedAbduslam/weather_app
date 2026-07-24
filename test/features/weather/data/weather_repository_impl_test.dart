import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/error/exceptions.dart';
import 'package:weather_app/core/error/failures.dart';
import 'package:weather_app/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:weather_app/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:weather_app/features/weather/data/models/weather_model.dart';
import 'package:weather_app/features/weather/data/repositories/weather_repository_impl.dart';

class MockRemote extends Mock implements WeatherRemoteDataSource {}

class MockLocal extends Mock implements WeatherLocalDataSource {}

void main() {
  late MockRemote remote;
  late MockLocal local;
  late WeatherRepositoryImpl repository;

  final weather = WeatherModel(
    cityName: 'Cairo',
    country: 'Egypt',
    temperatureC: 34.5,
    description: 'Sunny',
    iconUrl: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
    conditionCode: 1000,
    lastUpdated: DateTime(2026, 7, 22, 14),
  );

  setUp(() {
    remote = MockRemote();
    local = MockLocal();
    repository = WeatherRepositoryImpl(remote: remote, local: local);
    registerFallbackValue(weather);
  });

  test('success: returns remote data and caches it', () async {
    when(() => remote.getCurrentWeather('Cairo')).thenAnswer((_) async => weather);
    when(() => local.cacheWeather(any())).thenAnswer((_) async {});

    final result = await repository.getCurrentWeather('Cairo');

    expect(result.weather, weather);
    expect(result.isFromCache, isFalse);
    verify(() => local.cacheWeather(weather)).called(1);
  });

  test('invalid city: throws CityNotFoundFailure without cache fallback', () {
    when(() => remote.getCurrentWeather('xyzzy'))
        .thenThrow(const CityNotFoundException());

    expect(() => repository.getCurrentWeather('xyzzy'),
        throwsA(isA<CityNotFoundFailure>()));
    verifyNever(() => local.getLastWeather());
  });

  test('offline with cache: falls back to cached weather', () async {
    when(() => remote.getCurrentWeather('Cairo'))
        .thenThrow(const NetworkException());
    when(() => local.getLastWeather()).thenAnswer((_) async => weather);

    final result = await repository.getCurrentWeather('Cairo');

    expect(result.weather, weather);
    expect(result.isFromCache, isTrue);
  });

  test('offline without cache: throws NetworkFailure', () {
    when(() => remote.getCurrentWeather('Cairo'))
        .thenThrow(const NetworkException());
    when(() => local.getLastWeather()).thenThrow(const CacheException());

    expect(() => repository.getCurrentWeather('Cairo'),
        throwsA(isA<NetworkFailure>()));
  });

  test('server error: throws ServerFailure', () {
    when(() => remote.getCurrentWeather('Cairo'))
        .thenThrow(const ServerException('Server error (500)'));

    expect(() => repository.getCurrentWeather('Cairo'),
        throwsA(isA<ServerFailure>()));
  });
}

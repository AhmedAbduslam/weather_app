import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_app/core/error/failures.dart';
import 'package:weather_app/features/weather/domain/entities/weather.dart';
import 'package:weather_app/features/weather/domain/repositories/weather_repository.dart';
import 'package:weather_app/features/weather/domain/usecases/get_current_weather.dart';
import 'package:weather_app/features/weather/presentation/cubit/weather_cubit.dart';

class MockRepository extends Mock implements WeatherRepository {}

void main() {
  late MockRepository repository;
  late WeatherCubit cubit;

  final weather = Weather(
    cityName: 'Cairo',
    country: 'Egypt',
    temperatureC: 34.5,
    description: 'Sunny',
    iconUrl: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
    conditionCode: 1000,
    lastUpdated: DateTime(2026, 7, 22, 14),
  );

  setUp(() {
    repository = MockRepository();
    // The real use case is cheap and pure, so we use it with a mocked
    // repository — this also covers its empty-input validation.
    cubit = WeatherCubit(GetCurrentWeather(repository));
  });

  tearDown(() => cubit.close());

  test('initial state is WeatherInitial', () {
    expect(cubit.state, const WeatherInitial());
  });

  blocTest<WeatherCubit, WeatherState>(
    'success: emits [Loading, Loaded] with fresh data',
    build: () {
      when(() => repository.getCurrentWeather('Cairo'))
          .thenAnswer((_) async => (weather: weather, isFromCache: false));
      return cubit;
    },
    act: (c) => c.search('Cairo'),
    expect: () => [
      const WeatherLoading(),
      WeatherLoaded(weather, isFromCache: false),
    ],
  );

  blocTest<WeatherCubit, WeatherState>(
    'offline fallback: emits Loaded with isFromCache=true',
    build: () {
      when(() => repository.getCurrentWeather('Cairo'))
          .thenAnswer((_) async => (weather: weather, isFromCache: true));
      return cubit;
    },
    act: (c) => c.search('Cairo'),
    expect: () => [
      const WeatherLoading(),
      WeatherLoaded(weather, isFromCache: true),
    ],
  );

  blocTest<WeatherCubit, WeatherState>(
    'invalid city: emits [Loading, Error] with the failure message',
    build: () {
      when(() => repository.getCurrentWeather('xyzzy'))
          .thenThrow(const CityNotFoundFailure());
      return cubit;
    },
    act: (c) => c.search('xyzzy'),
    expect: () => [
      const WeatherLoading(),
      const WeatherError(
          'City not found. Check the spelling and try again.'),
    ],
  );

  blocTest<WeatherCubit, WeatherState>(
    'empty input: emits Error without calling the repository',
    build: () => cubit,
    act: (c) => c.search('   '),
    expect: () => [
      const WeatherLoading(),
      const WeatherError('Please enter a city name.'),
    ],
    verify: (_) => verifyZeroInteractions(repository),
  );
}

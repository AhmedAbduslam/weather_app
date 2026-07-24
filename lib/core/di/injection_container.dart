import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../../features/weather/data/datasources/weather_local_data_source.dart';
import '../../features/weather/data/datasources/weather_remote_data_source.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';
import '../../features/weather/domain/usecases/get_current_weather.dart';
import '../../features/weather/presentation/cubit/weather_cubit.dart';
import '../network/api_client.dart';

/// Service locator (get_it). All wiring lives here — the only place that
/// knows which concrete classes implement which abstractions (Dependency
/// Inversion in practice).
final sl = GetIt.instance;

Future<void> init() async {
  // External
  await Hive.initFlutter();
  final box = await Hive.openBox<Map>(WeatherLocalDataSourceImpl.boxName);
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // Core
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // Data sources (registered against their abstract types)
  sl.registerLazySingleton<WeatherRemoteDataSource>(
      () => WeatherRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<WeatherLocalDataSource>(
      () => WeatherLocalDataSourceImpl(box));

  // Repository
  sl.registerLazySingleton<WeatherRepository>(
      () => WeatherRepositoryImpl(remote: sl(), local: sl()));

  // Use cases
  sl.registerLazySingleton<GetCurrentWeather>(() => GetCurrentWeather(sl()));

  // Cubit: factory, so each screen gets a fresh instance with clean state.
  sl.registerFactory<WeatherCubit>(() => WeatherCubit(sl()));
}

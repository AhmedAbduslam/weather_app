import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/weather_model.dart';

/// Contract for the local cache.
abstract interface class WeatherLocalDataSource {
  /// Returns the last cached weather, or throws [CacheException] if none.
  Future<WeatherModel> getLastWeather();

  Future<void> cacheWeather(WeatherModel weather);
}

/// Hive-backed cache of the single most recent successful fetch,
/// so the app can still show something when offline (bonus requirement).
class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  const WeatherLocalDataSourceImpl(this._box);

  static const boxName = 'weather_cache';
  static const _key = 'last_weather';

  final Box<Map> _box;

  @override
  Future<WeatherModel> getLastWeather() async {
    final stored = _box.get(_key);
    if (stored == null) throw const CacheException();
    // Hive returns Map<dynamic, dynamic>; normalise the keys.
    return WeatherModel.fromJson(Map<String, dynamic>.from(stored));
  }

  @override
  Future<void> cacheWeather(WeatherModel weather) =>
      _box.put(_key, weather.toJson());
}

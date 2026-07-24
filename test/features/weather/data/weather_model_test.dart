import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/features/weather/data/models/weather_model.dart';

void main() {
  const apiJson = {
    'location': {'name': 'Cairo', 'country': 'Egypt'},
    'current': {
      'temp_c': 34.5,
      'last_updated': '2026-07-22 14:00',
      'condition': {
        'text': 'Sunny',
        'icon': '//cdn.weatherapi.com/weather/64x64/day/113.png',
        'code': 1000,
      },
    },
  };

  group('WeatherModel', () {
    test('fromApiJson parses the weatherapi.com response', () {
      final model = WeatherModel.fromApiJson(apiJson);

      expect(model.cityName, 'Cairo');
      expect(model.country, 'Egypt');
      expect(model.temperatureC, 34.5);
      expect(model.description, 'Sunny');
      expect(model.conditionCode, 1000);
      // Protocol-relative icon URL must be prefixed with https:
      expect(model.iconUrl,
          'https://cdn.weatherapi.com/weather/64x64/day/113.png');
      expect(model.lastUpdated, DateTime(2026, 7, 22, 14));
    });

    test('toJson / fromJson round-trips (cache format)', () {
      final original = WeatherModel.fromApiJson(apiJson);
      final restored = WeatherModel.fromJson(original.toJson());

      expect(restored, original);
    });
  });
}

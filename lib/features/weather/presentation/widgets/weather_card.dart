import 'package:flutter/material.dart';

import '../../domain/entities/weather.dart';

/// Card showing the fetched weather. Pure presentation: receives a domain
/// entity and renders it — no fetching or state logic.
class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key, required this.weather, required this.isFromCache});

  final Weather weather;
  final bool isFromCache;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFromCache) ...[
              _OfflineBanner(lastUpdated: weather.lastUpdated),
              const SizedBox(height: 16),
            ],
            Text(
              '${weather.cityName}, ${weather.country}',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            _WeatherIcon(weather: weather),
            Text(
              '${weather.temperatureC.toStringAsFixed(1)}°C',
              style: theme.textTheme.displayMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(weather.description, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.lastUpdated});

  final DateTime lastUpdated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 18, color: theme.colorScheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Offline — cached from '
              '${lastUpdated.day}/${lastUpdated.month} '
              '${lastUpdated.hour.toString().padLeft(2, '0')}:'
              '${lastUpdated.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    // Network icon from the API; falls back to a Material icon when the
    // image can't load (e.g. viewing cached data while offline).
    return Image.network(
      weather.iconUrl,
      width: 96,
      height: 96,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        _fallbackIcon(weather.conditionCode),
        size: 96,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Maps weatherapi.com condition codes to a rough Material icon so the
  /// card still shows *something* meaningful offline.
  IconData _fallbackIcon(int code) {
    if (code == 1000) return Icons.wb_sunny; // clear/sunny
    if (code <= 1030) return Icons.cloud; // cloudy / overcast / mist
    if (code <= 1087) return Icons.thunderstorm; // thundery outbreaks
    if (code <= 1237) return Icons.ac_unit; // snow / sleet / ice
    if (code <= 1264) return Icons.umbrella; // rain / drizzle
    return Icons.cloud; // remaining mixed conditions
  }
}

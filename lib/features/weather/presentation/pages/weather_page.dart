import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/weather_cubit.dart';
import '../widgets/city_search_field.dart';
import '../widgets/error_view.dart';
import '../widgets/weather_card.dart';

/// The single screen of the app: search field on top, and below it the
/// current cubit state rendered exhaustively (idle / loading / card / error).
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  /// Remembered so the error view's "Try again" can repeat the last search.
  String _lastQuery = '';

  void _search(String city) {
    _lastQuery = city;
    context.read<WeatherCubit>().search(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather'), centerTitle: true),
      body: SafeArea(
        // Responsive: the content is centered and capped at 500px wide, so
        // it fills a phone but doesn't stretch across a tablet/landscape.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<WeatherCubit, WeatherState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      CitySearchField(
                        onSearch: _search,
                        enabled: state is! WeatherLoading,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildBody(state),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Exhaustive mapping of state → widget (sealed class guarantees no case
  /// is forgotten).
  Widget _buildBody(WeatherState state) {
    return switch (state) {
      WeatherInitial() => const Padding(
          padding: EdgeInsets.only(top: 48),
          child: Column(
            children: [
              Icon(Icons.travel_explore, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text('Search for a city to see its current weather'),
            ],
          ),
        ),
      WeatherLoading() => const Padding(
          padding: EdgeInsets.only(top: 64),
          child: Center(child: CircularProgressIndicator()),
        ),
      WeatherLoaded(:final weather, :final isFromCache) =>
        WeatherCard(weather: weather, isFromCache: isFromCache),
      WeatherError(:final message) => Padding(
          padding: const EdgeInsets.only(top: 32),
          child: ErrorView(
            message: message,
            onRetry: _lastQuery.trim().isEmpty ? null : () => _search(_lastQuery),
          ),
        ),
    };
  }
}

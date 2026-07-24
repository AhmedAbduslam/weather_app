part of 'weather_cubit.dart';

/// The screen's finite set of states. Modelling them as a sealed hierarchy
/// means the UI must handle every case (exhaustive switch) — no forgotten
/// loading or error handling.
sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

/// Nothing searched yet.
class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

/// A request is in flight — UI shows the loading indicator.
class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

/// Weather is available. [isFromCache] is true when the data came from the
/// offline cache, so the UI can show an "offline" banner.
class WeatherLoaded extends WeatherState {
  const WeatherLoaded(this.weather, {required this.isFromCache});

  final Weather weather;
  final bool isFromCache;

  @override
  List<Object?> get props => [weather, isFromCache];
}

/// The lookup failed and there is nothing to show.
class WeatherError extends WeatherState {
  const WeatherError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
